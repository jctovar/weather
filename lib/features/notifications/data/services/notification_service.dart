import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:weather/core/constants/app_constants.dart';
import 'package:weather/core/utils/app_logger.dart';

/// Handles local notification display and anti-spam cooldown.
class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static bool _initialized = false;

  /// Initializes the notification plugin and creates the Android channel.
  static Future<void> init() async {
    if (_initialized) return;

    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initializationSettings = InitializationSettings(
      android: androidSettings,
    );
    await _plugin.initialize(initializationSettings);
    await _createChannel();
    _initialized = true;
    AppLogger.info('Notification service initialized');
  }

  static Future<void> _createChannel() async {
    const channel = AndroidNotificationChannel(
      AppConstants.rainNotificationChannelId,
      AppConstants.rainNotificationChannelName,
      importance: Importance.high,
    );
    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);
  }

  /// Returns true if a notification was shown in the last
  /// [AppConstants.rainCooldownHours] hours.
  static Future<bool> isSpamCooldownActive() async {
    final prefs = await SharedPreferences.getInstance();
    final lastTimeStr = prefs.getString(
      AppConstants.lastRainNotificationTimeKey,
    );
    if (lastTimeStr == null) return false;
    final lastTime = DateTime.parse(lastTimeStr);
    return DateTime.now().difference(lastTime).inHours <
        AppConstants.rainCooldownHours;
  }

  /// Displays a rain notification and records the timestamp.
  static Future<void> showRainNotification(String message) async {
    await _plugin.show(
      0,
      AppConstants.rainNotificationChannelName,
      message,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          AppConstants.rainNotificationChannelId,
          AppConstants.rainNotificationChannelName,
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
      ),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      AppConstants.lastRainNotificationTimeKey,
      DateTime.now().toIso8601String(),
    );
    AppLogger.info('Rain notification shown: $message');
  }
}
