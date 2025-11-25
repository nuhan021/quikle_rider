import 'dart:async';
import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:quikle_rider/core/services/firebase/notification_payload.dart';
import 'package:quikle_rider/core/services/firebase/notification_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:quikle_rider/firebase_options.dart';

class FirebaseService {
  FirebaseService._();

  static final FirebaseService instance = FirebaseService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  StreamSubscription<String>? _tokenRefreshSubscription;
  String? _cachedToken;

  Future<void> init() async {
    _listenToTokenRefresh();
    await _requestPermission();
    await syncToken();
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    debugPrint(
      '[FCM] Authorization status: ${settings.authorizationStatus.name}',
    );

    await _messaging.setAutoInitEnabled(true);
  }

  Future<String?> syncToken() async {
    try {
      await _waitForApnsToken();
      final token = await _messaging.getToken();
      if (token != null) {
        _cachedToken = token;
        AppLoggerHelper.debug('[FCM] Token: $token');
      } else {
        debugPrint('[FCM] Token is null (yet to be generated)');
      }
      return token;
    } on FirebaseException catch (error) {
      if (error.code == 'apns-token-not-set') {
        debugPrint(
          '[FCM] APNS token not ready yet. Waiting for token refresh callback.',
        );
        return null;
      }
      debugPrint('[FCM] Failed to fetch token: ${error.message}');
      return null;
    } catch (error) {
      debugPrint('[FCM] Failed to fetch token: $error');
      return null;
    }
  }

  Future<String?> refreshToken() => syncToken();

  String? get token => _cachedToken;

  Future<String?> waitForToken({Duration timeout = const Duration(seconds: 20)}) async {
    if (_cachedToken?.isNotEmpty ?? false) return _cachedToken;
    final completer = Completer<String?>();
    late StreamSubscription<String> subscription;
    subscription = FirebaseMessaging.instance.onTokenRefresh.listen(
      (token) {
        _cachedToken = token;
        if (!completer.isCompleted) {
          completer.complete(token);
        }
        subscription.cancel();
      },
      onError: (error) {
        if (!completer.isCompleted) {
          completer.completeError(error);
        }
      },
    );
    return completer.future.timeout(
      timeout,
      onTimeout: () {
        subscription.cancel();
        return _cachedToken;
      },
    );
  }

  Future<void> _waitForApnsToken() async {
    if (!Platform.isIOS && !Platform.isMacOS) return;
    const attempts = 6;
    for (var i = 0; i < attempts; i++) {
      final apnsToken = await _messaging.getAPNSToken();
      if (apnsToken != null && apnsToken.isNotEmpty) {
        debugPrint('[FCM] APNS token ready');
        return;
      }
      await Future.delayed(const Duration(seconds: 1));
    }
    debugPrint('[FCM] APNS token still null after waiting');
  }

  void _listenToTokenRefresh() {
    _tokenRefreshSubscription?.cancel();
    _tokenRefreshSubscription =
        FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      _cachedToken = token;
      AppLoggerHelper.debug('[FCM] Token refreshed: $token');
    });
  }
}

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService.instance.init();

  final payload = NotificationPayloadMapper.fromRemoteMessage(message);
  debugPrint('[FCM] Background message received: ${message.messageId}');

  await NotificationService.instance.show(
    id: payload.id,
    title: payload.title,
    body: payload.body,
    payload: payload.payload,
    isUrgent: payload.isUrgent,
  );
}
