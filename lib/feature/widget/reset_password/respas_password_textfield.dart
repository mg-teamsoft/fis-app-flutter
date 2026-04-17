part of '../../page/reset_password_page.dart';

final class _ResetPasswordPassTextfield extends StatelessWidget {
  const _ResetPasswordPassTextfield({
    required this.controller,
  });

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: context.textTheme.bodyLarge?.copyWith(
        color: context.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelStyle: context.textTheme.bodyLarge?.copyWith(
          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        labelText: 'Yeni Şifre',
        prefixIcon: const Icon(Icons.lock_outline),
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
