part of '../../page/login_page.dart';

final class _ForgetPasswordButton extends StatelessWidget {
  const _ForgetPasswordButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pushNamed('/forgotPassword'),
      child: ThemeTypography.h4(
        context,
        'Şifremi Unuttum',
        color: context.colorScheme.primary,
        weight: FontWeight.w700,
      ),
    );
  }
}
