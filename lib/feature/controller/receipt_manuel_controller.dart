part of '../page/receipt_manuel_page.dart';

mixin _ConnectionReceiptManuel on State<PageReceiptManuel> {
  final _formKey = GlobalKey<FormState>();
  final _picker = ImagePicker();

  final _businessNameController = TextEditingController();
  final _receiptNoController = TextEditingController();
  final _kdvAmountController = TextEditingController();
  final _totalAmountController = TextEditingController();

  DateTime? _selectedDate;
  late final ReceiptCategory? _selectedCategory;
  final String _paymentType = 'card';
  String? _selectedKdvRate;
  XFile? _invoiceImage;
  Uint8List? _invoiceImageBytes;

  bool _dateError = false;
  bool _imageError = false;
  bool _isUploading = false;
  bool _saving = false;
  bool _fieldsEnabled = false;
  late String? _uploadedKey;
  late String? _uploadedImageUrl;

  @override
  void initState() {
    super.initState();
    _totalAmountController.addListener(_recalculateKdv);
    _selectedCategory = null;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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
      final sha = crytoSHA256Hex(rawBytes);
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
        await _showDuplicateDialog();
        setState(() {
          _invoiceImage = null;
          _invoiceImageBytes = null;
        });
        return;
      }

      final key = rawData['key'] as String;
      final presignedUrl = rawData['presignedUrl'] as String;

      if (!kIsWeb) {
        await s3.putToS3(
          presignedUrl: presignedUrl,
          file: File(file.path),
          headers: {'Content-Type': mime},
        );
      }

      await s3.confirmUpload(
        key: key,
        size: size,
        mime: mime,
        sha256: sha,
      );

      final imageUrl = rawData['imageUrl']?.toString() ??
          rawData['url']?.toString() ??
          presignedUrl.split('?').first;

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
          ? ((e.response!.data as Map)['message'] ?? e.message)
          : (e.message ?? 'Yükleme hatası');
      _showSnackBar('Hata: $msg');
      setState(() {
        _invoiceImage = null;
        _invoiceImageBytes = null;
      });
    } on Exception catch (e) {
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

  Future<void> _showDuplicateDialog() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: ThemeTypography.bodyLarge(
          context,
          'Mükerrer Görsel',
          color: ctx.colorScheme.onSurface,
          weight: FontWeight.w700,
        ),
        content: ThemeTypography.bodyLarge(
          context,
          'Bu görsel daha önce sisteme yüklenmiş. Lütfen farklı bir görsel seçin.',
          color: ctx.theme.error,
          weight: FontWeight.w500,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: ThemeTypography.bodyLarge(
              ctx,
              'Tamam',
              color: ctx.colorScheme.primary,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String msg, {Color? color}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: ThemeTypography.bodyLarge(
          context,
          msg,
          color: context.colorScheme.error,
        ),
        backgroundColor: color ?? context.colorScheme.surface,
      ),
    );
  }

  Future<void> _showErrorDialog(String message) async {
    if (!mounted) return;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: ThemeTypography.bodyLarge(
          context,
          'Hata',
          color: ctx.colorScheme.onSurface,
          weight: FontWeight.w800,
        ),
        content: ThemeTypography.bodyLarge(
          context,
          message,
          color: ctx.colorScheme.error,
          weight: FontWeight.w500,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: ThemeTypography.bodyLarge(
              context,
              'Tamam',
              color: ctx.colorScheme.onSurface,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _extractBackendMessage(
    DioException e, {
    String fallback = 'Sunucu hatası',
  }) {
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

      final payload = <String, dynamic>{
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
      var successMsg = '✅ Fiş başarıyla kaydedildi';
      try {
        debugPrint(
          '[ManualForm][_save] pushing to Excel: sourceKey=$_uploadedKey',
        );
        final ok = await ExcelService().pushReceipt(_uploadedKey!, result);
        debugPrint('[ManualForm][_save] Excel push result: ok=$ok');
        successMsg = ok
            ? "✅ Fiş kaydedildi ve Excel'e eklendi"
            : '✅ Fiş kaydedildi (Excel güncellenemedi)';
      } on Exception catch (e) {
        debugPrint('[ManualForm][_save] Excel push failed: $e');
        successMsg = '✅ Fiş kaydedildi (Excel güncellenemedi)';
      }
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: ThemeTypography.bodyLarge(
            context,
            successMsg,
            color: context.theme.success,
            weight: FontWeight.w700,
          ),
          backgroundColor: context.colorScheme.surface,
        ),
      );

      // Navigate to Excel files page
      await Navigator.of(context).pushNamedAndRemoveUntil(
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
    } on Exception catch (e) {
      debugPrint('[ManualForm][_save] unexpected error: $e');
      if (!mounted) return;
      _showSnackBar(e.toString());
    } finally {
      debugPrint('[ManualForm][_save] finished; resetting saving flag');
      if (mounted) setState(() => _saving = false);
    }
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
      _totalAmountController.text.trim().replaceAll(',', '.'),
    );
    if (total != null && parsed > total) {
      return 'KDV tutarı toplam tutarı aşamaz';
    }
    return null;
  }

  String? _totalAmountValidator(String? value) {
    if (value == null || value.trim().isEmpty) return 'Bu alan zorunludur';
    final parsed = double.tryParse(value.trim().replaceAll(',', '.'));
    if (parsed == null) return 'Geçerli bir tutar giriniz';
    if (parsed <= 0) return "Tutar 0'dan büyük olmalıdır";
    return null;
  }

  String get _dateText => _selectedDate != null
      ? DateFormat('dd/MM/yyyy').format(_selectedDate!)
      : '';
}
