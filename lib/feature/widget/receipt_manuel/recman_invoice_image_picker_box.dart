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
