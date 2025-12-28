import 'dart:io';
import 'package:dio/dio.dart';
import 'package:fis_app_flutter/models/receipt_flow_models.dart';
import 'package:fis_app_flutter/utils/checksum_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import '../services/s3_upload_service.dart';
import '../services/job_service.dart';
import '../utils/mime_utils.dart';
import 'dart:typed_data';
import 'package:crypto/crypto.dart';

String sha256Hex(Uint8List bytes) =>
    sha256.convert(bytes).toString(); // hex lowercase

class ReceiptProcessPage extends StatefulWidget {
  final List<XFile> files;
  const ReceiptProcessPage({super.key, required this.files});

  @override
  State<ReceiptProcessPage> createState() => _ReceiptProcessPageState();
}

class _ReceiptProcessPageState extends State<ReceiptProcessPage> {
  final _s3 = S3UploadService();
  final _jobs = JobService();
  bool _processing = false;
  final Map<String, Future<Uint8List>> _bytesCache = {};

  Future<void> _process() async {
    setState(() => _processing = true);
    final items = widget.files.map((f) => SelectedItem(f)).toList();

    try {
      for (final item in items) {
        final jpegFile = await convertToJpeg(File(item.file.path));

        final mime = guessMime(jpegFile.path);
        // 1) init
        final bytes = await jpegFile.readAsBytes();
        final checksum = crc32Base64(bytes);
        final sha = sha256Hex(bytes);

        final init = await _s3.initUpload(
          contentType: mime,
          filename: p.basename(jpegFile.path),
          checksumCRC32: checksum,
          sha256: sha,
        );
        item.key = init.key;

        // 2) put to s3
        await _s3.putToS3(
          presignedUrl: init.presignedUrl,
          file: File(item.file.path),
          headers: {
            'Content-Type': 'image/jpeg',
            // Optional but fine to include for clarity:
            // 'x-amz-checksum-crc32': checksum,
          },
        );

        // 3) confirm
        final size = await File(item.file.path).length();
        const maxBytes = 5 * 1024 * 1024;
        const minBytes = 100 * 1024;

        if (size > maxBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Resim en fazla 5 MB olabilir.'),
              ),
            );
          }
          continue;
        } else if (size < minBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('⚠️ Resim en az 100 KB olabilir.'),
              ),
            );
          }
          continue;
        }

        await _s3.confirmUpload(
          key: init.key,
          size: size,
          mime: mime,
          sha256: sha,
        );

        // 4) start processing by key
        item.jobId = await _jobs.startByKey(init.key, mime: mime);
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        '/receipt/results',
        arguments: items,
      );
    } on DioException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.message ?? 'İşlem hatası')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _processing = false);
    }
  }

  @override
  Widget build(BuildContext uildContext) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fişleri İşle')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Expanded(
              child: GridView.builder(
                itemCount: widget.files.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                ),
                itemBuilder: (_, i) {
                  final file = widget.files[i];
                  return ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: kIsWeb
                        ? FutureBuilder<Uint8List>(
                            future: _bytesCache.putIfAbsent(
                              file.path,
                              () => file.readAsBytes(),
                            ),
                            builder: (context, snap) {
                              if (!snap.hasData) {
                                return const Center(
                                    child: CircularProgressIndicator());
                              }
                              return Image.memory(
                                snap.data!,
                                fit: BoxFit.cover,
                              );
                            },
                          )
                        : Image.file(
                            File(file.path),
                            fit: BoxFit.cover,
                          ),
                  );
                },
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _processing ? null : _process,
                icon: _processing
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.play_arrow),
                label: Text(_processing ? 'İşleniyor...' : 'İşle'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
