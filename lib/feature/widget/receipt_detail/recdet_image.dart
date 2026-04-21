part of '../../page/receipt_detail_page.dart';

final class _ReceiptDetailImage extends StatefulWidget {
  const _ReceiptDetailImage({
    required this.size,
    required this.imageUrl,
  });

  final String imageUrl;
  final Size size;

  @override
  State<_ReceiptDetailImage> createState() => _ReceiptImageState();
}

class _ReceiptImageState extends State<_ReceiptDetailImage> {
  int _rotationQuarterTurns = 0;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.size.height * 0.25,
      decoration: BoxDecoration(
        color: context.colorScheme.surface,
        borderRadius: ThemeRadius.circular24,
        boxShadow: [
          BoxShadow(
            color: context.colorScheme.onSurface.withValues(alpha: 0.06),
            offset: const Offset(0, 10),
            blurRadius: 24,
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: widget.imageUrl.isNotEmpty
          ? Stack(
              children: [
                Positioned.fill(
                  child: InteractiveViewer(
                    minScale: 1,
                    maxScale: 5,
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: RotatedBox(
                        quarterTurns: _rotationQuarterTurns,
                        child: Image.network(
                          widget.imageUrl,
                          fit: BoxFit.fitWidth,
                          errorBuilder: (_, error, __) {
                            debugPrint(
                              'Receipt image load failed. url=${widget.imageUrl} error=$error',
                            );
                            return _ReceiptDetailImagePlaceholder(
                              size: widget.size,
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: ThemeSize.spacingS,
                  right: ThemeSize.spacingS,
                  child: Material(
                    color: context.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.8),
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: IconButton(
                      icon: Icon(
                        Icons.rotate_right,
                        color: context.colorScheme.onSurface,
                      ),
                      onPressed: () {
                        setState(() {
                          _rotationQuarterTurns =
                              (_rotationQuarterTurns + 1) % 4;
                        });
                      },
                      tooltip: 'Döndür',
                    ),
                  ),
                ),
              ],
            )
          : _ReceiptDetailImagePlaceholder(
              size: widget.size,
            ),
    );
  }
}
