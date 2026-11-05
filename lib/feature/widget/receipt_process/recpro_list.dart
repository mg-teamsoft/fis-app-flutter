part of '../../page/receipt_process_page.dart';

class _ReceiptProcessList extends StatelessWidget {
  const _ReceiptProcessList({
    required this.files,
    required this.processing,
    required this.bytesCache,
    required this.previewImage,
    required this.removeImage,
  });

  final List<XFile> files;
  final bool processing;
  final Map<String, Future<Uint8List>> bytesCache;
  final ValueChanged<XFile> previewImage;
  final ValueChanged<XFile> removeImage;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: files.isEmpty
          ? const Center(
              child: Text(
                'İşlenecek görsel kalmadı. Geri dönüp yeniden seçebilirsiniz.',
              ),
            )
          : GridView.builder(
              itemCount: files.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                mainAxisSpacing: 8,
                crossAxisSpacing: 8,
              ),
              itemBuilder: (_, i) {
                final file = files[i];
                return Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius: ThemeRadius.circular8,
                      child: InkWell(
                        onTap: processing ? null : () => previewImage(file),
                        child: kIsWeb
                            ? FutureBuilder<Uint8List>(
                                future: bytesCache.putIfAbsent(
                                  file.path,
                                  file.readAsBytes,
                                ),
                                builder: (context, snap) {
                                  if (!snap.hasData) {
                                    return const Center(
                                      child: CircularProgressIndicator(),
                                    );
                                  }
                                  return Image.memory(
                                    snap.data!,
                                    fit: BoxFit.contain,
                                  );
                                },
                              )
                            : Image(
                                image: ResizeImage(
                                  FileImage(File(file.path)),
                                  width: 480,
                                  height: 480,
                                  policy: ResizeImagePolicy.fit,
                                ),
                                fit: BoxFit.contain,
                              ),
                      ),
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: IconButton.filledTonal(
                        tooltip: 'Görseli çıkar',
                        onPressed: processing ? null : () => removeImage(file),
                        icon: const Icon(Icons.close),
                      ),
                    ),
                  ],
                );
              },
            ),
    );
  }
}
