part of '../../page/account_settings_page.dart';

class _AccountSettingsDeleteAccountLink extends StatelessWidget {
  const _AccountSettingsDeleteAccountLink({
    required this.deleting,
    required this.onDeleteAccount,
  });

  final bool deleting;
  final Future<void> Function() onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return Align(
      child: TextButton(
        onPressed: deleting ? null : onDeleteAccount,
        child: deleting
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : ThemeTypography.bodyMedium(
                context,
                'Hesabı Sil',
                color: context.colorScheme.error,
                weight: FontWeight.w700,
              ),
      ),
    );
  }
}
