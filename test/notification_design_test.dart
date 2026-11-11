import 'package:dio/dio.dart';
import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/services/api_client.dart';
import 'package:fis_app_flutter/feature/page/notification_page.dart';
import 'package:fis_app_flutter/model/notification_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('optional notification metadata survives mapping and read updates', () {
    final original = NotificationModel.fromJson({
      'id': 'campaign',
      'category': 'campaign',
      'version': '1.2.2',
      'endDate': '2026-12-01T12:00:00Z',
      'isUnread': true,
    });
    final read = original.copyWith(isUnread: false);
    final restored = NotificationModel.fromJson(read.toMap());
    expect(restored.category, 'campaign');
    expect(restored.version, '1.2.2');
    expect(restored.endDate, DateTime.utc(2026, 12, 1, 12));
    expect(restored.isUnread, isFalse);
    expect(NotificationModel.fromJson({}).endDate, isNull);
    expect(NotificationModel.fromJson({'endDate': 'invalid'}).endDate, isNull);
  });

  testWidgets('notification cards fit narrow screens and mark read once',
      (tester) async {
    tester.view.physicalSize = const Size(320, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    var reads = 0;
    final interceptor = InterceptorsWrapper(
      onRequest: (options, handler) {
        if (options.path == '/api/notifications/read') {
          reads++;
          handler.resolve(
            Response<dynamic>(
              requestOptions: options,
              statusCode: 204,
            ),
          );
          return;
        }
        handler.resolve(
          Response<dynamic>(
            requestOptions: options,
            statusCode: 200,
            data: [
              {
                'id': 'one',
                'title': 'Yeni sürüm yayında',
                'subtitle': 'Fiş yükleme iyileştirildi.',
                'content': 'Tüm açıklamalar bu kartın içinde gösterilir.',
                'category': 'version',
                'version': 'v1.2.2',
                'time': 'Az önce',
                'isUnread': true,
              },
              {
                'id': 'two',
                'title': 'Kampanya',
                'category': 'campaign',
                'endDate': DateTime.now()
                    .add(const Duration(days: 3))
                    .toIso8601String(),
              },
              {'id': 'three', 'title': 'Genel duyuru'},
            ],
          ),
        );
      },
    );
    ApiClient().dio.interceptors.insert(0, interceptor);
    addTearDown(() => ApiClient().dio.interceptors.remove(interceptor));
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeApp.light,
        home: const Scaffold(body: PageNotification()),
      ),
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pumpAndSettle();
    expect(find.text('Bildirimler'), findsOneWidget);
    expect(find.text('Sürüm Güncelleme'), findsOneWidget);
    expect(find.text('v1.2.2'), findsOneWidget);
    expect(find.textContaining('Kalan süre:'), findsOneWidget);
    expect(find.text('Tümünü Oku'), findsNothing);
    expect(find.text('Detayları Gör'), findsOneWidget);
    const detail = 'Tüm açıklamalar bu kartın içinde gösterilir.';
    expect(find.text(detail), findsNothing);
    await tester.tap(find.text('Detayları Gör'));
    await tester.pump();
    expect(find.text(detail), findsOneWidget);
    expect(find.text('Fiş yükleme iyileştirildi.'), findsOneWidget);
    expect(reads, 0);
    await tester.tap(find.text('Detayları Gizle'));
    await tester.pump();
    expect(find.text(detail), findsNothing);
    expect(tester.takeException(), isNull);
    await tester.runAsync(() async {
      await tester.tap(find.text('Yeni sürüm yayında'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    await tester.pumpAndSettle();
    expect(reads, 1);
    await tester.runAsync(() => tester.tap(find.text('Yeni sürüm yayında')));
    await tester.pumpAndSettle();
    expect(reads, 1);
    await tester.pumpWidget(const SizedBox());
  });
}
