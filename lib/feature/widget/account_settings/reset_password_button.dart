part of '../../page/account_settings.dart';

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
        minimumSize: const Size.fromHeight(56),
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
      label: Text(
        'Şifreyi Sıfırla',
        style: context.textTheme.bodyMedium?.copyWith(
          color: context.colorScheme.onSurface,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
