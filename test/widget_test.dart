import 'package:fis_app_flutter/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('renders login flow on startup', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Giriş Yap'), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
    expect(find.text('Giriş'), findsOneWidget);
  });
}
