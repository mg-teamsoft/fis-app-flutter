part of '../../page/reset_password.dart';

final class _ResetPasswordBackButton extends StatelessWidget {
  const _ResetPasswordBackButton({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        'Giriş sayfasına dön',
        style: context.textTheme.titleLarge,
      ),
    );
  }
}
