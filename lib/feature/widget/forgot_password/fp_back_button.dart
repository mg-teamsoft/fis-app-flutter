part of '../../page/forget_password_page.dart';

final class _ForgotPasswordBackButton extends StatelessWidget {
  const _ForgotPasswordBackButton({required this.onPressed});

  final void Function() onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: ThemeTypography.titleLarge(
        context,
        'Giriş sayfasına dön',
        color: context.colorScheme.primary,
        weight: FontWeight.w700,
      ),
    );
  }
}
