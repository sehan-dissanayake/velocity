import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:rxdart/subjects.dart';
import 'package:flutter/material.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_init;

class NotificationService {
  static final NotificationService _instance = NotificationService._();
  factory NotificationService() => _instance;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final BehaviorSubject<NotificationResponse> _onNotificationClick =
      BehaviorSubject<NotificationResponse>();

  static const String rfidChannelId = 'rfid_notifications';
  static const String defaultChannelId = 'velocity_notifications';

  NotificationService._();

  Stream<NotificationResponse> get onNotificationClick =>
      _onNotificationClick.stream;

  Future<void> init() async {
    tz_init.initializeTimeZones();

    // Android initialization
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // In NotificationService initialization
    final DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: true,
          requestBadgePermission: true,
          requestSoundPermission: true,
          notificationCategories: [
            DarwinNotificationCategory(
              'rfidCategory',
              actions: <DarwinNotificationAction>[
                DarwinNotificationAction.plain('id', 'Action'),
              ],
            ),
          ],
        );

    // Initialize settings
    final InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    // Initialize plugin
    await _flutterLocalNotificationsPlugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationResponse,
      onDidReceiveBackgroundNotificationResponse:
          _onNotificationBackgroundResponse,
    );

    // Create notification channels for Android
    await _createNotificationChannels();
  }

  Future<void> _createNotificationChannels() async {
    // Get Android-specific plugin implementation
    final androidPlugin =
        _flutterLocalNotificationsPlugin
            .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin
            >();

    if (androidPlugin != null) {
      // RFID notification channel (high importance)
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          rfidChannelId,
          'RFID Notifications',
          description: 'Notifications for RFID events',
          importance: Importance.high,
        ),
      );

      // Default notification channel
      await androidPlugin.createNotificationChannel(
        const AndroidNotificationChannel(
          defaultChannelId,
          'General Notifications',
          description: 'General application notifications',
          importance: Importance.defaultImportance,
        ),
      );
    }
  }

  static void _onNotificationResponse(NotificationResponse response) {
    NotificationService()._onNotificationClick.add(response);
  }

  @pragma('vm:entry-point')
  static void _onNotificationBackgroundResponse(NotificationResponse response) {
    // Background handling
    debugPrint('Notification clicked in background: ${response.payload}');
  }

  Future<void> showRfidNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    return _showNotification(
      id: id,
      title: title,
      body: body,
      channelId: rfidChannelId,
      payload: payload,
    );
  }

  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    return _showNotification(
      id: id,
      title: title,
      body: body,
      channelId: defaultChannelId,
      payload: payload,
    );
  }

  Future<void> _showNotification({
    required int id,
    required String title,
    required String body,
    required String channelId,
    String? payload,
  }) async {
    final AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
          channelId, // Use the provided channel ID
          channelId == rfidChannelId
              ? 'RFID Notifications'
              : 'General Notifications',
          channelDescription:
              channelId == rfidChannelId
                  ? 'Notifications for RFID events'
                  : 'General application notifications',
          importance: Importance.high,
          priority: Priority.high,
          showWhen: true,
        );

    const DarwinNotificationDetails iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails details = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _flutterLocalNotificationsPlugin.show(
      id,
      title,
      body,
      details,
      payload: payload,
    );
  }
}
