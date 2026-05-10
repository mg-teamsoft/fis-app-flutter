part of '../../page/account_settings_page.dart';

class _AccountSettingsResetPasswordButton extends StatelessWidget {
  const _AccountSettingsResetPasswordButton({
    required this.onResetPassword,
  });

  final VoidCallback onResetPassword;

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: onResetPassword,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(ThemeSize.buttonHeightLarge),
        side: BorderSide(color: context.colorScheme.outline),
        shape: RoundedRectangleBorder(
          borderRadius: ThemeRadius.circular12,
        ),
      ),
      icon: Icon(
        Icons.lock_reset,
        color: context.colorScheme.outline,
        size: ThemeSize.iconMedium,
      ),
      label: ThemeTypography.bodyMedium(
        context,
        'Şifreyi Sıfırla',
        color: context.colorScheme.onSurface,
        weight: FontWeight.w700,
      ),
    );
  }
}
