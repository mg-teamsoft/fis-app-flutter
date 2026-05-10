part of '../../page/receipt_manuel_page.dart';

class _DropdownFieldBox extends StatelessWidget {
  const _DropdownFieldBox({
    required this.value,
    required this.hintText,
    required this.items,
    required this.onChanged,
    this.validator,
  });

  final String? value;
  final String hintText;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      validator: validator,
      items: items
          .map(
            (item) => DropdownMenuItem<String>(
              value: item,
              child: ThemeTypography.bodyMedium(
                context,
                '%$item',
                color: context.colorScheme.onSurface,
              ),
            ),
          )
          .toList(),
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: context.colorScheme.surfaceContainer,
        contentPadding: const ThemePadding.horizontalSymmetricMedium(),
        border: OutlineInputBorder(
          borderRadius: ThemeRadius.circular16,
          borderSide: BorderSide(color: context.colorScheme.surface),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: ThemeRadius.circular16,
          borderSide: BorderSide(color: context.colorScheme.surface),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: ThemeRadius.circular16,
          borderSide:
              BorderSide(color: context.colorScheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: ThemeRadius.circular16,
          borderSide: BorderSide(color: context.colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: ThemeRadius.circular16,
          borderSide: BorderSide(color: context.colorScheme.error),
        ),
      ),
      icon: Icon(
        Icons.keyboard_arrow_down_rounded,
        color: context.colorScheme.onSurface,
      ),
      dropdownColor: context.colorScheme.surface,
    );
  }
}
