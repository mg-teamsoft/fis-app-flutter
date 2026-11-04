import 'package:fis_app_flutter/app/import/theme.dart';
import 'package:fis_app_flutter/app/widget/twice_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final width in <double>[
    320,
    360,
    375,
    390,
    393,
    402,
    414,
    420,
    428,
    430,
    440,
  ]) {
    for (final scale in <double>[1, 1.3, 2]) {
      testWidgets('Full action labels at width $width and text scale $scale',
          (tester) async {
        final size = Size(width, 956);
        tester.view.devicePixelRatio = 1;
        tester.view.physicalSize = size;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        var uploads = 0;
        var excelOpens = 0;

        await tester.pumpWidget(
          MaterialApp(
            theme: ThemeApp.light,
            home: MediaQuery(
              data: MediaQueryData(
                size: size,
                textScaler: TextScaler.linear(scale),
              ),
              child: Scaffold(
                body: Padding(
                  padding: const ThemePadding.all20(),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: TwiceButton(
                      size: size,
                      onPressedOne: () => uploads++,
                      onPressedTwo: () => excelOpens++,
                      titleOne: 'Fiş Yükle',
                      titleTwo: 'Excel Aç',
                      iconOne: const Icon(Icons.receipt, size: 24),
                      iconTwo: const Icon(Icons.table_chart, size: 24),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );

        expect(tester.takeException(), isNull);
        for (final label in ['Fiş Yükle', 'Excel Aç']) {
          final finder = find.text(label);
          final paragraph = tester.renderObject<RenderParagraph>(finder);
          expect(paragraph.didExceedMaxLines, isFalse);
          final boxes = paragraph.getBoxesForSelection(
            TextSelection(baseOffset: 0, extentOffset: label.length),
          );
          expect(boxes.map((box) => box.top).toSet(), hasLength(1));
          final button = find.ancestor(
            of: finder,
            matching: find.byType(ElevatedButton),
          );
          final bounds = tester.getRect(button);
          for (final box in boxes) {
            final topLeft = paragraph.localToGlobal(Offset(box.left, box.top));
            final bottomRight =
                paragraph.localToGlobal(Offset(box.right, box.bottom));
            expect(bounds.contains(topLeft), isTrue);
            expect(bounds.contains(bottomRight), isTrue);
          }
          await tester.tap(button);
        }
        expect(uploads, 1);
        expect(excelOpens, 1);
      });
    }
  }
}
