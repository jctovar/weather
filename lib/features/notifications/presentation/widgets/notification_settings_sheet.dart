import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weather/features/notifications/presentation/providers/notification_settings_provider.dart';

/// Bottom sheet for rain-notification settings.
class NotificationSettingsSheet extends ConsumerWidget {
  const NotificationSettingsSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final enabled = ref.watch(notificationSettingsProvider);
    final notifier = ref.read(notificationSettingsProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Configuración',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            SwitchListTile(
              title: const Text('Notificaciones de lluvia'),
              subtitle: const Text(
                'Avisa cuando haya ≥70% de probabilidad de lluvia en las próximas 3 horas',
              ),
              value: enabled,
              onChanged: (value) => _onToggle(context, value, notifier),
            ),
            const Divider(height: 32),
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  size: 16,
                  color: Theme.of(context).colorScheme.outline,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Máximo 1 notificación cada 6 horas.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Future<void> _onToggle(
    BuildContext context,
    bool value,
    NotificationSettingsNotifier notifier,
  ) async {
    if (!value) {
      await notifier.toggle(false);
      return;
    }

    // Request notification permission (Android 13+).
    final status = await Permission.notification.request();
    if (status.isGranted) {
      await notifier.toggle(true);
    } else {
      await notifier.toggle(false);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Permiso de notificaciones necesario'),
          ),
        );
      }
    }
  }
}
