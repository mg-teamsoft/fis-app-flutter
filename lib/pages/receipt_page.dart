import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/receipt_service.dart';
import 'receipt_process_page.dart';

class ReceiptPage extends StatefulWidget {
  const ReceiptPage({super.key});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  final _picker = ImagePicker();
  List<XFile> _picked = [];

  Future<void> _pickMultiGallery() async {
    final files = await _picker.pickMultiImage(imageQuality: 90);
    if (!mounted) return;
    setState(() => _picked = files);
    if (_picked.isNotEmpty) {
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ReceiptProcessPage(files: _picked),
      ));
    }
  }

  Future<void> _captureCamera() async {
    final file = await ReceiptService.captureWithCamera(context);
    if (!mounted) return;
    if (file != null) {
      setState(() => _picked = [file]);
      Navigator.push(context, MaterialPageRoute(
        builder: (_) => ReceiptProcessPage(files: _picked),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fiş Seç')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _pickMultiGallery,
                    icon: const Icon(Icons.photo_library),
                    label: const Text('Galeriden Seç (çoklu)'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _captureCamera,
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Kamerayla Çek'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _picked.isEmpty
                  ? const Center(child: Text('Henüz seçim yapılmadı'))
                  : GridView.builder(
                      itemCount: _picked.length,
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3, mainAxisSpacing: 8, crossAxisSpacing: 8),
                      itemBuilder: (_, i) => ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.file(File(_picked[i].path), fit: BoxFit.cover),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}