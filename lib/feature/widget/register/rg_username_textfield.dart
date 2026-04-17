part of '../../page/register_page.dart';

final class _RegisterUsernameTextField extends StatelessWidget {
  const _RegisterUsernameTextField({
    required this.controller,
    required this.reqValidator,
  });

  final TextEditingController controller;
  final String? Function(String?)? reqValidator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      style: context.textTheme.bodyLarge?.copyWith(
        color: context.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      decoration: InputDecoration(
        labelText: 'Kullanıcı Adı',
        labelStyle: context.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.w800,
          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        prefixIcon: const Icon(Icons.person),
      ),
      textInputAction: TextInputAction.next,
      validator: reqValidator,
      autofillHints: const [AutofillHints.username],
    );
  }
}
