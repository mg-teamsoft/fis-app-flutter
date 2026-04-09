part of '../../page/reset_password_page.dart';

final class _ResetPasswordFilledButton extends StatelessWidget {
  const _ResetPasswordFilledButton({
    required this.submitting,
    required this.submit,
  });

  final bool submitting;
  final Future<void> Function() submit;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: submitting ? null : submit,
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: ThemeRadius.circular8),
          padding: const ThemePadding.all10(),
          minimumSize: const Size(120, 40),
        ),
        child: submitting
            ? const SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : ThemeTypography.bodyMedium(
                context,
                'Şifreyi Sıfırla',
                color: context.colorScheme.surface,
              ),
      ),
    );
  }
}
