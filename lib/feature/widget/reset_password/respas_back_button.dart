part of '../../page/reset_password_page.dart';

final class _ResetPasswordBackButton extends StatelessWidget {
  const _ResetPasswordBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: ThemeTypography.titleLarge(
        context,
        'Giriş sayfasına dön',
        color: context.colorScheme.primary,
      ),
    );
  }
}
