part of '../../page/receipt_manuel.dart';

class _DateFieldBox extends StatelessWidget {
  const _DateFieldBox({
    required this.value,
    required this.onTap,
    this.hasError = false,
  });

  final String value;
  final VoidCallback onTap;
  final bool hasError;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Ink(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasError ? const Color(0xFFF04438) : const Color(0xFFD0D5DD),
          ),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? 'gg/aa/yyyy' : value,
                style: TextStyle(
                  color: value.isEmpty
                      ? const Color(0xFF98A2B3)
                      : const Color(0xFF101828),
                  fontSize: 16,
                ),
              ),
            ),
            const Icon(Icons.calendar_today_outlined, size: 20),
          ],
        ),
      ),
    );
  }
}
