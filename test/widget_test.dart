import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather/main.dart';

void main() {
  setUpAll(() async {
    // Initialize Hive for testing
    await Hive.initFlutter();
    await Hive.openBox('weather_box');
  });

  tearDownAll(() async {
    // Clean up Hive
    await Hive.close();
  });

  testWidgets('Weather app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const WeatherApp(),
    );

    // Verify that the loading indicator is shown initially.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
