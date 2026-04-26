import 'package:home_widget/home_widget.dart';
import 'package:weather/core/utils/app_logger.dart';

/// Abstraction over the home_widget package.
///
/// Saves weather data that the Android [WeatherWidgetProvider] reads
/// via [HomeWidgetPlugin.getData] to render the home screen widget.
class HomeWidgetService {
  HomeWidgetService._();

  static const String _appGroupId = 'group.com.fanguye.weather';
  static const String _widgetName = 'WeatherWidgetProvider';
  static const String _prefix = 'weather_widget_';

  /// Initializes the home widget group ID.
  static Future<void> init() async {
    await HomeWidget.setAppGroupId(_appGroupId);
  }

  /// Persists current weather data and triggers a widget update.
  static Future<void> saveWeatherData({
    required String locationName,
    required double temperature,
    required int weatherCode,
    required bool isDay,
    String description = '',
    double? tempMax,
    double? tempMin,
  }) async {
    try {
      await HomeWidget.saveWidgetData(
        '${_prefix}location',
        locationName,
      );
      await HomeWidget.saveWidgetData(
        '${_prefix}temp',
        temperature.toStringAsFixed(0),
      );
      await HomeWidget.saveWidgetData(
        '${_prefix}code',
        weatherCode.toString(),
      );
      await HomeWidget.saveWidgetData(
        '${_prefix}isDay',
        isDay ? '1' : '0',
      );
      await HomeWidget.saveWidgetData(
        '${_prefix}desc',
        description,
      );
      await HomeWidget.saveWidgetData(
        '${_prefix}max',
        tempMax?.toStringAsFixed(0) ?? '',
      );
      await HomeWidget.saveWidgetData(
        '${_prefix}min',
        tempMin?.toStringAsFixed(0) ?? '',
      );

      await HomeWidget.updateWidget(
        name: _widgetName,
        androidName: _widgetName,
      );
      AppLogger.info('Home widget data updated');
    } catch (e) {
      AppLogger.error('Failed to update home widget: $e');
    }
  }
}
