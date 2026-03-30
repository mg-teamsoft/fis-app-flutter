part of '../../page/receipt_table.dart';

InputDecoration _input_Decoration(String hint, {String? errorText}) =>
    InputDecoration(
      hintText: hint,
      errorText: errorText,
      isDense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: errorText != null
            ? const BorderSide(color: Color(0xFFD32F2F), width: 1.5)
            : BorderSide.none,
      ),
      filled: false,
    );
