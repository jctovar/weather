import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather/core/constants/app_constants.dart';
import 'package:weather/main.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    Hive.init('.hive_test_smoke');
    await Hive.openBox<String>(AppConstants.weatherBoxName);
  });

  tearDownAll(() async {
    if (Hive.isBoxOpen(AppConstants.weatherBoxName)) {
      await Hive.box<String>(AppConstants.weatherBoxName).close();
    }
    await Hive.close();
  });

  testWidgets('Weather app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: WeatherApp(),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
