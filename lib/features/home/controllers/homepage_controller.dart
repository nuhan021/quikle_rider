import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/features/home/data/home_service.dart';
import 'package:quikle_rider/features/home/models/home_dashboard_models.dart';
import 'package:quikle_rider/features/home/presentation/screen/goonline.dart';
import 'package:quikle_rider/features/home/presentation/screen/gooffline.dart';
import 'package:quikle_rider/features/home/presentation/widgets/alert_dialog.dart';
import 'package:quikle_rider/features/home/presentation/widgets/incoming_assignment_dialog.dart';
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
  final popupAssignment = Rxn<Assignment>();
  final HomeService _homeService;

  Timer? _incomingAssignmentTimer;
  Timer? _dialogAutoCloseTimer;
  int _assignmentSequence = 6000;
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
    isLoading.value = true;
    errorMessage.value = null;
    try {
      final data = await _loadDashboardData();
      stats.assignAll(data.stats);
      assignments.assignAll(data.assignments);
    } catch (error) {
      errorMessage.value = 'Unable to load dashboard data. Please try again.';
    } finally {
      isLoading.value = false;
    }
  }

  Future<HomeDashboardData> _loadDashboardData() async {
    await Future.delayed(const Duration(milliseconds: 400));
    return HomeDashboardData(
      stats: const [
        HomeStat(
          id: 'today-deliveries',
          title: 'Today',
          subtitle: 'Deliveries',
          value: 5,
        ),
        HomeStat(
          id: 'weekly-deliveries',
          title: 'This Week',
          subtitle: 'Deliveries',
          value: 32,
        ),
        HomeStat(
          id: 'rating',
          title: 'Rating',
          subtitle: 'Out of 5',
          value: 4.8,
        ),
      ],
      assignments: [
        Assignment(
          id: '#5678',
          customerName: 'Aanya Desai',
          expectedArrival: DateTime.now().add(const Duration(hours: 1)),
          address: '456 Oak Ave, Downtown',
          distanceInKm: 4.0,
          totalAmount: 34,
          basePay: 20,
          distancePay: 14,
          orderType: 'Grocery',
          currency: '₹',
          isUrgent: true,
          isCombined: true,
          tierLabel: 'Bronze Tier Rate',
        ),
        Assignment(
          id: '#5677',
          customerName: 'Rahul Verma',
          expectedArrival: DateTime.now().add(const Duration(hours: 3)),
          address: '89 Lake View Road, Uptown',
          distanceInKm: 2.5,
          totalAmount: 28,
          basePay: 18,
          distancePay: 10,
          orderType: 'Pharmacy',
          currency: '₹',
          isUrgent: false,
          isCombined: false,
          status: AssignmentStatus.accepted,
        ),
        Assignment(
          id: '#5676',
          customerName: 'Neha Kapoor',
          expectedArrival: DateTime.now().add(const Duration(hours: 5)),
          address: '12 Garden Blvd, Midtown',
          distanceInKm: 5.4,
          totalAmount: 48,
          basePay: 30,
          distancePay: 18,
          orderType: 'Grocery',
          currency: '₹',
          isUrgent: false,
          isCombined: true,
          status: AssignmentStatus.rejected,
        ),
      ],
    );
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
          _scheduleIncomingAssignment();
        } else {
          _cancelIncomingAssignment();
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

  void _scheduleIncomingAssignment() {
    _incomingAssignmentTimer?.cancel();
    _incomingAssignmentTimer = Timer(
      const Duration(seconds: 200000),
      _presentIncomingAssignment,
    );
  }

  void _cancelIncomingAssignment() {
    _incomingAssignmentTimer?.cancel();
    _incomingAssignmentTimer = null;
    _dialogAutoCloseTimer?.cancel();
    _dialogAutoCloseTimer = null;
    popupAssignment.value = null;
    if (Get.isDialogOpen ?? false) {
      Get.back();
    }
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

  Assignment _createIncomingAssignment() {
    _assignmentSequence += 1;
    final now = DateTime.now();
    final arrival = now.add(const Duration(minutes: 30));

    return Assignment(
      id: '#$_assignmentSequence',
      customerName: 'Priya Sharma',
      expectedArrival: arrival,
      address: '221B Baker St, Park Town',
      distanceInKm: 4.2,
      totalAmount: 42,
      currency: '₹',
      basePay: 28,
      distancePay: 14,
      orderType: 'Grocery',
      isUrgent: true,
      isCombined: false,
    );
  }

  Future<void> _presentIncomingAssignment() async {
    final assignment = _createIncomingAssignment();
    popupAssignment.value = assignment;

    _dialogAutoCloseTimer?.cancel();
    _dialogAutoCloseTimer = Timer(const Duration(seconds: 10), () {
      if (Get.isDialogOpen ?? false) {
        Get.back();
      }
    });

    final status = await Get.dialog<AssignmentStatus>(
      IncomingAssignmentDialog(
        assignment: assignment,
        onAccept: () => Get.back(result: AssignmentStatus.accepted),
        onReject: () => Get.back(result: AssignmentStatus.rejected),
      ),
      barrierDismissible: false,
    );

    _dialogAutoCloseTimer?.cancel();
    _dialogAutoCloseTimer = null;
    popupAssignment.value = null;

    await _handleIncomingAssignmentResult(assignment, status);

    if (isOnline.value) {
      _scheduleIncomingAssignment();
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

  Future<void> _handleIncomingAssignmentResult(
    Assignment assignment,
    AssignmentStatus? status,
  ) async {
    switch (status) {
      case AssignmentStatus.accepted:
        final success = await acceptAssignment(assignment);
        if (success) {
          // Show dialog
          Get.dialog(
            OrderStatusDialog(
              imageUrl: "assets/images/success.png",
              text: "Order Accepted",
            ),
            barrierDismissible: false,
          );

          // Auto close after 1s
          Future.delayed(const Duration(seconds: 1), () {
            if (Get.isDialogOpen ?? false) Get.back();
          });
        }
        break;

      case AssignmentStatus.rejected:
        final success = await rejectAssignment(assignment);
        if (success) {
          Get.dialog(
            OrderStatusDialog(
              imageUrl: "assets/images/cancel.png",
              text: "Order Rejected",
            ),
            barrierDismissible: false,
          );

          Future.delayed(const Duration(seconds: 1), () {
            if (Get.isDialogOpen ?? false) Get.back();
          });
        }
        break;

      case AssignmentStatus.pending:
      case null:
        _setAssignmentStatus(assignment, AssignmentStatus.pending);
        break;
    }
  }

  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    _cancelIncomingAssignment();
    super.onClose();
  }
}
