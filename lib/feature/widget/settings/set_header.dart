part of '../../page/settings_page.dart';

final class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: ThemeTypography.h4(
            context,
            'Ayarlar',
            weight: FontWeight.w900,
            color: context.colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: ThemeSize.spacingL),
        Row(
          children: [
            Icon(Icons.receipt_long, color: context.colorScheme.primary),
            const SizedBox(width: ThemeSize.spacingS),
            ThemeTypography.bodyLarge(
              context,
              'Fiş Limitleri',
              weight: FontWeight.w900,
              color: context.colorScheme.primary,
            ),
          ],
        ),
      ],
    );
  }
}
