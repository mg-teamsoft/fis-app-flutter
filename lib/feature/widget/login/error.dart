part of '../../page/login.dart';

final class _LoginErrorText extends StatelessWidget {
  const _LoginErrorText({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Text(
      message,
      style: context.textTheme.bodySmall,
    );
  }
}
