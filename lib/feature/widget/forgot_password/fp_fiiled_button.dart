part of '../../page/forget_password_page.dart';

final class _ForgotPasswordFiiledButton extends StatelessWidget {
  const _ForgotPasswordFiiledButton({
    required this.loading,
    required this.submit,
  });
  final bool loading;
  final VoidCallback submit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : submit,
        style: FilledButton.styleFrom(
          backgroundColor: context.colorScheme.primary,
          foregroundColor: context.colorScheme.surface,
          padding: const EdgeInsets.symmetric(
            vertical: ThemeSize.spacingM,
            horizontal: ThemeSize.spacingL,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: ThemeRadius.circular12,
          ),
        ),
        child: loading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : ThemeTypography.titleMedium(
                context,
                'Sıfırlama Maili Gönder',
                color: context.colorScheme.surface,
                weight: FontWeight.w700,
              ),
      ),
    );
  }
}
