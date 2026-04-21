part of '../../page/receipt_page.dart';

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
                  size: ThemeSize.iconLarge,
                  color: context.colorScheme.primary.withValues(alpha: 0.3),
                ),
                const SizedBox(height: ThemeSize.spacingM),
                ThemeTypography.titleMedium(
                  context,
                  'Henüz fiş seçilmedi.',
                  color: context.colorScheme.primary,
                ),
                const SizedBox(height: ThemeSize.spacingS),
                ThemeTypography.bodyMedium(
                  context,
                  'Galerinizden fiş seçin veya kamerayla çekin.',
                  color: context.colorScheme.primary,
                  textAlign: TextAlign.center,
                ),
              ],
            )
          : GridView.builder(
              padding: const ThemePadding.marginBottom16(),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: ThemeSize.spacingM,
                crossAxisSpacing: ThemeSize.spacingM,
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
