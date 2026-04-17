part of '../../page/login_page.dart';

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
      decoration: InputDecoration(
        labelText: 'Kullanıcı Adınız',
        labelStyle: context.textTheme.bodyLarge?.copyWith(
          color: context.colorScheme.onSurface.withValues(alpha: 0.5),
        ),
        prefixIcon: const Icon(Icons.person, size: ThemeSize.iconLarge),
      ),
      showCursor: true,
    );
  }
}
