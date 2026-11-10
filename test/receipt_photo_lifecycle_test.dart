import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:fis_app_flutter/feature/page/receipt_result_page.dart';
import 'package:fis_app_flutter/model/receipt_flow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';
import 'package:photo_view/photo_view.dart';

void main() {
  late Directory directory;
  late List<SelectedItem> items;
  late Interceptor interceptor;

  setUp(() async {
    directory =
        await Directory.systemTemp.createTemp('receipt_photo_lifecycle');
    final file = await File('${directory.path}/receipt.jpg').writeAsBytes(
      img.encodeJpg(img.Image(width: 100, height: 200)),
    );
    items = List.generate(
      2,
      (i) => SelectedItem(XFile(file.path))..jobId = 'job-$i',
    );
    interceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        handler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: 200,
            data: {
              'status': 'done',
              'needsReview': false,
              'receipt': {'businessName': 'Test Market', 'totalAmount': 120},
            },
          ),
        );
      },
    );
    ApiClient().dio.interceptors.insert(0, interceptor);
  });
  tearDown(() async {
    ApiClient().dio.interceptors.remove(interceptor);
    await directory.delete(recursive: true);
  });

  Future<void> showResults(WidgetTester tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(900, 1800);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final recorder = ui.PictureRecorder();
    Canvas(recorder).drawColor(Colors.white, BlendMode.src);
    final picture = recorder.endRecording();
    final pixels = picture.toImageSync(100, 200);
    picture.dispose();
    PaintingBinding.instance.imageCache.putIfAbsent(
      FileImage(File(items.first.file.path)),
      () => OneFrameImageStreamCompleter(
        Future<ImageInfo>.value(ImageInfo(image: pixels)),
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeApp.light,
        home: PageReceiptResult(items: items),
      ),
    );
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    await tester.pump();
    expect(find.byType(PhotoView), findsNWidgets(2));
    expect(
      find.byWidgetPredicate(
        (widget) => widget.runtimeType.toString() == 'PhotoViewCore',
      ),
      findsNWidgets(2),
    );
  }

  testWidgets('valid receipts write while invalid receipts remain selectable',
      (tester) async {
    ApiClient().dio.interceptors.remove(interceptor);
    var writes = 0;
    for (final item in items) {
      item.key = item.jobId;
    }
    interceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        final writing = options.path == '/api/excel/write';
        if (writing) writes++;
        handler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: 200,
            data: writing
                ? {'status': 'success'}
                : {
                    'status': 'done',
                    'needsReview': false,
                    'receipt': {
                      'businessName': 'Test Market',
                      'transactionDate': '2026-11-10',
                      'totalAmount': 120,
                      'vatAmount': options.path.endsWith('job-0') ? 0 : 20,
                      'vatRate': 20,
                    },
                  },
          ),
        );
      },
    );
    ApiClient().dio.interceptors.insert(0, interceptor);
    await showResults(tester);
    await tester.pump(const Duration(seconds: 1));
    final approve = find.text("Onayla ve Excel'e Yaz");
    await tester.ensureVisible(approve);
    await tester.runAsync(() => tester.tap(approve));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();
    await tester.pump();
    expect(writes, 1);
    expect(find.byType(PhotoView), findsOneWidget);
    expect(find.byType(Checkbox), findsOneWidget);
    await tester.ensureVisible(find.byType(Checkbox));
    await tester.tap(find.byType(Checkbox));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox)).value, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('receipt selection can be toggled off and on', (tester) async {
    await showResults(tester);
    final checkbox = find.byType(Checkbox).first;
    expect(tester.widget<Checkbox>(checkbox).value, isTrue);
    await tester.tap(checkbox);
    await tester.pump();
    expect(tester.widget<Checkbox>(checkbox).value, isFalse);
    await tester.tap(checkbox);
    await tester.pump();
    expect(tester.widget<Checkbox>(checkbox).value, isTrue);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets(
      'removing first and last receipts safely detaches photo listeners',
      (tester) async {
    await showResults(tester);
    final secondController =
        tester.widgetList<PhotoView>(find.byType(PhotoView)).last.controller;
    await tester.tap(find.byTooltip('Sil').first);
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(find.byType(PhotoView), findsOneWidget);
    expect(
      tester.widget<PhotoView>(find.byType(PhotoView)).controller,
      same(secondController),
    );
    await tester.tap(find.byTooltip('Döndür'));
    await tester.pump();
    expect(secondController!.rotation, closeTo(math.pi / 2, 0.001));
    expect(tester.takeException(), isNull);
    await tester.tap(find.byTooltip('Sil'));
    await tester.pump();
    expect(find.byType(PhotoView), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('closing the result page safely releases photo controllers',
      (tester) async {
    await showResults(tester);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
      'removing a receipt while its job query is pending ignores the late response',
      (tester) async {
    ApiClient().dio.interceptors.remove(interceptor);
    RequestInterceptorHandler? pending;
    RequestOptions? pendingOptions;
    var secondPolled = false;
    interceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path.endsWith('job-0')) {
          pending = handler;
          pendingOptions = options;
        } else {
          secondPolled = true;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: {
                'status': 'done',
                'needsReview': false,
                'receipt': {'businessName': 'Remaining receipt'},
              },
            ),
          );
        }
      },
    );
    ApiClient().dio.interceptors.insert(0, interceptor);
    await showResults(tester);
    expect(pending, isNotNull);
    await tester.tap(find.byTooltip('Sil').first);
    await tester.pump();
    pending!.resolve(
      Response<Map<String, dynamic>>(
        requestOptions: pendingOptions!,
        statusCode: 200,
        data: {
          'status': 'done',
          'receipt': {'businessName': 'Removed receipt'},
        },
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
    expect(secondPolled, isTrue);
    expect(find.byType(PhotoView), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
