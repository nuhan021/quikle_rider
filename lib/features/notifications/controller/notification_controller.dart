import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/firebase/notification_payload.dart';
import 'package:quikle_rider/core/services/firebase/notification_service.dart';

class AppNotification {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.receivedAt,
    this.payload,
    this.isUrgent = false,
    this.isRead = false,
  });

  final int id;
  final String title;
  final String body;
  final DateTime receivedAt;
  final String? payload;
  final bool isUrgent;
  final bool isRead;

  AppNotification copyWith({
    String? title,
    String? body,
    DateTime? receivedAt,
    String? payload,
    bool? isUrgent,
    bool? isRead,
  }) {
    return AppNotification(
      id: id,
      title: title ?? this.title,
      body: body ?? this.body,
      receivedAt: receivedAt ?? this.receivedAt,
      payload: payload ?? this.payload,
      isUrgent: isUrgent ?? this.isUrgent,
      isRead: isRead ?? this.isRead,
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
  bool _seeded = false;
  StreamSubscription<RemoteMessage>? _foregroundSubscription;
  StreamSubscription<RemoteMessage>? _openedAppSubscription;

  @override
  void onInit() {
    super.onInit();
    _initializeService();

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
