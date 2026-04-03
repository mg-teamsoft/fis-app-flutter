part of '../../page/forget_password.dart';

final class _ForgotPasswordTextField extends StatelessWidget {
  const _ForgotPasswordTextField({
    required this.controller,
    required this.submit,
  });

  final TextEditingController controller;
  final Future<void> Function() submit;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'E-posta',
        prefixIcon: Icon(Icons.email_outlined),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.done,
      validator: (value) {
        if (value == null || value.trim().isEmpty) {
          return 'E-posta gerekli';
        }
        final email = value.trim();
        final reg = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
        if (!reg.hasMatch(email)) {
          return 'Geçerli bir e-posta girin';
        }
        return null;
      },
      onFieldSubmitted: (_) => submit(),
    );
  }
}
