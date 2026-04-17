part of '../../page/receipt_result_page.dart';

class _ReceiptResultClipRect extends StatelessWidget {
  const _ReceiptResultClipRect({
    required this.item,
    required this.bytesCache,
    required this.photoController,
  });

  final SelectedItem item;
  final Map<String, Future<Uint8List>> bytesCache;
  final PhotoViewController photoController;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: kIsWeb
          ? FutureBuilder<Uint8List>(
              future: bytesCache.putIfAbsent(
                item.file.path,
                item.file.readAsBytes,
              ),
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return PhotoView(
                  imageProvider: MemoryImage(snap.data!),
                  controller: photoController,
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  minScale: PhotoViewComputedScale.contained * 0.95,
                  maxScale: PhotoViewComputedScale.covered * 4.0,
                  basePosition: Alignment.center,
                  tightMode: true,
                );
              },
            )
          : PhotoView(
              imageProvider: FileImage(File(item.file.path)),
              controller: photoController,
              backgroundDecoration:
                  const BoxDecoration(color: Colors.transparent),
              minScale: PhotoViewComputedScale.contained * 0.95,
              maxScale: PhotoViewComputedScale.covered * 4.0,
              basePosition: Alignment.center,
              tightMode: true,
            ),
    );
  }
}
