part of '../../page/receipt_table_page.dart';

InputDecoration _inputDecoration(
  BuildContext context,
  String hint, {
  String? errorText,
}) =>
    InputDecoration(
      hintText: hint,
      errorText: errorText,
      isDense: true,
      contentPadding: const ThemePadding.verticalSymmetricSmall(),
      border: OutlineInputBorder(
        borderRadius: ThemeRadius.circular8,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: ThemeRadius.circular8,
        borderSide: errorText != null
            ? BorderSide(color: context.theme.error, width: 1.5)
            : BorderSide.none,
      ),
      filled: false,
    );
