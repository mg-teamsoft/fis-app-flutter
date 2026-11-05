import 'dart:io';

import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:fis_app_flutter/feature/page/receipt_result_page.dart';
import 'package:fis_app_flutter/model/receipt_flow_models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

void main() {
  late Directory directory;
  late XFile image;
  setUp(() async {
    directory =
        await Directory.systemTemp.createTemp('receipt_job_review_test');
    final file = await File('${directory.path}/receipt.jpg').writeAsBytes(
      img.encodeJpg(img.Image(width: 100, height: 200)),
    );
    image = XFile(file.path);
  });
  tearDown(() => directory.delete(recursive: true));

  for (final scenario in [
    (
      name: 'true',
      fields: <String, dynamic>{'needsReview': true},
      wrapped: false
    ),
    (
      name: 'false',
      fields: <String, dynamic>{'needsReview': false},
      wrapped: false
    ),
    (
      name: 'null',
      fields: <String, dynamic>{'needsReview': null},
      wrapped: false
    ),
    (name: 'missing', fields: <String, dynamic>{}, wrapped: false),
    (
      name: 'invalid',
      fields: <String, dynamic>{'needsReview': 'false'},
      wrapped: false
    ),
    (
      name: 'nested job',
      fields: <String, dynamic>{'needsReview': true},
      wrapped: true
    ),
  ]) {
    testWidgets('done job handles needsReview ${scenario.name}',
        (tester) async {
      var queries = 0;
      final response = <String, dynamic>{
        'status': 'done',
        ...scenario.fields,
        'receipt': {
          'businessName': 'Test Market',
          'transactionDate': '2026-11-05',
          'totalAmount': 120,
          'vatAmount': 20,
          'vatRate': 20,
        },
      };
      final interceptor = InterceptorsWrapper(
        onRequest: (options, handler) {
          expect(options.path, '/api/job/test-job');
          queries++;
          handler.resolve(
            Response<Map<String, dynamic>>(
              requestOptions: options,
              statusCode: 200,
              data: scenario.wrapped ? {'job': response} : response,
            ),
          );
        },
      );
      ApiClient().dio.interceptors.insert(0, interceptor);
      addTearDown(() => ApiClient().dio.interceptors.remove(interceptor));
      final item = SelectedItem(image)..jobId = 'test-job';
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeApp.light,
          home: PageReceiptResult(items: [item]),
        ),
      );
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 100));
      if (scenario.fields['needsReview'] == false) {
        expect(
          find.textContaining('Fiş bilgilerini kontrol edin'),
          findsNothing,
        );
      } else if (scenario.fields['needsReview'] == true) {
        expect(find.text('Fiş bilgilerini kontrol edin'), findsOneWidget);
      } else {
        expect(
          find.text(
            'Doğrulama durumu bilinmiyor. Fiş bilgilerini kontrol edin.',
          ),
          findsOneWidget,
        );
      }
      // A completed job remains terminal; review is performed in the editor.
      await tester.pump(const Duration(seconds: 20));
      expect(queries, 1);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox());
    });
  }

  testWidgets('background S3 download error is displayed and stops polling',
      (tester) async {
    var queries = 0;
    final interceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        queries++;
        handler.resolve(
          Response<Map<String, dynamic>>(
            requestOptions: options,
            statusCode: 200,
            data: {'status': 'error', 'message': 'S3 indirme başarısız.'},
          ),
        );
      },
    );
    ApiClient().dio.interceptors.insert(0, interceptor);
    addTearDown(() => ApiClient().dio.interceptors.remove(interceptor));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeApp.light,
        home:
            PageReceiptResult(items: [SelectedItem(image)..jobId = 'test-job']),
      ),
    );
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.textContaining('S3 indirme başarısız.'), findsWidgets);
    expect(find.textContaining('Fiş bilgilerini kontrol edin'), findsNothing);
    await tester.pump(const Duration(seconds: 20));
    expect(queries, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });
}
