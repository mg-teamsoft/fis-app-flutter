import 'dart:io';

import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/feature/page/receipt_page.dart';
import 'package:fis_app_flutter/feature/page/receipt_process_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:image_picker/image_picker.dart';

void main() {
  testWidgets(
      'review scrolls through 20 thumbnails, previews and removes images',
      (tester) async {
    final directory = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('receipt_review_test'),
    ))!;
    addTearDown(() => directory.delete(recursive: true));
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(
      const MethodChannel('plugins.flutter.io/path_provider'),
      (_) async => directory.path,
    );
    final bytes = img.encodeJpg(img.Image(width: 100, height: 200));
    final files = <XFile>[];
    await tester.runAsync(() async {
      for (var i = 0; i < 20; i++) {
        final file = await File('${directory.path}/$i.jpg').writeAsBytes(bytes);
        files.add(XFile(file.path));
      }
    });
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeApp.light,
        home: PageReceiptProcess(files: files),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Onayla ve işle'), findsOneWidget);
    expect(tester.takeException(), isNull);
    final thumbnail = tester.widget<Image>(find.byType(Image).first);
    final provider = thumbnail.image as ResizeImage;
    expect(provider.width, 480);
    expect(provider.height, 480);
    expect(provider.policy, ResizeImagePolicy.fit);
    await tester.tap(find.byType(Image).first);
    await tester.pumpAndSettle();
    expect(find.byType(InteractiveViewer), findsOneWidget);
    await tester.tap(find.byTooltip('Kapat'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Görseli çıkar').first);
    await tester.pumpAndSettle();
    final grid = tester.widget<GridView>(find.byType(GridView));
    expect(grid.childrenDelegate.estimatedChildCount, 19);
    await tester.drag(find.byType(GridView), const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('confirmation is disabled when the review is empty',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeApp.light,
        home: const PageReceiptProcess(files: []),
      ),
    );
    final button = tester.widget<FilledButton>(
      find.byWidgetPredicate((widget) => widget is FilledButton),
    );
    expect(button.onPressed, isNull);
  });

  testWidgets('gallery selection defers cropping until Continue is pressed',
      (tester) async {
    final directory = (await tester.runAsync(
      () => Directory.systemTemp.createTemp('receipt_selection_test'),
    ))!;
    addTearDown(() => directory.delete(recursive: true));
    final file = File('${directory.path}/source.jpg');
    await tester.runAsync(() async {
      await file
          .writeAsBytes(img.encodeJpg(img.Image(width: 100, height: 200)));
      await Directory('${directory.path}/receipt_images').create();
    });
    var cropCalls = 0;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
      ..setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider'),
        (_) async => directory.path,
      )
      ..setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/image_picker'),
        (call) async {
          expect(call.method, 'pickMultiImage');
          return [file.path];
        },
      )
      ..setMockMethodCallHandler(
        const MethodChannel('fis_app/receipt_crop'),
        (call) async {
          cropCalls++;
          expect((call.arguments as Map)['path'], file.path);
          return null;
        },
      );
    await tester.pumpWidget(
      MaterialApp(theme: ThemeApp.light, home: const PageReceipt()),
    );
    await tester.tap(find.text('Galeriden Resim Seç'));
    await tester.pumpAndSettle();
    expect(find.text('1 resim seçildi - Devam Et'), findsOneWidget);
    expect(cropCalls, 0);
    await tester.tap(find.text('1 resim seçildi - Devam Et'));
    await tester.pumpAndSettle();
    expect(cropCalls, 1);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    await tester
        .runAsync(() => Future<void>.delayed(const Duration(milliseconds: 20)));
  });
}
