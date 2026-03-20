import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import 'notification_providers.dart';

// ─── Keys ─────────────────────────────────────────────────────────────────

const _kReminderEnabled = 'reminder_enabled';
const _kReminderHour = 'reminder_hour_24';
const _kReminderMinute = 'reminder_minute';

// ─── Service ──────────────────────────────────────────────────────────────

class NotificationService {
  NotificationService._();

  static final _plugin = FlutterLocalNotificationsPlugin();
  static ProviderContainer? _container;

  static const _notifId = 1;
  static const _channelId = 'daily_reminder';
  static const _channelName = 'Daily Reminder';

  static const _bodies = [
    "How are you feeling today?",
    "Take a moment to check in with yourself.",
    "A quick mood log goes a long way.",
    "How's your day going?",
    "Your journal is waiting for you.",
  ];

  // ── Init ──────────────────────────────────────────────

  static Future<void> initialize(ProviderContainer container) async {
    _container = container;
    tz.initializeTimeZones();

    // Resolve device timezone so tz.local is correct
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (e) {
      debugPrint('Could not resolve timezone: $e');
    }

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    await _plugin.initialize(
      const InitializationSettings(android: android, iOS: darwin),
      onDidReceiveNotificationResponse: _onTap,
      onDidReceiveBackgroundNotificationResponse: _onTapBackground,
    );

    // If app was launched from a notification tap, handle it
    final launchDetails =
        await _plugin.getNotificationAppLaunchDetails();
    if (launchDetails?.didNotificationLaunchApp == true) {
      _triggerPendingCheckIn();
    }
  }

  static void _onTap(NotificationResponse response) {
    _triggerPendingCheckIn();
  }

  static void _triggerPendingCheckIn() {
    _container?.read(pendingCheckInProvider.notifier).state = true;
  }

  // ── Permission ────────────────────────────────────────

  static Future<bool> requestAndroidPermission() async {
    final impl = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    return await impl?.requestNotificationsPermission() ?? false;
  }

  // ── Schedule ──────────────────────────────────────────

  /// Schedules a daily notification at [hour24]:[minute] local time.
  static Future<void> scheduleDailyReminder(
      int hour24, int minute) async {
    await _plugin.cancel(_notifId);

    final body = _bodies[Random().nextInt(_bodies.length)];

    await _plugin.zonedSchedule(
      _notifId,
      'Time to check in 🌙',
      body,
      _nextInstanceOf(hour24, minute),
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: 'Daily mood check-in reminder',
          importance: Importance.high,
          priority: Priority.high,
          icon: '@mipmap/ic_launcher',
        ),
        iOS: const DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
      payload: 'checkin',
    );

    // Persist
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReminderEnabled, true);
    await prefs.setInt(_kReminderHour, hour24);
    await prefs.setInt(_kReminderMinute, minute);
  }

  static Future<void> cancelReminder() async {
    await _plugin.cancel(_notifId);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kReminderEnabled, false);
  }

  // ── Saved prefs ───────────────────────────────────────

  static Future<ReminderSettings> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return ReminderSettings(
      enabled: prefs.getBool(_kReminderEnabled) ?? false,
      hour24: prefs.getInt(_kReminderHour) ?? 20, // default 8 PM
      minute: prefs.getInt(_kReminderMinute) ?? 0,
    );
  }

  // ── Helpers ───────────────────────────────────────────

  static tz.TZDateTime _nextInstanceOf(int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
        tz.local, now.year, now.month, now.day, hour, minute);
    if (scheduled.isBefore(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }
}

// ── Background handler must be top-level ──────────────────────────────────

@pragma('vm:entry-point')
void _onTapBackground(NotificationResponse response) {
  // Handled when app next comes to foreground via getNotificationAppLaunchDetails
}

// ─── Settings model ────────────────────────────────────────────────────────

class ReminderSettings {
  const ReminderSettings({
    required this.enabled,
    required this.hour24,
    required this.minute,
  });
  final bool enabled;
  final int hour24;
  final int minute;

  /// hour24 → 12h display string e.g. "8:00 PM"
  String get displayTime {
    final period = hour24 >= 12 ? 'PM' : 'AM';
    final h = hour24 % 12 == 0 ? 12 : hour24 % 12;
    final m = minute.toString().padLeft(2, '0');
    return '$h:$m $period';
  }
}
