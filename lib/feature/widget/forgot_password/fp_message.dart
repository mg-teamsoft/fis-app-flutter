part of '../../page/forget_password_page.dart';

final class _ForgotPasswordMessage extends StatelessWidget {
  const _ForgotPasswordMessage({
    required this.statusMessage,
    required this.errorMessage,
  });
  final String? statusMessage;
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return (statusMessage != null)
        ? Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: ThemeTypography.bodySmall(
              context,
              statusMessage!,
              color: context.colorScheme.primary,
            ),
          )
        : (errorMessage != null)
            ? Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: ThemeTypography.bodySmall(
                  context,
                  errorMessage!,
                  color: context.colorScheme.error,
                ),
              )
            : const SizedBox.shrink();
  }
}
