part of '../page/receipt_initial.dart';

class _ReceiptInitialView extends StatelessWidget {
  const _ReceiptInitialView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () async {
              final file = await ReceiptService.pickFromGallery(context);
              if (!context.mounted) return;
              if (file != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                    'Galeriden seçildi: ${file.path}',
                    style: context.textTheme.bodyMedium,
                  )),
                );
              }
            },
            child: Text(
              'Galeriden Seç',
              style: context.textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final file = await ReceiptService.captureWithCamera(context);
              if (!context.mounted) return;
              if (file != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text(
                    'Kameradan çekildi: ${file.path}',
                    style: context.textTheme.bodyMedium,
                  )),
                );
              }
            },
            child: Text(
              'Kamera ile Çek',
              style: context.textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
