part of '../../page/receipt_manuel_page.dart';

class _ReceiptManuelHelperHint extends StatelessWidget {
  const _ReceiptManuelHelperHint({
    required this.fieldsEnabled,
    required this.isUploading,
  });

  final bool fieldsEnabled;
  final bool isUploading;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (!fieldsEnabled && !isUploading) ...[
          const SizedBox(height: 10),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF4E5),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFFFB347)),
            ),
            child: const Row(
              children: [
                Icon(Icons.info_outline, color: Color(0xFFE67E00), size: 18),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Formu doldurmak için önce fiş görselini yükleyin.',
                    style: TextStyle(
                      color: Color(0xFFE67E00),
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        const SizedBox(height: 20),
      ],
    );
  }
}
