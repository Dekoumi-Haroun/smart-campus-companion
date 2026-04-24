import 'dart:developer' as developer;

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../../domain/entities/timetable_item.dart';

/// Callback invoked when a notification is tapped while the app is running.
/// Set by the app (in main.dart) so the service can delegate navigation.
typedef NotificationTapCallback = void Function(String? payload);

/// Singleton service for local notifications.
///
/// Handles initialization, scheduling class reminders (10 min before),
/// firing ad-hoc notifications (e.g., "New announcements"), and
/// cancelling everything when the user disables notifications.
class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  /// External callback for handling notification taps (set from app layer).
  NotificationTapCallback? onNotificationTap;

  bool _initialized = false;

  // ── Android Notification Channel ──
  static const _channelId = 'smart_campus_reminders';
  static const _channelName = 'Class Reminders';
  static const _channelDescription = 'Notifications for upcoming classes';

  static const _bgChannelId = 'smart_campus_background';
  static const _bgChannelName = 'Background Updates';
  static const _bgChannelDescription =
      'Notifications for new announcements found in the background';

  /// Initialize the plugin. Must be called once at app startup.
  Future<void> init() async {
    if (_initialized || kIsWeb) return;

    tz.initializeTimeZones();

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _plugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
      onDidReceiveNotificationResponse: _onNotificationResponse,
    );

    // Create the Android notification channels.
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.high,
        ),
      );
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          _bgChannelId,
          _bgChannelName,
          description: _bgChannelDescription,
          importance: Importance.defaultImportance,
        ),
      );
    }

    _initialized = true;
    developer.log('NotificationService initialized', name: 'Notifications');
  }

  void _onNotificationResponse(NotificationResponse response) {
    developer.log(
      'Notification tapped: payload=${response.payload}',
      name: 'Notifications',
    );
    onNotificationTap?.call(response.payload);
  }

  /// Request notification permission on Android 13+ / iOS.
  Future<bool> requestPermission() async {
    if (kIsWeb) return false;
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    if (androidPlugin != null) {
      final granted = await androidPlugin.requestNotificationsPermission();
      return granted ?? false;
    }
    // iOS permissions are requested during init.
    return true;
  }

  /// Schedule a reminder notification 10 minutes before a timetable class.
  ///
  /// The [notificationId] is derived from the timetable item ID so it can be
  /// cancelled individually. The [payload] contains the item ID for deep linking.
  Future<int> scheduleClassReminder(TimetableItem item) async {
    if (kIsWeb) return -1;
    final notificationId = item.id.hashCode.abs() % 2147483647;

    // Build the scheduled date/time for the next occurrence of this class.
    final scheduledDate = _nextOccurrence(item.dayOfWeek, item.startTime);
    // 10 minutes before class.
    final reminderTime = scheduledDate.subtract(const Duration(minutes: 10));

    // Don't schedule if the reminder time is already in the past.
    if (reminderTime.isBefore(tz.TZDateTime.now(tz.local))) {
      // Schedule for next week instead.
      final nextWeek = reminderTime.add(const Duration(days: 7));
      await _scheduleAt(
        id: notificationId,
        title: 'Class in 10 minutes',
        body: '${item.courseName} with ${item.instructor} in ${item.room}',
        scheduledDate: tz.TZDateTime.from(nextWeek, tz.local),
        payload: 'timetable:${item.id}',
      );
    } else {
      await _scheduleAt(
        id: notificationId,
        title: 'Class in 10 minutes',
        body: '${item.courseName} with ${item.instructor} in ${item.room}',
        scheduledDate: tz.TZDateTime.from(reminderTime, tz.local),
        payload: 'timetable:${item.id}',
      );
    }

    developer.log(
      'Scheduled reminder for ${item.courseName} (id=$notificationId)',
      name: 'Notifications',
    );
    return notificationId;
  }

  /// Cancel a specific scheduled notification.
  Future<void> cancelReminder(int notificationId) async {
    if (kIsWeb) return;
    await _plugin.cancel(notificationId);
    developer.log(
      'Cancelled reminder id=$notificationId',
      name: 'Notifications',
    );
  }

  /// Cancel all pending notifications.
  Future<void> cancelAll() async {
    if (kIsWeb) return;
    await _plugin.cancelAll();
    developer.log('Cancelled all notifications', name: 'Notifications');
  }

  /// Show an immediate notification (used by background task).
  Future<void> showInstant({
    required String title,
    required String body,
    String? payload,
  }) async {
    if (kIsWeb) return;
    const androidDetails = AndroidNotificationDetails(
      _bgChannelId,
      _bgChannelName,
      channelDescription: _bgChannelDescription,
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      DateTime.now().millisecondsSinceEpoch % 2147483647,
      title,
      body,
      details,
      payload: payload,
    );
  }

  // ── Helpers ──

  Future<void> _scheduleAt({
    required int id,
    required String title,
    required String body,
    required tz.TZDateTime scheduledDate,
    String? payload,
  }) async {
    const androidDetails = AndroidNotificationDetails(
      _channelId,
      _channelName,
      channelDescription: _channelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      scheduledDate,
      details,
      payload: payload,
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
    );
  }

  /// Compute the next [tz.TZDateTime] for a given [dayOfWeek] (1=Mon) and
  /// [time] ("HH:mm").
  tz.TZDateTime _nextOccurrence(int dayOfWeek, String time) {
    final parts = time.split(':');
    if (parts.length < 2) {
      throw FormatException(
        'Invalid time format for notification scheduling: "$time"',
      );
    }
    final hour = int.parse(parts[0]);
    final minute = int.parse(parts[1]);

    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );

    // Adjust to the correct weekday.
    while (scheduled.weekday != dayOfWeek) {
      scheduled = scheduled.add(const Duration(days: 1));
    }

    // If this occurrence has already passed, move to next week.
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 7));
    }
    return scheduled;
  }
}
