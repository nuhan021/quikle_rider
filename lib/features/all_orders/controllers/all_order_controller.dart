import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/features/all_orders/data/services/order_services.dart';
import 'package:quikle_rider/features/all_orders/models/rider_order_model.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';

class AllOrdersController extends GetxController {
  AllOrdersController({OrderServices? orderServices})
      : _orderServices = orderServices ?? OrderServices();

  final OrderServices _orderServices;

  RxBool isOnline = true.obs;
  TabController? tabController;
  RxInt selectedIndex = 0.obs;
  RxBool hasConnection = true.obs;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  Worker? _verificationWorker;

  final RxBool isOrdersLoading = false.obs;
  final RxString ordersError = ''.obs;
  final RxList<RiderOrder> orders = <RiderOrder>[].obs;
  final RxList<RiderOrder> combinedOrders = <RiderOrder>[].obs;
  final RxList<RiderOrder> singleOrders = <RiderOrder>[].obs;
  int? _pendingInitialTabIndex;
  late final ProfileController _profileController;

  bool _isCombinedOrder(RiderOrder order) {
    final type = (order.deliveryType ?? '').toLowerCase().trim();
    return order.isCombined || type == 'combined';
  }

  @override
  void onInit() {
    super.onInit();
    _profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    _verificationWorker = ever<bool?>(_profileController.isVerified, (value) {
      if (value == true && orders.isEmpty && !isOrdersLoading.value) {
        fetchOrders();
      }
    });
    _initConnectivityMonitoring();
    fetchOrders();
  }

  void toggleOnline() {
    isOnline.toggle();
  }

  void attachTabController(TabController controller) {
    tabController = controller;
    if (_pendingInitialTabIndex != null) {
      _selectTab(_pendingInitialTabIndex!);
      _pendingInitialTabIndex = null;
    }
  }

  void changeTab(int index) {
    tabController?.animateTo(index);
    selectedIndex.value = index;
  }

  Future<void> fetchOrders({int skip = 0, int limit = 10}) async {
    final isVerified = _profileController.isVerified.value == true;
    if (!isVerified) {
      ordersError.value = 'Your profile not verified.';
      orders.clear();
      combinedOrders.clear();
      singleOrders.clear();
      return;
    }

    final accessToken = StorageService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      ordersError.value = 'Missing access token. Please login again.';
      orders.clear();
      combinedOrders.clear();
      singleOrders.clear();
      return;
    }

    isOrdersLoading.value = true;
    ordersError.value = '';

    try {
      final response = await _orderServices.getOrders(
        accessToken: accessToken,
        skip: skip,
        limit: limit,
      );

      if (response.isSuccess && response.responseData is List) {
        final rawList = response.responseData as List;
        final parsedOrders = rawList
            .whereType<Map<String, dynamic>>()
            .map(RiderOrder.fromJson)
            .toList(growable: false);

        orders.assignAll(parsedOrders);
        combinedOrders.assignAll(parsedOrders.where(_isCombinedOrder));
        singleOrders.assignAll(parsedOrders.where((o) => !_isCombinedOrder(o)));

        final initialIndex =
            parsedOrders.isNotEmpty && _isCombinedOrder(parsedOrders.first)
                ? 0
                : 1;
        _selectTab(initialIndex);
      } else {
        orders.clear();
        combinedOrders.clear();
        singleOrders.clear();
        ordersError.value = response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Failed to load orders.';
      }
    } catch (_) {
      orders.clear();
      combinedOrders.clear();
      singleOrders.clear();
      ordersError.value = 'Failed to load orders.';
    } finally {
      isOrdersLoading.value = false;
    }
  }

  void _selectTab(int index) {
    if (tabController == null) {
      _pendingInitialTabIndex = index;
      selectedIndex.value = index;
      return;
    }
    if (index < 0 || index >= (tabController?.length ?? 0)) {
      return;
    }
    changeTab(index);
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
    _verificationWorker?.dispose();
    super.onClose();
  }
}
