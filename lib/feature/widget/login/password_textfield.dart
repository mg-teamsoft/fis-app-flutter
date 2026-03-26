part of '../../page/login.dart';

final class _PasswordTextField extends StatelessWidget {
  _PasswordTextField({required this.controller, required this.onPressed});

  final TextEditingController controller;
  final ValueNotifier<bool> _obscureNotifier = ValueNotifier<bool>(true);
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: _obscureNotifier,
      builder: (context, isObscure, child) {
        return TextField(
          controller: controller,
          obscureText: isObscure,
          style: context.textTheme.bodyLarge?.copyWith(
              color: context.colorScheme.onSurface,
              fontWeight: FontWeight.w700),
          decoration: InputDecoration(
            labelText: 'Şifreniz',
            prefixIcon: const Icon(Icons.lock, size: ThemeSize.iconLarge),
            suffixIcon: IconButton(
              icon: Icon(isObscure ? Icons.visibility : Icons.visibility_off),
              onPressed: () => _obscureNotifier.value = !_obscureNotifier.value,
            ),
          ),
          onEditingComplete: onPressed,
          showCursor: true,
        );
      },
    );
  }
}
