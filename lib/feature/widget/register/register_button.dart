part of '../../page/register.dart';

final class _RegisterButton extends StatelessWidget {
  const _RegisterButton({
    required this.loading,
    required this.onPressed,
  });

  final bool loading;
  final void Function()? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: loading ? null : onPressed,
        child: loading
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Text('Kayıt Ol'),
      ),
    );
  }
}
