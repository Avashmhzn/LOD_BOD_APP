import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lodbod_app/core/widgets/brand_splash.dart';

void main() {
  testWidgets('splash shows Lod Bod branding and loading status', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: BrandSplash(statusText: 'Checking your session...'),
      ),
    );

    expect(find.text('LOD'), findsOneWidget);
    expect(find.text('BOD'), findsOneWidget);
    expect(find.text('S H I P P E R'), findsOneWidget);
    expect(find.text('Checking your session...'), findsOneWidget);
  });
}
