part of '../../page/login_page.dart';

final class _RegisterButton extends StatelessWidget {
  const _RegisterButton();

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pushNamed('/register'),
      child: ThemeTypography.titleMedium(
        context,
        'Hesap Oluştur',
        color: context.colorScheme.primary,
        weight: FontWeight.w700,
      ),
    );
  }
}
