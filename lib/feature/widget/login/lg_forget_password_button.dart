part of '../../page/login_page.dart';

final class _ForgetPasswordButton extends StatelessWidget {
  const _ForgetPasswordButton({required this.translations});

  final Translations translations;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pushNamed('/forgotPassword'),
      child: ThemeTypography.titleMedium(
        context,
        translations.page.login.button_forget_password,
        color: context.colorScheme.primary,
        weight: FontWeight.w700,
      ),
    );
  }
}
