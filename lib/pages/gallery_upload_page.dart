import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import '../services/receipt_service.dart';
import '../services/upload_service.dart';

class GalleryUploadPage extends StatefulWidget {
  const GalleryUploadPage({super.key});

  @override
  State<GalleryUploadPage> createState() => _GalleryUploadPageState();
}

class _GalleryUploadPageState extends State<GalleryUploadPage> {
  XFile? _picked;
  Uint8List? _pickedBytes;
  bool _uploading = false;
  final _uploader = UploadService();

  Future<void> _pick() async {
    final file = await ReceiptService.pickFromGallery(context);
    Uint8List? bytes;

    if (kIsWeb && file != null) {
      bytes = await file.readAsBytes();
    }

    if (!mounted) return;
    setState(() {
      _picked = file;
      _pickedBytes = bytes;
    });
    if (file == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Herhangi bir görsel seçilmedi')),
      );
    }
  }

  Future<void> _upload() async {
    if (_picked == null) return;
    setState(() => _uploading = true);

    final res = await _uploader.uploadReceiptImage(_picked!);

    if (!mounted) return;
    setState(() => _uploading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(res.message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final img = _picked != null
        ? kIsWeb
            ? (_pickedBytes != null ? Image.memory(_pickedBytes!) : null)
            : Image.file(File(_picked!.path))
        : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Galeriden Yükle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            FilledButton.icon(
              onPressed: _uploading ? null : _pick,
              icon: const Icon(Icons.photo_library),
              label: const Text('Galeriden Seç'),
            ),
            const SizedBox(height: 16),
            if (img != null)
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: img,
                ),
              )
            else
              const Expanded(
                child: Center(child: Text('Önizleme için bir fotoğraf seçin')),
              ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (_picked == null || _uploading) ? null : _upload,
                icon: _uploading
                    ? const SizedBox(
                        height: 18, width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.cloud_upload),
                label: Text(_uploading ? 'Yükleniyor...' : 'Yükle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
