import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/features/home/data/home_service.dart';
import 'package:quikle_rider/features/home/models/home_dashboard_models.dart';
import 'package:quikle_rider/features/home/presentation/screen/goonline.dart';
import 'package:quikle_rider/features/home/presentation/screen/gooffline.dart';
import 'package:quikle_rider/custom_tab_bar/notifications.dart';

class HomepageController extends GetxController {
  HomepageController({HomeService? homeService})
      : _homeService = homeService ?? HomeService();

  var isOnline = false.obs;
  var isLoading = false.obs;
  final hasConnection = true.obs;
  final errorMessage = RxnString();
  final stats = <HomeStat>[].obs;
  final assignments = <Assignment>[].obs;
  final _pendingActions = <String>{}.obs;
  final HomeService _homeService;

  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  void onToggleSwitch() async {
    if (!isOnline.value) {
      final result = await Get.to(
        () => const GoOnlinePage(),
        opaque: false,
        fullscreenDialog: true,
        transition: Transition.fade,
      );
      if (result == true) {
        await _changeOnlineStatus(true);
      }
    } else {
      final result = await Get.to(
        () => const GoOfflinePage(),
        opaque: false,
        fullscreenDialog: true,
        transition: Transition.fade,
      );
      if (result == true) {
        await _changeOnlineStatus(false);
      }
    }
  }

  void openNotifications() {
    HapticFeedback.lightImpact();
    Get.to(() => const NotificationsPage(), transition: Transition.fadeIn);
  }

  @override
  void onInit() {
    super.onInit();
    _initConnectivityMonitoring();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    await _refreshUpcomingAssignments(showLoader: true);
  }

  Future<HomeDashboardData> _loadDashboardData() async {
    final upcomingAssignments = await _fetchUpcomingAssignments();
    return HomeDashboardData(
      stats: _buildStats(upcomingAssignments),
      assignments: upcomingAssignments,
    );
  }

  Future<List<Assignment>> _fetchUpcomingAssignments() async {
    final response = await _homeService.fetchUpcomingOrders(orderId: "ORD_C87381CD");
    if (!response.isSuccess) {
      throw response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Unable to load upcoming orders.';
    }

    return _mapAssignmentsResponse(response.responseData);
  }

  List<HomeStat> _buildStats(List<Assignment> upcomingAssignments) {
    final totalPayout = upcomingAssignments.fold<double>(
      0,
      (previousValue, assignment) => previousValue + assignment.totalAmount,
    );

    return [
      HomeStat(
        id: 'upcoming',
        title: 'Upcoming',
        subtitle: 'Orders',
        value: upcomingAssignments.length,
      ),
      HomeStat(
        id: 'payout',
        title: 'Payout',
        subtitle: 'Potential',
        value: totalPayout,
        unit: '₹',
      ),
      const HomeStat(
        id: 'rating',
        title: 'Rating',
        subtitle: 'Out of 5',
        value: 4.8,
      ),
    ];
  }

  Future<void> _refreshUpcomingAssignments({bool showLoader = false}) async {
    if (showLoader) {
      isLoading.value = true;
      errorMessage.value = null;
    }

    try {
      final data = await _loadDashboardData();
      stats.assignAll(data.stats);
      assignments.assignAll(data.assignments);
    } catch (error) {
      if (showLoader) {
        errorMessage.value = error is String
            ? error
            : 'Unable to load upcoming orders. Please try again.';
      }
    } finally {
      if (showLoader) {
        isLoading.value = false;
      }
    }
  }

  bool isAssignmentActionPending(String assignmentId) =>
      _pendingActions.contains(assignmentId);

  Future<bool> acceptAssignment(Assignment assignment) async {
    final result = await _performAssignmentAction(
      assignmentId: assignment.id,
      action: () async {
        await Future.delayed(const Duration(milliseconds: 350));
        return true;
      },
    );
    if (result) {
      _setAssignmentStatus(assignment, AssignmentStatus.accepted);
    }
    return result;
  }

