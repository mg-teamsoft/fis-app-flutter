part of '../../page/settings_page.dart';

final class _SettingsTransaction extends StatelessWidget {
  const _SettingsTransaction();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(Icons.settings, color: context.colorScheme.primary),
            const SizedBox(width: ThemeSize.spacingS),
            ThemeTypography.titleLarge(
              context,
              'İşlem Yönetimi',
              weight: FontWeight.w900,
              color: context.colorScheme.primary,
            ),
          ],
        ),
        const SizedBox(width: ThemeSize.spacingS),
        ThemeTypography.titleMedium(
          context,
          'Dahil edilecek işlem türlerini seçin.',
          color: context.colorScheme.primary,
        ),
      ],
    );
  }
}
