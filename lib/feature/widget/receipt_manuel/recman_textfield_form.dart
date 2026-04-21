part of '../../page/receipt_manuel_page.dart';

class _TextFieldBox extends StatelessWidget {
  const _TextFieldBox({
    required this.controller,
    required this.hintText,
    this.validator,
    this.prefixText,
    this.keyboardType,
    this.inputFormatters,
    this.textAlign = TextAlign.left,
    this.readOnly = false,
    this.fillColor,
  });

  final TextEditingController controller;
  final String hintText;
  final String? Function(String?)? validator;
  final String? prefixText;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final TextAlign textAlign;
  final bool readOnly;
  final Color? fillColor;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      validator: validator,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      textAlign: textAlign,
      readOnly: readOnly,
      decoration: InputDecoration(
        hintText: hintText,
        prefixText: prefixText,
        filled: true,
        fillColor: fillColor ?? context.colorScheme.surface,
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
          borderSide: BorderSide(color: context.theme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: ThemeRadius.circular16,
          borderSide: BorderSide(color: context.theme.error),
        ),
      ),
    );
  }
}
