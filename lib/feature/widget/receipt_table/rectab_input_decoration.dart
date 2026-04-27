part of '../../page/receipt_table_page.dart';

InputDecoration _inputDecoration(
  BuildContext context,
  String hint, {
  required bool isError,
  String? errorText,
}) =>
    InputDecoration(
      hintText: hint,
      errorText: errorText,
      isDense: true,
      contentPadding: const ThemePadding.verticalSymmetricSmall(),
      border: OutlineInputBorder(
        borderRadius: ThemeRadius.circular8,
        borderSide: isError
            ? BorderSide(color: context.theme.warning, width: 1.5)
            : BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: ThemeRadius.circular8,
        borderSide: isError
            ? BorderSide(color: context.theme.error, width: 1.5)
            : BorderSide.none,
      ),
      filled: false,
    );
