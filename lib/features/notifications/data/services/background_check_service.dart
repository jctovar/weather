import 'package:hive_flutter/hive_flutter.dart';
import 'package:weather/core/constants/app_constants.dart';
import 'package:weather/core/utils/app_logger.dart';
import 'package:weather/core/utils/weather_code_mapper.dart';
import 'package:weather/features/home_widget/data/services/home_widget_service.dart';
import 'package:weather/features/notifications/data/services/notification_service.dart';
import 'package:weather/features/notifications/domain/usecases/get_rain_notification_message.dart';
import 'package:weather/features/notifications/domain/usecases/should_notify_rain.dart';
import 'package:weather/features/weather/data/datasources/local_cache_datasource.dart';
import 'package:weather/features/weather/data/datasources/open_meteo_api_datasource.dart';

/// Orchestrates a rain check in a background isolate.
class BackgroundCheckService {
  Future<void> checkAndNotify() async {
    try {
      // Init Hive (required in WorkManager isolate).
      await Hive.initFlutter();
      await Hive.openBox<String>(AppConstants.weatherBoxName);

      final cache = LocalCacheDataSource();
      await cache.init();

      // Get last known location.
      final location = cache.getLastLocation();
      if (location == null) {
        AppLogger.warn('No last location for background check');
        return;
      }

      // Fetch hourly forecast (2 days to have buffer data).
      final api = OpenMeteoApiDataSource();
      final forecastModel = await api.getHourlyForecast(
        latitude: location.lat,
        longitude: location.lon,
      );
      final hourly = forecastModel.toEntityList();

      // Filter next 3 hours from now.
      final now = DateTime.now();
      final next3Hours = hourly.where((h) {
        final diff = h.time.difference(now).inMinutes;
        return diff >= 0 && diff <= 180;
      }).toList();

      if (next3Hours.isEmpty) {
        AppLogger.info('No hourly data in next 3 hours');
        return;
      }

      // Check rain criteria.
      if (!shouldNotifyRain(next3Hours)) {
        AppLogger.info('No rain detected in next 3 hours');
        return;
      }

      // Anti-spam cooldown.
      if (await NotificationService.isSpamCooldownActive()) {
        AppLogger.info('Notification cooldown active, skipping');
        return;
      }

      // Show notification.
      final matching = next3Hours.where(
        (h) => h.precipitationProbability >= 70 && h.precipitation > 0.5,
      ).toList();
      final message = getRainNotificationMessage(matching);
      await NotificationService.showRainNotification(message);

      // Update home widget with current weather
      await _updateWidget(location);
    } catch (e) {
      AppLogger.error('Background rain check failed: $e');
    }
  }

  Future<void> _updateWidget(({double lat, double lon}) location) async {
    try {
      final api = OpenMeteoApiDataSource();
      final currentModel = await api.getCurrentWeather(
        latitude: location.lat,
        longitude: location.lon,
      );
      final current = currentModel.toEntity();

      await HomeWidgetService.saveWeatherData(
        locationName: '', // Keep existing location name
        temperature: current.temperature,
        weatherCode: current.weatherCode,
        isDay: current.isDay,
        description: WeatherCodeMapper.description(current.weatherCode),
      );
      AppLogger.info('Home widget updated from background');
    } catch (e) {
      AppLogger.error('Failed to update widget in background: $e');
    }
  }
}
