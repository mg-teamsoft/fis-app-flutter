part of '../../page/receipt_manuel_page.dart';

/// ATM-style currency formatter: digits push in from the right of a fixed
/// decimal point (2 decimal places). The dot is never user-editable.
class _CurrencyInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    // Extract only digit characters from whatever was typed
    final digits = newValue.text.replaceAll(RegExp('[^0-9]'), '');

    if (digits.isEmpty) {
      return newValue.copyWith(
        text: '0.00',
        selection: const TextSelection.collapsed(offset: 4),
      );
    }

    // Max 10 digits (99 999 999.99)
    final trimmed =
        digits.length > 10 ? digits.substring(digits.length - 10) : digits;

    // Pad to at least 3 digits so we always have X.XX
    final padded = trimmed.padLeft(3, '0');

    // Split into integer and decimal parts
    final intRaw = padded.substring(0, padded.length - 2);
    final decPart = padded.substring(padded.length - 2);

    // Strip leading zeros from integer part, keep at least one digit
    final intPart = intRaw.replaceFirst(RegExp('^0+'), '').isEmpty
        ? '0'
        : intRaw.replaceFirst(RegExp('^0+'), '');

    final result = '$intPart.$decPart';
    return newValue.copyWith(
      text: result,
      selection: TextSelection.collapsed(offset: result.length),
    );
  }
}
