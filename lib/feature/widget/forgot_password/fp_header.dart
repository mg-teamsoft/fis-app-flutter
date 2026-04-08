part of '../../page/forget_password_page.dart';

final class _ForgotPasswordHeader extends StatelessWidget {
  const _ForgotPasswordHeader();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const _ForgotPasswordLogo(),
        const SizedBox(
          height: ThemeSize.spacingXXXl,
        ),
        ThemeTypography.bodyMedium(
          context,
          'E-posta adresinizi girin. Şifre sıfırlama adımlarını içeren bir e-posta göndereceğiz.',
          color: context.colorScheme.onSurface,
        ),
      ],
    );
  }
}
