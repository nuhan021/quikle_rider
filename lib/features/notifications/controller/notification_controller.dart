import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/firebase/notification_payload.dart';
import 'package:quikle_rider/core/services/firebase/notification_service.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.payload,
    this.isUrgent = false,
    this.isRead = false,
    this.remoteId,
    this.userId,
  });

  final int id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final String? payload;
  final bool isUrgent;
  final bool isRead;
  final String? remoteId;
  final int? userId;

  AppNotification copyWith({
    String? title,
    String? body,
    DateTime? receivedAt,
    String? payload,
    bool? isUrgent,
    bool? isRead,
    String? remoteId,
    int? userId,
  }) {
    return AppNotification(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      payload: payload ?? this.payload,
      isUrgent: isUrgent ?? this.isUrgent,
      isRead: isRead ?? this.isRead,
      remoteId: remoteId ?? this.remoteId,
      userId: userId ?? this.userId,
    );
  }

  String get timeAgo {
    final difference = DateTime.now().difference(receivedAt);
    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min ago';
    if (difference.inHours < 24) return '${difference.inHours} hr ago';
    return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
  }
}

class NotificationController extends GetxController {
  NotificationController({
    NotificationService? notificationService,
  }) : _notificationService = notificationService ?? NotificationService.instance;

  static NotificationController get to => Get.find<NotificationController>();

