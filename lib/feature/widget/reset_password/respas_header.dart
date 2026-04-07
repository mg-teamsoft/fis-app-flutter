part of '../../page/reset_password_page.dart';

final class _ResetPasswordHeader extends StatelessWidget {
  const _ResetPasswordHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ResetPasswordLogo(),
        const SizedBox(height: ThemeSize.spacingM),
        ThemeTypography.bodyMedium(
          context,
          'E-postadaki bağlantıyı açarak geldiniz. Yeni şifrenizi belirleyin.',
          color: context.colorScheme.onSurface,
        ),
      ],
    );
  }
}
