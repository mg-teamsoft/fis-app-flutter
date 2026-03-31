part of '../../page/settings.dart';

final class _SettingsTransaction extends StatelessWidget {
  const _SettingsTransaction();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Icon(Icons.settings, color: Colors.blue),
            const SizedBox(width: ThemeSize.spacingS),
            Text(
              'İşlem Yönetimi',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: context.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(width: ThemeSize.spacingS),
        Text(
          'Dahil edilecek işlem türlerini seçin.',
          style: context.textTheme.titleMedium?.copyWith(
            color: context.colorScheme.primary,
          ),
        ),
      ],
    );
  }
}
