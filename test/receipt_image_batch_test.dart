import 'package:fis_app_flutter/app/services/receipt_image_batch.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  test(
      'prepares 20 files sequentially and keeps only generated file references',
      () async {
    var active = 0;
    var maxActive = 0;
    final preparedOrder = <String>[];
    final deleted = <String>[];
    final progress = <int>[];
    final sources = List.generate(20, (i) => XFile('/gallery/$i.jpg'));
    final batch = ReceiptImageBatch(
      prepare: (source) async {
        active++;
        if (active > maxActive) maxActive = active;
        await Future<void>.delayed(Duration.zero);
        preparedOrder.add(source.path);
        active--;
        return XFile('/prepared/${source.name}');
      },
      delete: (file) async => deleted.add(file.path),
    );
    final output = await batch.prepareAll(
      sources,
      onProgress: (completed, total) {
        expect(total, 20);
        progress.add(completed);
      },
      isCancelled: () => false,
    );
    expect(maxActive, 1);
    expect(preparedOrder, sources.map((f) => f.path));
    expect(output, hasLength(20));
    expect(progress, List.generate(21, (i) => i));
    expect(deleted, isEmpty);
    await batch.dispose();
    expect(deleted, output.map((f) => f.path));
    expect(deleted.any((path) => path.startsWith('/gallery/')), isFalse);
    await batch.dispose();
    expect(deleted, hasLength(20));
  });

  test('cleans generated files if preparation fails part way through',
      () async {
    final deleted = <String>[];
    var calls = 0;
    final batch = ReceiptImageBatch(
      prepare: (file) async {
        if (++calls == 3) throw Exception('No document');
        return XFile('/prepared/${file.name}');
      },
      delete: (file) async => deleted.add(file.path),
    );
    await expectLater(
      batch.prepareAll(
        List.generate(5, (i) => XFile('/gallery/$i.jpg')),
        onProgress: (_, __) {},
        isCancelled: () => false,
      ),
      throwsException,
    );
    expect(calls, 3);
    expect(deleted, ['/prepared/0.jpg', '/prepared/1.jpg']);
  });

  test('stops after the current file and cleans it if its page is closed',
      () async {
    var cancelled = false;
    final deleted = <String>[];
    var calls = 0;
    final batch = ReceiptImageBatch(
      prepare: (file) async {
        calls++;
        cancelled = true;
        return XFile('/prepared/${file.name}');
      },
      delete: (file) async => deleted.add(file.path),
    );
    await expectLater(
      batch.prepareAll(
        [XFile('/gallery/1.jpg'), XFile('/gallery/2.jpg')],
        onProgress: (_, __) {},
        isCancelled: () => cancelled,
      ),
      throwsException,
    );
    expect(calls, 1);
    expect(deleted, ['/prepared/1.jpg']);
  });
}
