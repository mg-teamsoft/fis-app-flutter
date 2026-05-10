part of '../page/receipt_initial_page.dart';

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
                    content: ThemeTypography.bodyMedium(
                      context,
                      'Galeriden seçildi: ${file.path}',
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                );
              }
            },
            child: ThemeTypography.bodyMedium(
              context,
              'Galeriden Seç',
              color: context.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: ThemeSize.spacingM),
          ElevatedButton(
            onPressed: () async {
              final file = await ReceiptService.captureWithCamera(context);
              if (!context.mounted) return;
              if (file != null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: ThemeTypography.bodyMedium(
                      context,
                      'Kameradan çekildi: ${file.path}',
                      color: context.colorScheme.onSurface,
                    ),
                  ),
                );
              }
            },
            child: ThemeTypography.bodyMedium(
              context,
              'Kamera ile Çek',
              color: context.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
