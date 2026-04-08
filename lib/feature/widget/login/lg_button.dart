part of '../../page/login_page.dart';

final class _LoginButton extends StatelessWidget {
  const _LoginButton({required this.isLoading, required this.onPressed});

  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isLoading ? null : onPressed,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: ThemeRadius.circular8),
          padding: const ThemePadding.all10(),
          minimumSize: const Size(120, 40),
        ),
        child: isLoading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                spacing: ThemeSize.spacingL,
                children: [
                  const Icon(
                    Icons.login,
                    size: ThemeSize.iconLarge,
                  ),
                  ThemeTypography.h4(
                    context,
                    'Giriş Yap',
                  ),
                ],
              ),
      ),
    );
  }
}
