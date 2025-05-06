import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

class NotificationService {
  // Singleton pattern
  static final NotificationService _notificationService = NotificationService._internal();
  factory NotificationService() => _notificationService;
  NotificationService._internal();

  // Notification plugin instance
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // Notification IDs
  static const int instantNotificationId = 0;
  static const int scheduledNotificationId = 1;
  static const int periodicNotificationId = 2;

  // Notification Channels for Android
  static const String _channelId = 'high_importance_channel';
  static const String _channelName = 'High Importance Notifications';
  static const String _channelDescription = 'Channel for important notifications';

  // Health Goals Channel
  static const String _healthGoalsChannelId = 'health_goals_channel';
  static const String _healthGoalsChannelName = 'Health Goals Notifications';
  static const String _healthGoalsChannelDescription = 'Channel for health goals reminders';

  // Medication Channel
  static const String _medicationChannelId = 'medication_channel';
  static const String _medicationChannelName = 'Medication Reminders';
  static const String _medicationChannelDescription = 'Channel for medication reminders';

  // Initialize notifications
  Future<void> initializeNotifications() async {
    // Android initialization settings
    print("----------- Initialize Notifications Completed -------------");
    const AndroidInitializationSettings initializationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    // iOS initialization settings
    const DarwinInitializationSettings initializationSettingsIOS =
    DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    // Initialize settings for all platforms
    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: onNotificationTapped,
    );

    // Create Android notification channels
    await _createNotificationChannels();
  }

  // Create Android notification channels
  Future<void> _createNotificationChannels() async {
    // Main high importance channel
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      _channelId,
      _channelName,
      description: _channelDescription,
      importance: Importance.max,
    );

    // Health goals channel
    const AndroidNotificationChannel healthGoalsChannel = AndroidNotificationChannel(
      _healthGoalsChannelId,
      _healthGoalsChannelName,
      description: _healthGoalsChannelDescription,
      importance: Importance.high,
    );

    // Medication channel
    const AndroidNotificationChannel medicationChannel = AndroidNotificationChannel(
      _medicationChannelId,
      _medicationChannelName,
      description: _medicationChannelDescription,
      importance: Importance.max, // High importance to ensure medication reminders are noticed
      sound: RawResourceAndroidNotificationSound('medication_alert'), // Custom sound for medication reminders
      enableVibration: true,
    );

    // Create the channels
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(healthGoalsChannel);

    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(medicationChannel);
  }

  // Request permissions
  Future<void> requestPermissions() async {
    // Request permissions for iOS
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );

    // For Android 13 and above (API level 33)
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
        ?.requestNotificationsPermission();
  }

  // Handle notification tap
  void onNotificationTapped(NotificationResponse notificationResponse) {
    // Handle notification tap based on payload
    if (notificationResponse.payload != null) {
      print('Notification payload: ${notificationResponse.payload}');
      // You can navigate to a specific screen based on the payload

      // For medication reminders, extract medication ID
      try {
        // Attempt to parse JSON payload
        Map<String, dynamic> payload = jsonDecode(notificationResponse.payload!);

        if (payload.containsKey('medicationId')) {
          String medicationId = payload['medicationId'];
          // You could navigate to medication details screen or mark as taken
          // Example navigation code would go here
        }
      } catch (e) {
        print('Error parsing notification payload: $e');
      }
    }
  }

  // Show instant notification
  Future<void> showInstantNotification({
    required String title,
    required String body,
    String? payload,
    String? channelId,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      channelId ?? _channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.show(
      instantNotificationId,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // Schedule a notification
  Future<void> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
    String? channelId,
    int? id,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      channelId ?? _channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.zonedSchedule(
      id ?? scheduledNotificationId,
      title,
      body,
      tz.TZDateTime.from(scheduledDate, tz.local),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Helper method to get channel name based on channelId
  String _getChannelName(String? channelId) {
    if (channelId == _healthGoalsChannelId) {
      return _healthGoalsChannelName;
    } else if (channelId == _medicationChannelId) {
      return _medicationChannelName;
    } else {
      return _channelName;
    }
  }

  // Helper method to get channel description based on channelId
  String _getChannelDescription(String? channelId) {
    if (channelId == _healthGoalsChannelId) {
      return _healthGoalsChannelDescription;
    } else if (channelId == _medicationChannelId) {
      return _medicationChannelDescription;
    } else {
      return _channelDescription;
    }
  }

  // Show periodic notification
  Future<void> showPeriodicNotification({
    required String title,
    required String body,
    required RepeatInterval repeatInterval,
    String? payload,
    String? channelId,
    int? id,
  }) async {
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
    AndroidNotificationDetails(
      channelId ?? _channelId,
      _getChannelName(channelId),
      channelDescription: _getChannelDescription(channelId),
      importance: Importance.max,
      priority: Priority.high,
    );

    const DarwinNotificationDetails iOSPlatformChannelSpecifics =
    DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final NotificationDetails platformChannelSpecifics = NotificationDetails(
      android: androidPlatformChannelSpecifics,
      iOS: iOSPlatformChannelSpecifics,
    );

    await flutterLocalNotificationsPlugin.periodicallyShow(
      id ?? periodicNotificationId,
      title,
      body,
      repeatInterval,
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  // Schedule a medication reminder notification
  Future<void> scheduleMedicationReminder({
    required String title,
    required String body,
    required DateTime scheduledDate,
    required String medicationId,
    String? additionalData,
  }) async {
    final String payload = jsonEncode({
      'medicationId': medicationId,
      'type': 'medication_reminder',
      'additionalData': additionalData,
    });

    final notificationId = int.parse(medicationId.hashCode.toString().substring(0, 9));

    await scheduleNotification(
      title: title,
      body: body,
      scheduledDate: scheduledDate,
      payload: payload,
      channelId: _medicationChannelId,
      id: notificationId,
    );
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Cancel specific notification
  Future<void> cancelNotification(int id) async {
    await flutterLocalNotificationsPlugin.cancel(id);
  }

  // Get pending notification requests
  Future<List<PendingNotificationRequest>> getPendingNotificationRequests() async {
    return await flutterLocalNotificationsPlugin.pendingNotificationRequests();
  }
}