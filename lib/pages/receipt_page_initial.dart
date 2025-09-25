import 'package:flutter/material.dart';
import '../services/receipt_service.dart';

class ReceiptPage extends StatelessWidget {
  const ReceiptPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Fiş Yükleme")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () async {
                final file = await ReceiptService.pickFromGallery(context);
                if (file != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Galeriden seçildi: ${file.path}")),
                  );
                }
              },
              child: const Text("Galeriden Seç"),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () async {
                final file = await ReceiptService.captureWithCamera(context);
                if (file != null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Kameradan çekildi: ${file.path}")),
                  );
                }
              },
              child: const Text("Kamera ile Çek"),
            ),
          ],
        ),
      ),
    );
  }
}