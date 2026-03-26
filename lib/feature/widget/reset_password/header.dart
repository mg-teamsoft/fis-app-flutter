part of '../../page/reset_password.dart';

final class _ResetPasswordHeader extends StatelessWidget {
  const _ResetPasswordHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ResetPasswordLogo(),
        const SizedBox(height: ThemeSize.spacingM),
        Text(
          'E-postadaki bağlantıyı açarak geldiniz. Yeni şifrenizi belirleyin.',
          style: context.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
