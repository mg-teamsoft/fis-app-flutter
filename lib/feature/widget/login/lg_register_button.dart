part of '../../page/login_page.dart';

final class _RegisterButton extends StatelessWidget {
  const _RegisterButton({required this.translations});

  final Translations translations;

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () => Navigator.of(context).pushNamed('/register'),
      child: ThemeTypography.titleMedium(
        context,
        translations.page.login.button_register,
        color: context.colorScheme.primary,
        weight: FontWeight.w700,
      ),
    );
  }
}
