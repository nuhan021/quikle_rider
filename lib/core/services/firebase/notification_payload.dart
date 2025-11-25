import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationPayloadMapper {
  static RemoteNotificationPayload fromRemoteMessage(RemoteMessage message) {
    final notification = message.notification;
    final data = message.data;
    final title = notification?.title ?? data['title'] ?? 'New notification';
    final body = notification?.body ?? data['body'] ?? 'You have a new update';
    final payload = data['payload'] ?? data['route'];

    return RemoteNotificationPayload(
      id: _resolveId(message),
      title: title,
      body: body,
      payload: payload?.isNotEmpty == true ? payload : null,
      isUrgent: _parseUrgentFlag(data),
    );
  }

  static int _resolveId(RemoteMessage message) {
    final idFromData = message.data['notification_id'];
    if (idFromData != null) {
      final parsed = int.tryParse(idFromData);
      if (parsed != null) return parsed;
    }
    return message.messageId?.hashCode ??
        DateTime.now().millisecondsSinceEpoch.remainder(100000);
  }

  static bool _parseUrgentFlag(Map<String, dynamic> data) {
    final value = data['urgent'] ?? data['isUrgent'] ?? data['is_urgent'];
    if (value == null) return false;
    if (value is bool) return value;
    if (value is num) return value != 0;
    if (value is String) {
      final normalized = value.toLowerCase();
      return normalized == 'true' ||
          normalized == '1' ||
          normalized == 'yes' ||
          normalized == 'urgent';
    }
    return false;
  }
}

class RemoteNotificationPayload {
  const RemoteNotificationPayload({
    required this.id,
    required this.title,
    required this.body,
    this.payload,
    this.isUrgent = false,
  });

  final int id;
  final String title;
  final String body;
  final String? payload;
  final bool isUrgent;
}
