part of '../../page/reset_password.dart';

final class _ResetPasswordPassConfirmTextfield extends StatelessWidget {
  const _ResetPasswordPassConfirmTextfield(
      {required this.controller, required this.confirmController});

  final TextEditingController controller;
  final TextEditingController confirmController;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: confirmController,
      decoration: const InputDecoration(
        labelText: 'Şifre Tekrar',
        prefixIcon: Icon(Icons.lock),
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
