part of '../../page/receipt_manuel_page.dart';

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
        const SizedBox(height: ThemeSize.spacingS),
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
                height: ThemeSize.avatarXL,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: context.colorScheme.onSurface.withValues(alpha: 0.35),
                  borderRadius: ThemeRadius.circular16,
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CircularProgressIndicator(
                          color: context.colorScheme.surface),
                      const SizedBox(height: ThemeSize.spacingS),
                      ThemeTypography.bodyLarge(
                        context,
                        'Yükleniyor...',
                        color: context.colorScheme.surface,
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
        if (imageError)
          Padding(
            padding: const ThemePadding.verticalSymmetricSmall(),
            child: ThemeTypography.bodySmall(
              context,
              'Fiş görseli zorunludur',
              color: context.theme.error,
            ),
          ),
      ],
    );
  }
}
