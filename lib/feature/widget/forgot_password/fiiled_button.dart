part of '../../page/forget_password.dart';

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
        child: loading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(
                'Sıfırlama Maili Gönder',
                style: context.textTheme.titleLarge,
              ),
      ),
    );
  }
}
