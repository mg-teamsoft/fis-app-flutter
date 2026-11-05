part of '../../page/receipt_page.dart';

class _ReceiptMidHead extends StatelessWidget {
  const _ReceiptMidHead({
    required this.picked,
    required this.removeSelected,
    required this.bytesCache,
  });

  final List<XFile> picked;
  final ValueChanged<XFile> removeSelected;
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
          : CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const ThemePadding.marginBottom16(),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      mainAxisSpacing: ThemeSize.spacingM,
                      crossAxisSpacing: ThemeSize.spacingM,
                    ),
                    delegate: SliverChildBuilderDelegate(
                      (_, i) {
                        final file = picked[i];
                        return Stack(
                          fit: StackFit.expand,
                          children: [
                            ClipRRect(
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
                                  : Image(
                                      image: ResizeImage(
                                        FileImage(File(file.path)),
                                        width: 480,
                                        height: 480,
                                        policy: ResizeImagePolicy.fit,
                                      ),
                                      fit: BoxFit.cover,
                                    ),
                            ),
                            Positioned(
                              top: 0,
                              right: 0,
                              child: IconButton.filledTonal(
                                tooltip: 'Seçimden çıkar',
                                onPressed: () => removeSelected(file),
                                icon: const Icon(Icons.close),
                              ),
                            ),
                          ],
                        );
                      },
                      childCount: picked.length,
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}
