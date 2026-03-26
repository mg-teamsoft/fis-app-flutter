part of '../../page/register.dart';

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
      decoration: const InputDecoration(
        labelText: 'E-posta',
        prefixIcon: Icon(Icons.email),
      ),
      keyboardType: TextInputType.emailAddress,
      textInputAction: TextInputAction.next,
      validator: mailValidator,
      autofillHints: const [AutofillHints.email],
    );
  }
}
