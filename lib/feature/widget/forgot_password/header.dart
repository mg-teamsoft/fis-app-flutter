part of '../../page/forget_password.dart';

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
        Text(
          'E-posta adresinizi girin. Şifre sıfırlama adımlarını içeren bir e-posta göndereceğiz.',
          style: context.textTheme.bodyMedium,
        ),
      ],
    );
  }
}