  Future<bool> rejectAssignment(Assignment assignment) async {
    final result = await _performAssignmentAction(
      assignmentId: assignment.id,
      action: () async {
        await Future.delayed(const Duration(milliseconds: 350));
        return true;
      },
    );
    if (result) {
      _setAssignmentStatus(assignment, AssignmentStatus.rejected);
    }
    return result;
  }

  Future<bool> _performAssignmentAction({
    required String assignmentId,
    required Future<bool> Function() action,
  }) async {
    if (_pendingActions.contains(assignmentId)) return false;
    _pendingActions.add(assignmentId);
    try {
      final result = await action();
      return result;
    } finally {
      _pendingActions.remove(assignmentId);
    }
  }

  Future<void> _changeOnlineStatus(bool goOnline) async {
    try {
      final response =
          await _homeService.toggleOnlineStatus(isOnline: goOnline);
      if (response.isSuccess) {
        isOnline.value = goOnline;
        if (goOnline) {
          await _refreshUpcomingAssignments(showLoader: true);
        } else {
          stats.clear();
          assignments.clear();
        }
        final message = _extractStatusMessage(response.responseData, goOnline);
        _showStatusSnack(
          title: 'Status updated',
          message: message,
          success: true,
        );
      } else {
        _showStatusSnack(
          title: 'Update failed',
          message: response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Unable to update status. Please try again.',
          success: false,
        );
      }
    } catch (error) {
      _showStatusSnack(
        title: 'Update failed',
        message: 'Unable to update status. Please try again.',
        success: false,
      );
    }
  }

  String _extractStatusMessage(dynamic data, bool goOnline) {
    if (data is Map<String, dynamic>) {
      final message = data['message'] ?? data['hint'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
    } else if (data is String && data.isNotEmpty) {
      return data;
    }
    return goOnline ? 'Rider is now online' : 'Rider is now offline';
  }

  void _showStatusSnack({
    required String title,
    required String message,
    required bool success,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: success ? Colors.green : Colors.redAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 3),
    );
  }

  void _initConnectivityMonitoring() {
    final connectivity = Connectivity();
    _connectivitySubscription = connectivity.onConnectivityChanged.listen(
      _updateConnectionStatus,
    );
    connectivity
        .checkConnectivity()
        .then(_updateConnectionStatus)
        .catchError((_) => hasConnection.value = true);
  }

  void _updateConnectionStatus(List<ConnectivityResult> results) {
    final isConnected = results.any(
      (result) => result != ConnectivityResult.none,
    );
    final previousState = hasConnection.value;
    hasConnection.value = isConnected;

    if (isConnected && !previousState && stats.isEmpty && !isLoading.value) {
      fetchDashboardData();
    }
  }

  void _setAssignmentStatus(Assignment assignment, AssignmentStatus status) {
    final updated = assignment.copyWith(status: status);
    final idx = assignments.indexWhere((item) => item.id == assignment.id);
    if (idx == -1) {
      assignments.insert(0, updated);
    } else {
      assignments[idx] = updated;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  List<Assignment> _mapAssignmentsResponse(dynamic data) {
    if (data is List) {
      return data
          .whereType<Map<String, dynamic>>()
          .map(Assignment.fromUpcomingOrderJson)
          .toList();
    }

    if (data is Map<String, dynamic>) {
      if (data['results'] is List) {
        final results = data['results'] as List<dynamic>;
        return results
            .whereType<Map<String, dynamic>>()
            .map(Assignment.fromUpcomingOrderJson)
            .toList();
      }

      if (data['orders'] is List) {
        final orders = data['orders'] as List<dynamic>;
        return orders
            .whereType<Map<String, dynamic>>()
            .map(Assignment.fromUpcomingOrderJson)
            .toList();
      }

      return [Assignment.fromUpcomingOrderJson(data)];
    }

    return [];
  }
}
