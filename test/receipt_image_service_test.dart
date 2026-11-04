import 'dart:io';

import 'package:fis_app_flutter/app/services/receipt_image_service.dart';
import 'package:flutter/services.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;

class _Compressor extends FlutterImageCompressPlatform {
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);

  int? width;
  int? height;
  int? requestedQuality;
  CompressFormat? requestedFormat;
  Uint8List output =
      Uint8List.fromList(img.encodeJpg(img.Image(width: 1, height: 1)));

  @override
  Future<Uint8List> compressWithList(
    Uint8List image, {
    int minWidth = 1920,
    int minHeight = 1080,
    int quality = 95,
    int rotate = 0,
    int inSampleSize = 1,
    bool autoCorrectionAngle = true,
    CompressFormat format = CompressFormat.jpeg,
    bool keepExif = false,
  }) async {
    width = minWidth;
    height = minHeight;
    requestedQuality = quality;
    requestedFormat = format;
    return output;
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Compressor compressor;
  late Directory directory;
  final original = FlutterImageCompressPlatform.instance;

  setUp(() async {
    compressor = _Compressor();
    FlutterImageCompressPlatform.instance = compressor;
    directory = await Directory.systemTemp.createTemp('receipt_resize_test');
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => directory.path,
    );
  });

  tearDown(() async {
    FlutterImageCompressPlatform.instance = original;
    await directory.delete(recursive: true);
  });

  for (final dimensions in [
    [4000, 3000, 2560, 1920],
    [3000, 4000, 1920, 2560],
    [4000, 1000, 2560, 640],
    [640, 480, 640, 480],
    [2560, 2560, 2560, 2560],
  ]) {
    test('fits ${dimensions[0]}x${dimensions[1]} without enlarging', () async {
      final source = XFile.fromData(
        Uint8List.fromList(
          img.encodePng(
            img.Image(width: dimensions[0], height: dimensions[1]),
          ),
        ),
        name: 'receipt.png',
      );
      final input = File('${directory.path}/receipt.png');
      await input.writeAsBytes(await source.readAsBytes());
      final result = await ReceiptImageService.prepare(XFile(input.path));
      expect(compressor.width, dimensions[2]);
      expect(compressor.height, dimensions[3]);
      expect(compressor.requestedQuality, 88);
      expect(compressor.requestedFormat, CompressFormat.jpeg);
      expect(result.name, endsWith('_receipt.jpg'));
      expect(result.mimeType, 'image/jpeg');
      expect(await result.readAsBytes(), compressor.output);
    });
  }

  test('rejects a non-JPEG encoder fallback', () async {
    compressor.output = Uint8List(20);
    final source = XFile.fromData(
      Uint8List.fromList(img.encodePng(img.Image(width: 10, height: 10))),
      name: 'receipt.png',
    );
    await expectLater(ReceiptImageService.prepare(source), throwsException);
  });
}
