part of '../../page/settings.dart';

final class _SettingsHeader extends StatelessWidget {
  const _SettingsHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Center(
          child: Text(
            'Ayarlar',
            style: context.textTheme.titleLarge?.copyWith(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            const Icon(Icons.receipt_long, color: Colors.blue),
            const SizedBox(width: ThemeSize.spacingS),
            Text(
              'Fiş Limitleri',
              style: context.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w900,
                color: context.colorScheme.primary,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
