import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:workmanager/workmanager.dart';
import 'package:weather/background/workmanager_callback.dart';
import 'package:weather/core/theme/app_theme.dart';
import 'package:weather/features/home_widget/data/services/home_widget_service.dart';
import 'package:weather/features/notifications/data/services/notification_service.dart';
import 'package:weather/features/weather/presentation/bloc/weather_notifier.dart';
import 'package:weather/features/weather/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local caching
  await Hive.initFlutter();
  await Hive.openBox<String>('weather_box');

  // Initialize local notifications
  await NotificationService.init();

  // Initialize home screen widget
  await HomeWidgetService.init();

  // Initialize WorkManager for background rain checks
  await Workmanager().initialize(callbackDispatcher);

  runApp(
    const ProviderScope(
      child: WeatherApp(),
    ),
  );
}

/// Root widget that sets up Material 3 theming and triggers weather loading
/// on the first frame.
class WeatherApp extends ConsumerWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize weather data on app start
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(weatherProvider.notifier).init();
    });

    return MaterialApp(
      title: 'Weather App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: const HomePage(),
    );
  }
}
