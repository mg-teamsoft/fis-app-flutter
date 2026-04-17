part of '../../page/receipt_manuel_page.dart';

class _FieldLabel extends StatelessWidget {
  const _FieldLabel(this.text)
      : main = null,
        suffix = null;

  const _FieldLabel.rich({
    required this.main,
    required this.suffix,
  }) : text = null;

  final String? text;
  final String? main;
  final String? suffix;

  @override
  Widget build(BuildContext context) {
    if (text != null) {
      return Text(
        text!,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF101828),
        ),
      );
    }

    return RichText(
      text: TextSpan(
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Color(0xFF101828),
        ),
        children: [
          TextSpan(text: main),
          TextSpan(
            text: suffix,
            style: const TextStyle(
              fontWeight: FontWeight.w400,
              color: Color(0xFF98A2B3),
            ),
          ),
        ],
      ),
    );
  }
}
