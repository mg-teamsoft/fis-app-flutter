part of '../../page/receipt.dart';

class _ReceiptMidHead extends StatelessWidget {
  const _ReceiptMidHead({
    required this.picked,
    required this.bytesCache,
  });

  final List<XFile> picked;
  final Map<String, Future<Uint8List>> bytesCache;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: picked.isEmpty
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.receipt_long_outlined,
                  size: 64,
                  color: context.colorScheme.primary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: 16),
                Text(
                  'Henüz fiş seçilmedi.',
                  style: context.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Galerinizden fiş seçin veya kamerayla çekin.',
                  textAlign: TextAlign.center,
                  style: context.textTheme.bodyMedium?.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            )
          : GridView.builder(
              padding: const EdgeInsets.only(bottom: 16),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
              ),
              itemCount: picked.length,
              itemBuilder: (_, i) {
                final file = picked[i];
                return ClipRRect(
                  borderRadius: BorderRadius.circular(20),
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
