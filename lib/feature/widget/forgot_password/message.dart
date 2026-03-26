part of '../../page/forget_password.dart';

final class _ForgotPasswordMessage extends StatelessWidget {
  const _ForgotPasswordMessage(
      {required this.statusMessage, required this.errorMessage});
  final String? statusMessage;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return (statusMessage != null)
        ? Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              statusMessage!,
              style: context.textTheme.bodySmall?.copyWith(
                color: context.colorScheme.primary,
              ),
            ),
          )
        : (errorMessage != null)
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(
                  errorMessage!,
                  style: context.textTheme.bodySmall?.copyWith(
                    color: context.colorScheme.error,
                  ),
                ),
              )
            : const SizedBox.shrink();
  }
}
