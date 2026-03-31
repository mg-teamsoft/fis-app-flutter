part of '../../page/account_settings.dart';

class _AccountSettingsSectionTitle extends StatelessWidget {
  const _AccountSettingsSectionTitle({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text.toUpperCase(),
      style: const TextStyle(
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
        fontSize: 14,
        color: Color(0xFF475467),
      ),
    );
  }
}
