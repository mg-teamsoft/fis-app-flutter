part of '../../page/register.dart';

final class _RegisterBackButton extends StatelessWidget {
  const _RegisterBackButton({required this.onPressed});

  final void Function()? onPressed;
  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: onPressed,
      child: Text(
        'Giriş Ekranına Git',
        style:
            context.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
      ),
    );
  }
}
