part of '../../page/register_page.dart';

final class _RegisterMailTextField extends StatelessWidget {
  const _RegisterMailTextField({
    required this.controller,
    required this.mailValidator,
  });

  final TextEditingController controller;
  final String? Function(String?)? mailValidator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: context.textTheme.bodyLarge?.copyWith(
        color: context.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: 'E-posta',
        labelStyle: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        prefixIcon: const Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: mailValidator,
      autofillHints: const [AutofillHints.email],
    );
  }
}
