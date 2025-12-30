import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class InternetServices {
  InternetServices({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  final Connectivity _connectivity;
  final RxBool hasConnection = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  void startMonitoring({VoidCallback? onReconnect}) {
    _connectivitySubscription ??=
        _connectivity.onConnectivityChanged.listen((results) {
      _updateConnectionStatus(results, onReconnect: onReconnect);
    });
    _connectivity
        .checkConnectivity()
        .then((results) => _updateConnectionStatus(results,
            onReconnect: onReconnect))
        .catchError((_) => hasConnection.value = true);
  }

  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  void _updateConnectionStatus(
    List<ConnectivityResult> results, {
    VoidCallback? onReconnect,
  }) {
    final isConnected =
        results.any((result) => result != ConnectivityResult.none);
    final previousState = hasConnection.value;
    hasConnection.value = isConnected;

    if (isConnected && !previousState) {
      onReconnect?.call();
    }
  }
}
