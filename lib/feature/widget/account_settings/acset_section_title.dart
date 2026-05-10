part of '../../page/account_settings_page.dart';

class _AccountSettingsSectionTitle extends StatelessWidget {
  const _AccountSettingsSectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return ThemeTypography.bodyMedium(
      context,
      text.toUpperCase(),
      weight: FontWeight.w700,
      color: context.theme.divider,
    );
  }
}
