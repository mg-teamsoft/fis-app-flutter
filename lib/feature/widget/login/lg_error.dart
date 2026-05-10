part of '../../page/login_page.dart';

final class _LoginErrorText extends StatelessWidget {
  const _LoginErrorText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ThemeTypography.bodySmall(
      context,
      message,
      color: context.colorScheme.error,
    );
  }
}
