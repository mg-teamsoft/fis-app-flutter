import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/receipt_detail.dart';
// ignore: unused_import
import '../services/s3_upload_service.dart';
import '../services/receipt_api_service.dart';
import '../utils/checksum_utils.dart';

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
    // Format to 2 decimal places without triggering the currency formatter
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

  Future<void> _pickInvoiceImage() async {
    final file = await _picker.pickImage(source: ImageSource.gallery);
    if (!mounted || file == null) return;

    Uint8List? bytes;
    if (kIsWeb) {
      bytes = await file.readAsBytes();
    }

    setState(() {
      _invoiceImage = file;
      _invoiceImageBytes = bytes;
      _imageError = false;
    });
  }

  Future<void> _save() async {
    if (_saving) return;
    final isFormValid = _formKey.currentState?.validate() ?? false;

    final newDateError = _selectedDate == null;
    final newImageError = _invoiceImage == null;

    setState(() {
      _dateError = newDateError;
      _imageError = newImageError;
    });

    if (!isFormValid || newDateError || newImageError) return;

    setState(() => _saving = true);
    try {
      // Step 1: upload image → get key + imageUrl
      final upload = await _uploadImage();
      if (!mounted) return;

      // Step 2: parse numeric/date fields
      final totalAmount =
          double.tryParse(_totalAmountController.text.trim()) ?? 0.0;
      final vatAmount =
          double.tryParse(_kdvAmountController.text.trim()) ?? 0.0;
      final vatRate = int.tryParse(_selectedKdvRate ?? '') ?? 0;
      final transactionDate = DateFormat('dd.MM.yyyy').format(_selectedDate!);

      // Step 3: build payload with upload result
      final Map<String, dynamic> payload = {
        'businessName': _businessNameController.text.trim(),
        'receiptNumber': _receiptNoController.text.trim(),
        'totalAmount': totalAmount,
        'vatAmount': vatAmount,
        'vatRate': vatRate,
        'transactionDate': transactionDate,
        'transactionType': _selectedCategory?.name,
        'paymentType': _paymentType,
        'imageUrl': upload?.imageUrl ?? '',
        if (upload?.key != null) 'sourceKey': upload!.key,
      };

      // Step 4: POST to /api/receipts
      final result = await ReceiptApiService().createReceipt(payload);
      if (!mounted) return;
      final id = result['_id'] ?? result['id'] ?? '';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fiş kaydedildi (id: $id)'),
          backgroundColor: const Color(0xFF12B76A),
        ),
      );
      Navigator.of(context).pop();
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = (e.response?.data is Map)
          ? (e.response!.data['message'] ?? e.message)
          : (e.message ?? 'Sunucu hatası');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Hata: $msg'),
          backgroundColor: const Color(0xFFF04438),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString()),
          backgroundColor: const Color(0xFFF04438),
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  /// Validates, checksums, and uploads the invoice image to S3.
  /// Returns a record with [key] (S3 object key) and [imageUrl] on success,
  /// or [null] if skipped / while S3 is commented out.
  Future<({String key, String imageUrl})?> _uploadImage() async {
    if (_invoiceImage == null || kIsWeb) return null;
    setState(() => _isUploading = true);
    try {
      final file = File(_invoiceImage!.path);
      // ignore: unused_local_variable
      final mime = _invoiceImage!.mimeType ?? 'image/jpeg';

      // 1) Compute checksums on raw file
      final bytes = await file.readAsBytes();
      // ignore: unused_local_variable
      final checksum = crc32Base64(bytes);
      // ignore: unused_local_variable
      final sha = _sha256Hex(bytes);

      // 2) Size validation
      final size = bytes.length;
      const maxBytes = 5 * 1024 * 1024;
      const minBytes = 100 * 1024;

      if (size > maxBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Resim en fazla 5 MB olabilir.')),
        );
        return null;
      } else if (size < minBytes) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Resim en az 100 KB olabilir.')),
        );
        return null;
      }

      // TODO: uncomment when ready to upload
      // final service = S3UploadService();
      // final init = await service.initUpload(
      //   contentType: mime,
      //   filename: _invoiceImage!.name,
      //   checksumCRC32: checksum,
      //   sha256: sha,
      // );
      // await service.putToS3(
      //   presignedUrl: init.presignedUrl,
      //   file: file,
      //   headers: {'Content-Type': mime},
      // );
      // await service.confirmUpload(
      //   key: init.key,
      //   size: size,
      //   mime: mime,
      //   sha256: sha,
      // );
      // Once uncommented, replace the return below with:
      // return (key: init.key, imageUrl: ''); // TODO: set imageUrl from your S3/CDN base URL

      return null; // remove when S3 upload is active
    } on DioException catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Yükleme hatası')),
      );
      return null;
    } catch (e) {
      if (!mounted) return null;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
      return null;
    } finally {
      if (mounted) setState(() => _isUploading = false);
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
                      onTap: () => setState(() => _selectedCategory = category),
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
                      onTap: () => setState(() => _paymentType = 'cash'),
                    ),
                    _ChoiceChipButton(
                      label: 'Kredi Kartı',
                      selected: _paymentType == 'card',
                      onTap: () => setState(() => _paymentType = 'card'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _FieldLabel('Fiş Görseli*'),
                const SizedBox(height: 8),
                _InvoiceImagePickerBox(
                  imageFile: _invoiceImage,
                  imageBytes: _invoiceImageBytes,
                  onTap: _pickInvoiceImage,
                  hasError: _imageError,
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
                const SizedBox(height: 12),
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
            onPressed: (_isUploading || _saving) ? null : _save,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1570EF),
              foregroundColor: Colors.white,
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
                : const Text('Fişi Kaydet'),
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
  final VoidCallback onTap;
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
