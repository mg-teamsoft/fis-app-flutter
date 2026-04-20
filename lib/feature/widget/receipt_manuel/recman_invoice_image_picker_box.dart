part of '../../page/receipt_manuel_page.dart';

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
      borderRadius: ThemeRadius.circular16,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          color: context.colorScheme.surface,
          borderRadius: ThemeRadius.circular16,
          border: Border.all(
            color: hasError ? context.theme.error : context.colorScheme.surface,
            width: 1.5,
          ),
        ),
        child: hasImage
            ? ClipRRect(
                borderRadius: ThemeRadius.circular12,
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
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.add_photo_alternate_outlined,
                        size: ThemeSize.iconXL,
                        color: context.colorScheme.onSurfaceVariant,
                      ),
                      const SizedBox(height: ThemeSize.spacingS),
                      ThemeTypography.bodyMedium(
                        context,
                        'Fiş görseli ekle',
                        color: context.colorScheme.onSurfaceVariant,
                        weight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }
}
