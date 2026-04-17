part of '../../page/register_page.dart';

final class _RegisterBackButton extends StatelessWidget {
  const _RegisterBackButton({required this.onPressed});

  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: ThemeTypography.titleMedium(
        context,
        'Giriş Ekranına Git',
        weight: FontWeight.w700,
        color: context.colorScheme.primary,
      ),
    );
  }
}