  final NotificationService _notificationService;
  final RxList<AppNotification> notifications = <AppNotification>[].obs;
  final RxBool isLoading = false.obs;
  final RxnString errorMessage = RxnString();
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeService();
    unawaited(fetchNotifications());
  }

  @override
  void onClose() {
    _foregroundSubscription?.cancel();
    _openedAppSubscription?.cancel();
    super.onClose();
  }

  Future<void> _initializeService() async {
    await _notificationService.init(onNotificationTap: handleNotificationTap);
    _listenToFirebaseMessages();
  }

  Future<void> fetchNotifications({bool showLoader = true}) async {
    if (isLoading.value) return;

    final accessToken = StorageService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      errorMessage.value = 'Please log in to view notifications.';
      return;
    }

    final authorization = _buildAuthorizationHeader(accessToken);

    if (showLoader) {
      isLoading.value = true;
    }
    errorMessage.value = null;

    try {
      final response = await _notificationService.getNotifications(
        authorization: authorization,
      );

      if (response.isSuccess) {
        final mapped = _mapApiNotifications(response.responseData);
        notifications.assignAll(mapped);
      } else {
        final message = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to load notifications.';
        errorMessage.value = message;
        AppLoggerHelper.debug('Notifications fetch failed: $message');
      }
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }

  void _listenToFirebaseMessages() {
    _foregroundSubscription?.cancel();
    _openedAppSubscription?.cancel();

    _foregroundSubscription = FirebaseMessaging.onMessage.listen(
      (message) {
        final payload = NotificationPayloadMapper.fromRemoteMessage(message);
        unawaited(
          addNotification(
            title: payload.title,
            body: payload.body,
            isUrgent: payload.isUrgent,
            payload: payload.payload,
          ),
        );
      },
    );

    _openedAppSubscription = FirebaseMessaging.onMessageOpenedApp.listen(
      (message) {
        final payload = NotificationPayloadMapper.fromRemoteMessage(message);
        unawaited(
          addNotification(
            title: payload.title,
            body: payload.body,
            isUrgent: payload.isUrgent,
            payload: payload.payload,
            silent: true,
          ),
        );
        final route = payload.payload;
        if (route != null && route.isNotEmpty) {
          handleNotificationTap(route);
        }
      },
    );

    FirebaseMessaging.instance.getInitialMessage().then((message) {
      if (message == null) return;
      final payload = NotificationPayloadMapper.fromRemoteMessage(message);
      unawaited(
        addNotification(
          title: payload.title,
          body: payload.body,
          isUrgent: payload.isUrgent,
          payload: payload.payload,
          silent: true,
        ),
      );
      final route = payload.payload;
      if (route != null && route.isNotEmpty) {
        Future.delayed(const Duration(milliseconds: 300), () {
          handleNotificationTap(route);
        });
      }
    });
  }

  List<AppNotification> _mapApiNotifications(dynamic data) {
    if (data is! List) {
      AppLoggerHelper.debug('Notifications response is not a list.');
      return [];
    }

    final items = <AppNotification>[];
    for (final entry in data) {
      if (entry is Map) {
        final mapped = _parseApiNotification(
          Map<String, dynamic>.from(entry),
        );
        if (mapped != null) {
          items.add(mapped);
        }
      }
    }

    items.sort((a, b) => b.receivedAt.compareTo(a.receivedAt));
    return items;
  }

  AppNotification? _parseApiNotification(Map<String, dynamic> json) {
    final title = json['title']?.toString().trim();
    final body = json['body']?.toString().trim();
    final receivedAt = _parseDate(json['created_at']);
    final remoteId = json['id']?.toString();
    final payload = json['payload']?.toString() ?? json['route']?.toString();

    return AppNotification(
      id: _generateLocalId(remoteId, receivedAt),
      title: title != null && title.isNotEmpty ? title : 'Notification',
      body: body ?? '',
      receivedAt: receivedAt,
      payload: payload != null && payload.isNotEmpty ? payload : null,
      isRead: _parseBool(json['is_read']),
      isUrgent: _parseBool(json['is_urgent'] ?? json['urgent']),
      remoteId: remoteId,
      userId: _parseInt(json['user_id']),
    );
  }

  String _buildAuthorizationHeader(String accessToken) {
    final tokenType = StorageService.tokenType;
    final normalized = tokenType?.trim();
    final resolvedType =
        normalized == null || normalized.isEmpty ? 'Bearer' : normalized;
    return '$resolvedType $accessToken';
  }

  DateTime _parseDate(dynamic value) {
    final raw = value?.toString();
    if (raw == null || raw.isEmpty) return DateTime.now();
    final parsed = DateTime.tryParse(raw);
    return parsed?.toLocal() ?? DateTime.now();
  }

  bool _parseBool(dynamic value) {
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

  int? _parseInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }

  int _generateLocalId(String? remoteId, DateTime receivedAt) {
    if (remoteId != null && remoteId.isNotEmpty) {
      return remoteId.hashCode & 0x7fffffff;
    }
    return receivedAt.millisecondsSinceEpoch.remainder(0x7fffffff);
  }

  Future<AppNotification> addNotification({
    required String title,
    required String body,
    bool isUrgent = false,
    String? payload,
    bool silent = false,
  }) async {
    final notification = AppNotification(
      id: DateTime.now().millisecondsSinceEpoch.remainder(1000000),
      title: title,
      body: body,
      receivedAt: DateTime.now(),
      isUrgent: isUrgent,
      payload: payload,
    );

    notifications.insert(0, notification);

    if (!silent) {
      await _notificationService.show(
        id: notification.id,
        title: notification.title,
        body: notification.body,
        payload: notification.payload,
        isUrgent: notification.isUrgent,
      );
    }

    return notification;
  }

  void removeNotification(int id) {
    notifications.removeWhere((item) => item.id == id);
    _notificationService.cancel(id);
  }

  void markAsRead(int id) {
    final index = notifications.indexWhere((item) => item.id == id);
    if (index == -1) return;
    notifications[index] = notifications[index].copyWith(isRead: true);
  }

  void markAllAsRead() {
    notifications.value = notifications
        .map((notification) => notification.copyWith(isRead: true))
        .toList();
  }

  bool get hasUnread => notifications.any((notification) => !notification.isRead);

  void openNotification(AppNotification notification) {
    markAsRead(notification.id);
    final destination = notification.payload;
    if (destination != null && destination.isNotEmpty) {
      _openRoute(destination);
    }
  }

  void handleNotificationTap(String payload) {
    if (payload.isEmpty) return;
    _openRoute(payload);
  }

  void _openRoute(String route) {
    try {
      Get.toNamed(route);
    } catch (error) {
      debugPrint('Navigation failed for $route: $error');
    }
  }
}
