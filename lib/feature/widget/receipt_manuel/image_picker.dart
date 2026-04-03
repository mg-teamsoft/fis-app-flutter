part of '../../page/receipt_manuel.dart';

class _ReceiptManuelImagePicker extends StatelessWidget {
  const _ReceiptManuelImagePicker({
    required this.invoiceImage,
    required this.invoiceImageBytes,
    required this.isUploading,
    required this.imageError,
    required this.pickInvoiceImage,
  });

  final XFile? invoiceImage;
  final Uint8List? invoiceImageBytes;
  final bool isUploading;
  final bool imageError;
  final VoidCallback pickInvoiceImage;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _FieldLabel('Fiş Görseli*'),
        const SizedBox(height: 8),
        Stack(
          alignment: Alignment.center,
          children: [
            _InvoiceImagePickerBox(
              imageFile: invoiceImage,
              imageBytes: invoiceImageBytes,
              onTap: isUploading ? null : pickInvoiceImage,
              hasError: imageError,
            ),
            if (isUploading)
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
        if (imageError)
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
      ],
    );
  }
}
