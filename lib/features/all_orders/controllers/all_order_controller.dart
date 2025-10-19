import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class AllOrdersController extends GetxController {
  RxBool isOnline = true.obs;
  late TabController tabController;
  RxInt selectedIndex = 0.obs;
  RxBool hasConnection = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    _initConnectivityMonitoring();
  }

  void toggleOnline() {
    isOnline.toggle();
  }

  void changeTab(int index) {
    tabController.animateTo(index);
    selectedIndex.value = index;
  }

  void _initConnectivityMonitoring() {
    final connectivity = Connectivity();
    _connectivitySubscription =
        connectivity.onConnectivityChanged.listen(_updateConnectionStatus);
    connectivity.checkConnectivity().then(_updateConnectionStatus).catchError(
      (_) => hasConnection.value = true,
    );
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    hasConnection.value =
        results.any((result) => result != ConnectivityResult.none);
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }
}
