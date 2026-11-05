part of '../../page/receipt_page.dart';

class _ReceiptPhotoTips extends StatelessWidget {
  const _ReceiptPhotoTips();

  static const _tips = [
    'Kenarların kolay algılanması için fişi koyu, tek renkli bir zeminde fotoğraflayın.',
    'Fişi düzleştirin; kıvrım ve kırışıklıkları mümkün olduğunca giderin.',
    'Yazıların net ve okunaklı olduğundan emin olun. Gölge ve yansımadan kaçının.',
    'Devam ettiğinizde görseller, okunabilirlik gözetilerek kırpılır ve yeniden boyutlandırılır.',
  ];

  @override
  Widget build(BuildContext context) {
    final colors = context.colorScheme;
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colors.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: ThemeRadius.circular12,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.lightbulb_outline, size: 18, color: colors.primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Daha iyi sonuçlar için',
                  style: context.textTheme.labelLarge
                      ?.copyWith(color: colors.onSurface),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          for (final tip in _tips)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('•  ', style: context.textTheme.bodySmall),
                  Expanded(
                    child: Text(
                      tip,
                      style: context.textTheme.bodySmall
                          ?.copyWith(color: colors.onSurfaceVariant),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
