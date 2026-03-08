import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:path/path.dart' as p;

import '../models/receipt_detail.dart';
import '../services/s3_upload_service.dart';
import '../services/receipt_api_service.dart';
import '../services/excel_service.dart';
import '../utils/checksum_utils.dart';
import '../utils/mime_utils.dart';

String _sha256Hex(Uint8List bytes) => sha256.convert(bytes).toString();

class ReceiptManualFormPage extends StatefulWidget {
  const ReceiptManualFormPage({super.key});

  @override
  State<ReceiptManualFormPage> createState() => _ReceiptManualFormPageState();
}

class _ReceiptManualFormPageState extends State<ReceiptManualFormPage> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _businessNameController = TextEditingController();
  final _receiptNoController = TextEditingController();
  final _kdvAmountController = TextEditingController();
  final _totalAmountController = TextEditingController();

  DateTime? _selectedDate;
  ReceiptCategory? _selectedCategory;
  String? _paymentType = 'card';
  String? _selectedKdvRate;
  XFile? _invoiceImage;
  Uint8List? _invoiceImageBytes;

  bool _dateError = false;
  bool _imageError = false;
  bool _isUploading = false;
  bool _saving = false;

  /// Whether all form fields and the submit button are enabled.
  /// Only becomes true after the image has been uploaded successfully.
  bool _fieldsEnabled = false;

  /// S3 key returned after a successful upload.
  String? _uploadedKey;

  /// Image URL (CDN / presigned) returned after upload.
  String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _totalAmountController.addListener(_recalculateKdv);
  }

  /// Calculates VAT from the total (VAT-inclusive) amount and the selected rate.
  /// Formula: vatAmount = total × rate ÷ (100 + rate)
  void _recalculateKdv() {
    final total = double.tryParse(_totalAmountController.text.trim());
    final rate = int.tryParse(_selectedKdvRate ?? '');
    if (total == null || rate == null || rate == 0) {
      _kdvAmountController.text = '';
      return;
    }
    final vat = total * rate / (100 + rate);
    _kdvAmountController.text = vat.toStringAsFixed(2);
  }

  @override
  void dispose() {
    _totalAmountController.removeListener(_recalculateKdv);
    _businessNameController.dispose();
    _receiptNoController.dispose();
    _kdvAmountController.dispose();
    _totalAmountController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    if (!_fieldsEnabled) return;
    final now = DateTime.now();
    final initial = _selectedDate ?? now;
    final result = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(2020),
      lastDate: DateTime(now.year + 5),
      locale: const Locale('tr', 'TR'),
    );
    if (!mounted || result == null) return;
    setState(() {
      _selectedDate = result;
      _dateError = false;
    });
  }

  /// Picks an image, then immediately runs the full S3 upload pipeline:
  ///   1. POST /file/init  → if "duplicate" show error and stop
  ///   2. PUT to S3 presigned URL
  ///   3. POST /file/confirm
  /// On success: enable all form fields.
  Future<void> _pickInvoiceImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted || file == null) return;

    Uint8List? bytes;
    if (kIsWeb) {
      bytes = await file.readAsBytes();
    }

    // Show the image immediately in the picker box
    setState(() {
      _invoiceImage = file;
      _invoiceImageBytes = bytes;
      _imageError = false;
      _fieldsEnabled = false; // reset until upload finishes
      _uploadedKey = null;
      _uploadedImageUrl = null;
    });

    // ----- Upload pipeline -----
    setState(() => _isUploading = true);
    try {
      final rawBytes = kIsWeb ? bytes! : await File(file.path).readAsBytes();

      // Size validation
      final size = rawBytes.length;
      const maxBytes = 5 * 1024 * 1024;
      const minBytes = 10 * 1024;
      if (size > maxBytes) {
        _showSnackBar('⚠️ Resim en fazla 5 MB olabilir.');
        setState(() {
          _invoiceImage = null;
          _invoiceImageBytes = null;
        });
        return;
      } else if (size < minBytes) {
        _showSnackBar('⚠️ Resim en az 100 KB olabilir.');
        setState(() {
          _invoiceImage = null;
          _invoiceImageBytes = null;
        });
        return;
      }

      final mime =
          kIsWeb ? (file.mimeType ?? 'image/jpeg') : guessMime(file.path);
      final checksum = crc32Base64(rawBytes);
      final sha = _sha256Hex(rawBytes);
      final filename = p.basename(file.path);

      final s3 = S3UploadService();

      // Step 1: /file/init — check for duplicate
      final rawData = await s3.initUploadRaw(
        contentType: mime,
        filename: filename,
        checksumCRC32: checksum,
        sha256: sha,
      );

      final status = rawData['status']?.toString().toLowerCase();
      if (status == 'duplicate') {
        if (!mounted) return;
        _showDuplicateDialog();
        setState(() {
          _invoiceImage = null;
          _invoiceImageBytes = null;
        });
        return;
      }

      // Parse the init response
      final key = rawData['key'] as String;
      final presignedUrl = rawData['presignedUrl'] as String;
      // NOTE: Do NOT spread the `headers` map from the init response into the
      // PUT request. The presigned URL is signed with only `host` as the
      // SignedHeaders (see X-Amz-SignedHeaders=host in the URL). Any extra
      // headers sent (e.g. x-amz-checksum-crc32) that were NOT part of the
      // presigned signature will cause AWS to return 403 AccessDenied.
      // The checksum is already embedded in the presigned URL query string.

      // Step 2: PUT to S3
      if (!kIsWeb) {
        await s3.putToS3(
          presignedUrl: presignedUrl,
          file: File(file.path),
          headers: {'Content-Type': mime},
        );
      }

      // Step 3: confirm
      await s3.confirmUpload(
        key: key,
        size: size,
        mime: mime,
        sha256: sha,
      );

      // Success — store key/url and unlock form
      final imageUrl = rawData['imageUrl']?.toString() ??
          rawData['url']?.toString() ??
          presignedUrl.split('?').first; // strip query params as fallback

      if (!mounted) return;
      setState(() {
        _uploadedKey = key;
        _uploadedImageUrl = imageUrl;
        _fieldsEnabled = true;
      });

      _showSnackBar('✅ Görsel yüklendi', color: const Color(0xFF12B76A));
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data is Map)
          ? (e.response!.data['message'] ?? e.message)
          : (e.message ?? 'Yükleme hatası');
      _showSnackBar('Hata: $msg');
      setState(() {
        _invoiceImage = null;
        _invoiceImageBytes = null;
      });
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString());
      setState(() {
        _invoiceImage = null;
        _invoiceImageBytes = null;
      });
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showDuplicateDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Mükerrer Görsel'),
        content: const Text(
          'Bu görsel daha önce sisteme yüklenmiş. Lütfen farklı bir görsel seçin.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: color ?? const Color(0xFFF04438),
      ),
    );
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hata'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  String _extractBackendMessage(DioException e,
      {String fallback = 'Sunucu hatası'}) {
    final data = e.response?.data;
    if (data is Map) {
      final map = Map<String, dynamic>.from(data);
      final msg = map['error']?.toString() ?? map['message']?.toString();
      if (msg != null && msg.trim().isNotEmpty) {
        return msg;
      }
    } else if (data is String && data.trim().isNotEmpty) {
      return data;
    }
    final dioMsg = e.message;
    if (dioMsg != null && dioMsg.trim().isNotEmpty) {
      return dioMsg;
    }
    return fallback;
  }

  Future<void> _save() async {
    debugPrint(
      '[ManualForm][_save] triggered: saving=$_saving fieldsEnabled=$_fieldsEnabled',
    );
    if (_saving || !_fieldsEnabled) return;

    final isFormValid = _formKey.currentState?.validate() ?? false;
    final newDateError = _selectedDate == null;
    debugPrint(
      '[ManualForm][_save] validation: isFormValid=$isFormValid dateSelected=${_selectedDate != null}',
    );

    setState(() {
      _dateError = newDateError;
    });

    if (!isFormValid || newDateError) {
      debugPrint(
        '[ManualForm][_save] aborted: form/date invalid (dateError=$newDateError)',
      );
      return;
    }

    setState(() => _saving = true);
    try {
      final totalAmount =
          double.tryParse(_totalAmountController.text.trim()) ?? 0.0;
      final vatAmount =
          double.tryParse(_kdvAmountController.text.trim()) ?? 0.0;
      final vatRate = int.tryParse(_selectedKdvRate ?? '') ?? 0;
      final transactionDate = DateFormat('dd.MM.yyyy').format(_selectedDate!);
      debugPrint(
        '[ManualForm][_save] parsed values: total=$totalAmount vatAmount=$vatAmount vatRate=$vatRate date=$transactionDate',
      );

      final Map<String, dynamic> payload = {
        'businessName': _businessNameController.text.trim(),
        'receiptNumber': _receiptNoController.text.trim(),
        'totalAmount': totalAmount,
        'vatAmount': vatAmount,
        'vatRate': vatRate,
        'transactionDate': transactionDate,
        'transactionType': _selectedCategory?.name,
        'paymentType': _paymentType,
        'imageUrl': _uploadedImageUrl ?? '',
        if (_uploadedKey != null) 'sourceKey': _uploadedKey,
      };
      debugPrint('[ManualForm][_save] payload: $payload');

      // POST to /api/receipts
      debugPrint('[ManualForm][_save] calling ReceiptApiService.createReceipt');
      final result = await ReceiptApiService().createReceipt(payload);
      debugPrint('[ManualForm][_save] createReceipt success: $result');
      if (!mounted) return;

      // Push to Excel: _uploadedKey is always set here because the form is
      // locked until /file/init + putToS3 + confirmUpload all succeed.
      String successMsg = '✅ Fiş başarıyla kaydedildi';
      try {
        debugPrint(
          '[ManualForm][_save] pushing to Excel: sourceKey=$_uploadedKey',
        );
        final ok = await ExcelService().pushReceipt(_uploadedKey!, result);
        debugPrint('[ManualForm][_save] Excel push result: ok=$ok');
        successMsg = ok
            ? '✅ Fiş kaydedildi ve Excel\'e eklendi'
            : '✅ Fiş kaydedildi (Excel güncellenemedi)';
      } catch (e) {
        debugPrint('[ManualForm][_save] Excel push failed: $e');
        successMsg = '✅ Fiş kaydedildi (Excel güncellenemedi)';
      }
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(successMsg),
          backgroundColor: const Color(0xFF12B76A),
        ),
      );

      // Navigate to Excel files page
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/excelFiles',
        (route) => route.isFirst,
      );
    } on DioException catch (e) {
      debugPrint(
        '[ManualForm][_save] DioException: status=${e.response?.statusCode} message=${e.message} data=${e.response?.data}',
      );
      if (!mounted) return;
      final msg = _extractBackendMessage(e);
      await _showErrorDialog(msg);
    } catch (e) {
      debugPrint('[ManualForm][_save] unexpected error: $e');
      if (!mounted) return;
      _showSnackBar(e.toString());
    } finally {
      debugPrint('[ManualForm][_save] finished; resetting saving flag');
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = _selectedDate != null
        ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF3F5F7),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Manuel Fatura',
          style: TextStyle(
            color: Color(0xFF101828),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 1. Image picker — always at top ──────────────────────────
                _FieldLabel('Fiş Görseli*'),
                const SizedBox(height: 8),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    _InvoiceImagePickerBox(
                      imageFile: _invoiceImage,
                      imageBytes: _invoiceImageBytes,
                      onTap: _isUploading ? null : _pickInvoiceImage,
                      hasError: _imageError,
                    ),
                    if (_isUploading)
                      Container(
                        height: 180,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.black.withValues(alpha: 0.35),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(color: Colors.white),
                              SizedBox(height: 12),
                              Text(
                                'Yükleniyor...',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                  ],
                ),
                if (_imageError)
                  const Padding(
                    padding: EdgeInsets.only(top: 6, left: 4),
                    child: Text(
                      'Fiş görseli zorunludur',
                      style: TextStyle(
                        color: Color(0xFFF04438),
                        fontSize: 12,
                      ),
                    ),
                  ),

                // ── Helper hint when no image yet ────────────────────────────
                if (!_fieldsEnabled && !_isUploading) ...[
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF4E5),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFFFB347)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline,
                            color: Color(0xFFE67E00), size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Formu doldurmak için önce fiş görselini yükleyin.',
                            style: TextStyle(
                              color: Color(0xFFE67E00),
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 20),

                // ── 2. Rest of the form — locked until image uploaded ─────────
                AbsorbPointer(
                  absorbing: !_fieldsEnabled,
                  child: Opacity(
                    opacity: _fieldsEnabled ? 1.0 : 0.45,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _FieldLabel('İşletme Adı*'),
                        const SizedBox(height: 8),
                        _TextFieldBox(
                          controller: _businessNameController,
                          hintText: 'Acme Corp',
                          validator: _businessNameValidator,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Tarih*'),
                                  const SizedBox(height: 8),
                                  _DateFieldBox(
                                    value: dateText,
                                    onTap: _pickDate,
                                    hasError: _dateError,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('Fiş No*'),
                                  const SizedBox(height: 8),
                                  _TextFieldBox(
                                    controller: _receiptNoController,
                                    hintText: 'REC-12345',
                                    validator: _receiptNoValidator,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _FieldLabel.rich(
                          main: 'İşlem Türü',
                          suffix: ' (Opsiyonel)',
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: ReceiptCategory.values.map((category) {
                            return _ChoiceChipButton(
                              label: category.label,
                              selected: _selectedCategory == category,
                              onTap: () =>
                                  setState(() => _selectedCategory = category),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 20),
                        _FieldLabel('Toplam Tutar*'),
                        const SizedBox(height: 8),
                        _TextFieldBox(
                          controller: _totalAmountController,
                          hintText: '0.00',
                          prefixText: '₺ ',
                          keyboardType: TextInputType.number,
                          inputFormatters: [_CurrencyInputFormatter()],
                          textAlign: TextAlign.right,
                          validator: _totalAmountValidator,
                        ),
                        const SizedBox(height: 20),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('KDV Oranı (%)'),
                                  const SizedBox(height: 8),
                                  _DropdownFieldBox(
                                    value: _selectedKdvRate,
                                    hintText: 'Oran Seç',
                                    items: const ['1', '8', '10', '18', '20'],
                                    onChanged: (value) {
                                      setState(() => _selectedKdvRate = value);
                                      _recalculateKdv();
                                    },
                                    validator: (value) =>
                                        (value == null || value.isEmpty)
                                            ? 'KDV oranı seçiniz'
                                            : null,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _FieldLabel('KDV Tutarı*'),
                                  const SizedBox(height: 8),
                                  _TextFieldBox(
                                    controller: _kdvAmountController,
                                    hintText: '0.00',
                                    prefixText: '₺ ',
                                    keyboardType: TextInputType.number,
                                    textAlign: TextAlign.right,
                                    readOnly: true,
                                    fillColor: const Color(0xFFF2F4F7),
                                    validator: _kdvAmountValidator,
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        _FieldLabel.rich(
                          main: 'Ödeme Türü',
                          suffix: ' (Opsiyonel)',
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 10,
                          runSpacing: 10,
                          children: [
                            _ChoiceChipButton(
                              label: 'Nakit',
                              selected: _paymentType == 'cash',
                              onTap: () =>
                                  setState(() => _paymentType = 'cash'),
                            ),
                            _ChoiceChipButton(
                              label: 'Kredi Kartı',
                              selected: _paymentType == 'card',
                              onTap: () =>
                                  setState(() => _paymentType = 'card'),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(20, 12, 20, 20),
        child: SizedBox(
          height: 56,
          child: ElevatedButton(
            onPressed:
                (_isUploading || _saving || !_fieldsEnabled) ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1570EF),
              foregroundColor: Colors.white,
              disabledBackgroundColor: const Color(0xFFD0D5DD),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              textStyle: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: (_isUploading || _saving)
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  )
                : const Text('Fişi Kaydet ve Excele Ekle'),
          ),
        ),
      ),
    );
  }

  String? _businessNameValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan zorunludur';
    if (value.trim().length < 2) return 'En az 2 karakter giriniz';
    return null;
  }

  String? _receiptNoValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan zorunludur';
    final regex = RegExp(r'^[a-zA-Z0-9\-_]+$');
    if (!regex.hasMatch(value.trim())) {
      return 'Yalnızca harf, rakam, - ve _ kullanılabilir';
    }
    return null;
  }

  String? _kdvAmountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan zorunludur';
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null) return 'Geçerli bir tutar giriniz';
    if (parsed < 0) return 'Tutar negatif olamaz';
    final total = double.tryParse(
        _totalAmountController.text.trim().replaceAll(',', '.'));
    if (total != null && parsed > total) {
      return 'KDV tutarı toplam tutarı aşamaz';
    }
    return null;
  }

  String? _totalAmountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan zorunludur';
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null) return 'Geçerli bir tutar giriniz';
    if (parsed <= 0) return 'Tutar 0\'dan büyük olmalıdır';
    return null;
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Widget helpers (unchanged from original)
// ─────────────────────────────────────────────────────────────────────────────

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text)
      : main = null,
        suffix = null;

  const _FieldLabel.rich({
    required this.main,
    required this.suffix,
  }) : text = null;

  final String? text;
  final String? main;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    if (text != null) {
      return Text(
        text!,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF101828),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF101828),
        ),
        children: [
          TextSpan(text: main),
          TextSpan(
            text: suffix,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: Color(0xFF98A2B3),
            ),
          ),
        ],
      ),
    );
  }
}

