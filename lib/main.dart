import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather/core/theme/app_theme.dart';
import 'package:weather/features/weather/presentation/bloc/weather_notifier.dart';
import 'package:weather/features/weather/presentation/pages/home_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local caching
  await Hive.initFlutter();

  // Initialize the weather cache
  await Hive.openBox('weather_box');

  runApp(
    const ProviderScope(
      child: WeatherApp(),
    ),
  );
}

/// Root widget of the weather application.
class WeatherApp extends ConsumerWidget {
  const WeatherApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize weather data on app start
    ref.read(weatherProvider).init();

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
