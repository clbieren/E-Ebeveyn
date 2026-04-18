import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();

    const androidInit = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosInit = DarwinInitializationSettings();
    const initSettings = InitializationSettings(
      android: androidInit,
      iOS: iosInit,
    );

    await _plugin.initialize(settings: initSettings);
    _initialized = true;
  }

  Future<bool> requestPermissions() async {
    try {
      final plugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      await plugin?.requestNotificationsPermission();

      final ios = _plugin.resolvePlatformSpecificImplementation<
          IOSFlutterLocalNotificationsPlugin>();
      await ios?.requestPermissions(alert: true, badge: true, sound: true);

      final status = await Permission.notification.request();
      return status.isGranted || status.isLimited || status.isProvisional;
    } catch (_) {
      return false;
    }
  }

  Future<void> scheduleReminder(
    int id,
    String title,
    String body,
    DateTime scheduledTime,
  ) async {
    try {
      await initialize();
      final when = tz.TZDateTime.from(scheduledTime, tz.local);
      if (when.isBefore(tz.TZDateTime.now(tz.local))) return;

      await _plugin.zonedSchedule(
        id: id,
        title: title,
        body: body,
        scheduledDate: when,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'reminders_channel',
            'Hatirlatmalar',
            channelDescription: 'Beslenme, uyku, ilac ve diger hatirlatmalar',
            importance: Importance.max,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      );
    } catch (_) {
      rethrow;
    }
  }

  Future<void> cancelReminder(int id) async {
    try {
      await _plugin.cancel(id: id);
    } catch (_) {
      rethrow;
    }
  }
}
