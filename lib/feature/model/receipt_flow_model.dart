import 'package:image_picker/image_picker.dart';

final class ModelReceiptFlow {
  // OCR/parse result
  ModelReceiptFlow(this.file);
  final XFile file;
  String? key; // S3 object key after init
  String? jobId; // backend job id after start
  String? imageUrl; // public S3 image URL after upload
  Map<String, dynamic>? result;
}
