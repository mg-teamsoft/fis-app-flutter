import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

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
  String? _transactionType = 'income';
  String? _paymentType = 'card';
  String? _selectedKdvRate;
  XFile? _invoiceImage;
  Uint8List? _invoiceImageBytes;

  @override
  void dispose() {
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
    setState(() => _selectedDate = result);
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
    });
  }

  void _save() {
    final isValid = _formKey.currentState?.validate() ?? false;
    if (!isValid) return;

    if (_selectedDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen tarih seçin.')),
      );
      return;
    }

    if (_selectedKdvRate == null || _selectedKdvRate!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen KDV oranı seçin.')),
      );
      return;
    }

    if (_invoiceImage == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen fiş görseli ekleyin.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
          content:
              Text('Manuel fiş formu hazır. Kaydetme entegrasyonu bekliyor.')),
    );
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
                  validator: _requiredValidator,
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
                            validator: _requiredValidator,
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
                  children: [
                    _ChoiceChipButton(
                      label: 'Gelir',
                      selected: _transactionType == 'income',
                      onTap: () => setState(() => _transactionType = 'income'),
                    ),
                    _ChoiceChipButton(
                      label: 'Gider',
                      selected: _transactionType == 'expense',
                      onTap: () => setState(() => _transactionType = 'expense'),
                    ),
                    _ChoiceChipButton(
                      label: 'İade',
                      selected: _transactionType == 'refund',
                      onTap: () => setState(() => _transactionType = 'refund'),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
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
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                            ),
                            validator: _requiredValidator,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
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
                            onChanged: (value) =>
                                setState(() => _selectedKdvRate = value),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _FieldLabel('Toplam Tutar*'),
                const SizedBox(height: 8),
                _TextFieldBox(
                  controller: _totalAmountController,
                  hintText: '0.00',
                  prefixText: '₺ ',
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  validator: _requiredValidator,
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
                      label: 'Kart',
                      selected: _paymentType == 'card',
                      onTap: () => setState(() => _paymentType = 'card'),
                    ),
                    _ChoiceChipButton(
                      label: 'Havale',
                      selected: _paymentType == 'transfer',
                      onTap: () => setState(() => _paymentType = 'transfer'),
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
            onPressed: _save,
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
            child: const Text('Fişi Kaydet'),
          ),
        ),
      ),
    );
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Bu alan zorunludur';
    }
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
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final String? prefixText;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hintText,
        prefixText: prefixText,
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
    );
  }
}

class _DateFieldBox extends StatelessWidget {
  const _DateFieldBox({
    required this.value,
    required this.onTap,
  });

  final String value;
  final VoidCallback onTap;

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
          border: Border.all(color: const Color(0xFFD0D5DD)),
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
  });

  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
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
  });

  final XFile? imageFile;
  final Uint8List? imageBytes;
  final VoidCallback onTap;

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
            color: const Color(0xFFD0D5DD),
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
