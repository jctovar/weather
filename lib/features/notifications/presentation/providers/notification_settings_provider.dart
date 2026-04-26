import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workmanager/workmanager.dart';
import 'package:weather/core/constants/app_constants.dart';
import 'package:weather/core/utils/app_logger.dart';

/// Manages rain-notification toggle state and WorkManager registration.
class NotificationSettingsNotifier extends Notifier<bool> {
  @override
  bool build() {
    _load();
    return false;
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    state = prefs.getBool(AppConstants.rainNotificationsEnabledKey) ?? false;
  }

  /// Toggles notifications on/off and registers/cancels the background task.
  Future<void> toggle(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConstants.rainNotificationsEnabledKey, enabled);
    state = enabled;

    if (enabled) {
      await _registerBackgroundTask();
      AppLogger.info('Rain notifications enabled, task registered');
    } else {
      await Workmanager().cancelByTag(AppConstants.rainCheckTaskTag);
      AppLogger.info('Rain notifications disabled, task cancelled');
    }
  }

  Future<void> _registerBackgroundTask() async {
    await Workmanager().registerPeriodicTask(
      AppConstants.rainCheckTaskName,
      AppConstants.rainCheckTaskTag,
      frequency: const Duration(
        minutes: AppConstants.rainCheckIntervalMinutes,
      ),
      constraints: Constraints(networkType: NetworkType.connected),
      existingWorkPolicy: ExistingWorkPolicy.keep,
    );
  }
}

/// Provider for notification settings.
final notificationSettingsProvider =
    NotifierProvider<NotificationSettingsNotifier, bool>(
  NotificationSettingsNotifier.new,
);
