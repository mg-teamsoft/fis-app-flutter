import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;

String guessMime(String path) {
  final p = path.toLowerCase();
  if (p.endsWith('.png')) return 'image/png';
  if (p.endsWith('.webp')) return 'image/webp';
  if (p.endsWith('.heic') || p.endsWith('.heif')) return 'image/heic';
  return 'image/jpeg';
}

/// Convert any image file to JPEG before upload
Future<File> convertToJpeg(File inputFile) async {
  // Read file as bytes
  final Uint8List bytes = await inputFile.readAsBytes();

  // Decode with image package (supports PNG, HEIC, etc. if available)
  final img.Image? original = img.decodeImage(bytes);
  if (original == null) {
    throw Exception("Could not decode image: ${inputFile.path}");
  }

  // Encode to JPEG with quality 90
  final jpegBytes = img.encodeJpg(original, quality: 90);

  // Save into a temp file with .jpg extension
  final jpegFile = File(
    "${inputFile.parent.path}/${DateTime.now().millisecondsSinceEpoch}.jpg",
  );
  await jpegFile.writeAsBytes(jpegBytes, flush: true);

  return jpegFile;
}
