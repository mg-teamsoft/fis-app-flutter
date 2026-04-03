part of '../../page/receipt_process.dart';

class _ReceiptProcessList extends StatelessWidget {
  const _ReceiptProcessList({
    required this.files,
    required this.processing,
    required this.bytesCache,
  });

  final List<XFile> files;
  final bool processing;
  final Map<String, Future<Uint8List>> bytesCache;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GridView.builder(
        itemCount: files.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
        ),
        itemBuilder: (_, i) {
          final file = files[i];
          return ClipRRect(
            borderRadius: BorderRadius.circular(8),
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
                        fit: BoxFit.cover,
                      );
                    },
                  )
                : Image.file(
                    File(file.path),
                    fit: BoxFit.cover,
                  ),
          );
        },
      ),
    );
  }
}
