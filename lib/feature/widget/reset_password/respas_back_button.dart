part of '../../page/reset_password_page.dart';

final class _ResetPasswordBackButton extends StatelessWidget {
  const _ResetPasswordBackButton(
      {required this.onPressed, required this.enter});

  final VoidCallback onPressed;
  final bool enter;

  @override
  Widget build(BuildContext context) {
    return enter
        ? const SizedBox.shrink()
        : TextButton(
            onPressed: onPressed,
            child: ThemeTypography.titleLarge(
              context,
              'Giriş sayfasına dön',
              color: context.colorScheme.primary,
            ),
          );
  }
}
