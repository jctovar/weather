import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:weather/core/constants/app_constants.dart';
import 'package:weather/core/utils/app_logger.dart';
import 'package:weather/features/notifications/data/services/background_check_service.dart';

/// Top-level entry point for WorkManager background tasks.
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    AppLogger.info('Background task started: $taskName');

    // Early exit if notifications are disabled.
    final prefs = await SharedPreferences.getInstance();
    final enabled =
        prefs.getBool(AppConstants.rainNotificationsEnabledKey) ?? false;
    if (!enabled) {
      AppLogger.info('Rain notifications disabled, skipping');
      return Future.value(true);
    }

    await BackgroundCheckService().checkAndNotify();
    return Future.value(true);
  });
}
