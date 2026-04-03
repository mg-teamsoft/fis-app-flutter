part of '../../page/register.dart';

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
      decoration: const InputDecoration(
        labelText: 'Kullanıcı Adı',
        prefixIcon: Icon(Icons.person),
      ),
      textInputAction: TextInputAction.next,
      validator: reqValidator,
      autofillHints: const [AutofillHints.username],
    );
  }
}
