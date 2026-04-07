part of '../../page/reset_password_page.dart';

final class _ResetPasswordPassConfirmTextfield extends StatelessWidget {
  const _ResetPasswordPassConfirmTextfield({
    required this.controller,
    required this.confirmController,
  });

  final TextEditingController controller;
  final TextEditingController confirmController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: confirmController,
      style: context.textTheme.bodyLarge?.copyWith(
        color: context.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: 'Şifre Tekrar',
        labelStyle: context.textTheme.bodyLarge?.copyWith(
          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        prefixIcon: const Icon(Icons.lock),
      ),
      obscureText: true,
      validator: (v) {
        if (v != controller.text) {
          return 'Şifreler eşleşmiyor';
        }
        return null;
      },
    );
  }
}
