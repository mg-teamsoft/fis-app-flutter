part of '../../page/connection_page.dart';

class _CnnPermissionChip extends StatelessWidget {
  const _CnnPermissionChip({required this.label, required this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4F7),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: const Color(0xFF667085)),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              color: Color(0xFF667085),
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
