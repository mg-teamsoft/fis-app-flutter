part of '../../page/login.dart';

final class _UsernameTextField extends StatelessWidget {
  const _UsernameTextField(this.controller);

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: context.textTheme.bodyLarge?.copyWith(
        color: context.colorScheme.onSurface,
        fontWeight: FontWeight.w700,
      ),
      decoration: const InputDecoration(
        labelText: 'Kullanıcı Adınız',
        prefixIcon: Icon(Icons.person, size: ThemeSize.iconLarge),
      ),
      showCursor: true,
    );
  }
}
