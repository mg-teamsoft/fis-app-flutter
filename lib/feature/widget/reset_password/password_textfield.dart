part of '../../page/reset_password.dart';

final class _ResetPasswordPassTextfield extends StatelessWidget {
  const _ResetPasswordPassTextfield({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: const InputDecoration(
        labelText: 'Yeni Şifre',
        prefixIcon: Icon(Icons.lock_outline),
      ),
      obscureText: true,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Şifre gerekli';
        if (v.length < 8) return 'En az 8 karakter olmalı';
        return null;
      },
    );
  }
}
