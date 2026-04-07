part of '../../page/receipt_process_page.dart';

class _ReceiptProcessFilledButton extends StatelessWidget {
  const _ReceiptProcessFilledButton({
    required this.processing,
    required this.process,
  });

  final bool processing;
  final VoidCallback process;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton.icon(
        onPressed: processing ? null : process,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          textStyle: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: processing
            ? const SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.play_arrow),
        label: Text(processing ? 'İşleniyor...' : 'İşle'),
      ),
    );
  }
}
