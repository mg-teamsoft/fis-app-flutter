part of '../../page/reset_password_page.dart';

final class _ResetPasswordError extends StatelessWidget {
  const _ResetPasswordError({this.status, this.error});

  final String? status;
  final String? error;

  @override
  Widget build(BuildContext context) {
    if (status != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ThemeTypography.bodySmall(
          context,
          status!,
          color: context.colorScheme.primary,
        ),
      );
    }
    if (error != null) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: ThemeTypography.bodySmall(
          context,
          error!,
          color: context.colorScheme.error,
        ),
      );
    }
    return const SizedBox.shrink();
  }
}