class _TextFieldBox extends StatelessWidget {
  const _TextFieldBox({
    required this.controller,
    required this.hintText,
    this.validator,
    this.prefixText,
    this.keyboardType,
    this.inputFormatters,
    this.textAlign = TextAlign.left,
    this.readOnly = false,
    this.fillColor,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final String? prefixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final bool readOnly;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        prefixText: prefixText,
        filled: true,
        fillColor: fillColor ?? Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1570EF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF04438)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF04438)),
        ),
      ),
    );
  }
}

class _DateFieldBox extends StatelessWidget {
  const _DateFieldBox({
    required this.value,
    required this.onTap,
    this.hasError = false,
  });

  final String value;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError ? const Color(0xFFF04438) : const Color(0xFFD0D5DD),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? 'gg/aa/yyyy' : value,
                style: TextStyle(
                  color: value.isEmpty
                      ? const Color(0xFF98A2B3)
                      : const Color(0xFF101828),
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 20),
          ],
        ),
      ),
    );
  }
}

class _DropdownFieldBox extends StatelessWidget {
  const _DropdownFieldBox({
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      validator: validator,
      items: items
          .map((item) => DropdownMenuItem<String>(
                value: item,
                child: Text('%$item'),
              ))
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.white,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFD0D5DD)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF1570EF), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF04438)),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFFF04438)),
        ),
      ),
      icon: const Icon(Icons.keyboard_arrow_down_rounded),
      dropdownColor: Colors.white,
    );
  }
}

