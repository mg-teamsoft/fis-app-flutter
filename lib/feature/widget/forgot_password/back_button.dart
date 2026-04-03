part of '../../page/forget_password.dart';

final class _ForgotPasswordBackButton extends StatelessWidget {
  const _ForgotPasswordBackButton({required this.onPressed});

  final void Function() onPressed;

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
