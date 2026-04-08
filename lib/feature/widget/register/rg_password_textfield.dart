part of '../../page/register_page.dart';

final class _RegisterPasswordTextField extends StatefulWidget {
  const _RegisterPasswordTextField({
    required this.controller,
    required this.passValidator,
    required this.onPressed,
    this.obscure = true,
  });

  final TextEditingController controller;
  final String? Function(String?)? passValidator;
  final bool obscure;
  final VoidCallback? onPressed;

  @override
  State<_RegisterPasswordTextField> createState() =>
      __RegisterPasswordTextFieldState();
}

class __RegisterPasswordTextFieldState
    extends State<_RegisterPasswordTextField> {
  bool _obscure = true;
  @override
  void initState() {
    super.initState();
    _obscure = widget.obscure;
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: widget.controller,
      style: context.textTheme.bodyLarge?.copyWith(
        color: context.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: 'Şifre',
        labelStyle: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        prefixIcon: const Icon(Icons.lock),
        suffixIcon: IconButton(
          icon: Icon(_obscure ? Icons.visibility : Icons.visibility_off),
          onPressed: () => setState(() => _obscure = !_obscure),
        ),
      ),
      obscureText: _obscure,
      validator: widget.passValidator,
      onFieldSubmitted: (_) => widget.onPressed?.call(),
      autofillHints: const [AutofillHints.newPassword],
    );
  }
}