class _ChoiceChipButton extends StatelessWidget {
  const _ChoiceChipButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(999),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFEAF2FF) : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: selected ? const Color(0xFF1570EF) : const Color(0xFFD0D5DD),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? const Color(0xFF1570EF) : const Color(0xFF344054),
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

class _InvoiceImagePickerBox extends StatelessWidget {
  const _InvoiceImagePickerBox({
    required this.imageFile,
    required this.imageBytes,
    required this.onTap,
    this.hasError = false,
  });

  final XFile? imageFile;
  final Uint8List? imageBytes;
  final VoidCallback? onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    final hasImage = imageFile != null;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError ? const Color(0xFFF04438) : const Color(0xFFD0D5DD),
            width: 1.5,
          ),
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: kIsWeb
                    ? Image.memory(
                        imageBytes!,
                        fit: BoxFit.cover,
                        width: double.infinity,
                      )
                    : Image.file(
                        File(imageFile!.path),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
              )
            : CustomPaint(
                painter: _DashedBorderPainter(),
                child: const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: 44,
                        color: Color(0xFF98A2B3),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Fiş görseli ekle',
                        style: TextStyle(
                          color: Color(0xFF667085),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const color = Color(0xFFD0D5DD);
    const dashWidth = 8.0;
    const dashSpace = 6.0;
    const radius = 16.0;
    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0.75, 0.75, size.width - 1.5, size.height - 1.5),
      const Radius.circular(radius),
    );

    final path = Path()..addRRect(rect);
    final metrics = path.computeMetrics();
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    for (final metric in metrics) {
      double distance = 0;
      while (distance < metric.length) {
        final next = distance + dashWidth;
        canvas.drawPath(metric.extractPath(distance, next), paint);
        distance += dashWidth + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// ATM-style currency formatter: digits push in from the right of a fixed
/// decimal point (2 decimal places). The dot is never user-editable.
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extract only digit characters from whatever was typed
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) {
      return newValue.copyWith(
        text: '0.00',
        selection: const TextSelection.collapsed(offset: 4),
      );
    }

    // Max 10 digits (99 999 999.99)
    final trimmed =
        digits.length > 10 ? digits.substring(digits.length - 10) : digits;

    // Pad to at least 3 digits so we always have X.XX
    final padded = trimmed.padLeft(3, '0');

    // Split into integer and decimal parts
    final intRaw = padded.substring(0, padded.length - 2);
    final decPart = padded.substring(padded.length - 2);

    // Strip leading zeros from integer part, keep at least one digit
    final intPart = intRaw.replaceFirst(RegExp(r'^0+'), '').isEmpty
        ? '0'
        : intRaw.replaceFirst(RegExp(r'^0+'), '');

    final result = '$intPart.$decPart';
    return newValue.copyWith(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
