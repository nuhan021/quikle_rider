import 'dart:convert';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:http/http.dart' as http;
import 'package:quikle_rider/core/utils/constants/api_constants.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';

typedef NotificationTapCallback = void Function(String payload);

class NotificationService {
  NotificationService._();

  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  final http.Client _httpClient = http.Client();
  final Uri _saveTokenUri = Uri.parse('$baseurl/rider/save_token/');
  final Uri _sendNotificationUri = Uri.parse('$baseurl/rider/send_notification/');

  final AndroidNotificationChannel _defaultChannel =
      const AndroidNotificationChannel(
    'quikle_default_channel',
    'Delivery Updates',
    description: 'General updates and alerts for riders',
    importance: Importance.high,
  );

  NotificationTapCallback? _onNotificationTap;
  bool _isInitialized = false;

  Future<void> init({NotificationTapCallback? onNotificationTap}) async {
    if (_isInitialized) {
      _onNotificationTap = onNotificationTap ?? _onNotificationTap;
      return;
    }

    _onNotificationTap = onNotificationTap;
    const androidInitialization = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const iosInitialization = DarwinInitializationSettings();

    const initializationSettings = InitializationSettings(
      android: androidInitialization,
      iOS: iosInitialization,
    );

    await _plugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (response) {
        final payload = response.payload;
        if (payload != null && payload.isNotEmpty) {
          _onNotificationTap?.call(payload);
        }
      },
    );

    await _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_defaultChannel);

    _isInitialized = true;
  }

  Future<void> requestPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.requestNotificationsPermission();

    final iosPlugin = _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>();
    await iosPlugin?.requestPermissions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  Future<void> show({
    required int id,
    required String title,
    required String body,
    String? payload,
    bool isUrgent = false,
  }) async {
    final androidDetails = AndroidNotificationDetails(
      _defaultChannel.id,
      _defaultChannel.name,
      channelDescription: _defaultChannel.description,
      importance: isUrgent ? Importance.max : Importance.high,
      priority: isUrgent ? Priority.max : Priority.high,
      ticker: 'quikle_notification',
    );

    const iosDetails = DarwinNotificationDetails(
      presentAlert: true,
      presentBadge: true,
      presentSound: true,
    );

    final notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: iosDetails,
    );

    await _plugin.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  Future<void> cancel(int id) => _plugin.cancel(id);

  Future<void> cancelAll() => _plugin.cancelAll();

  Future<bool> saveFcmToken({
    required int userId,
    required String token,
    required String platform,
    required String authorization,
  }) async {
    try {
      final response = await _httpClient.post(
        _saveTokenUri,
        headers: {
          'accept': 'application/json',
          'Content-Type': 'application/json',
          'Authorization': authorization,
        },
        body: jsonEncode({
          'user_id': userId,
          'token': token,
          'platform': platform,
        }),
      );
      return response.statusCode >= 200 && response.statusCode < 300;

      
    } catch (_) {
      return false;
    }
  }

  Future<bool> sendInstantNotification({
    required int userId,
    required String title,
    required String body,
  }) async {
    try {
      final response = await _httpClient.post(
        _sendNotificationUri,
        headers: const {
          'accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          'title': title,
          'body': body,
        }),
      );
       AppLoggerHelper.debug("Notification sent $userId");
       AppLoggerHelper.debug("Notification reponse ${response.body}");
      return response.statusCode >= 200 && response.statusCode < 300;
    } catch (_) {
      return false;
    }
  }
}
