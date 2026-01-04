import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import 'package:quikle_rider/core/services/network/internet_services.dart';
import 'package:quikle_rider/core/services/firebase/firebase_service.dart';
import 'package:quikle_rider/core/services/firebase/notification_service.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:quikle_rider/features/home/data/home_service.dart';
import 'package:quikle_rider/features/home/models/home_dashboard_models.dart';
import 'package:quikle_rider/features/home/presentation/screen/goonline.dart';
import 'package:quikle_rider/features/home/presentation/screen/gooffline.dart';
import 'package:quikle_rider/custom_tab_bar/notifications.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:quikle_rider/routes/app_routes.dart';

class HomepageController extends GetxController {
  HomepageController({
    HomeService? homeService,
    
    InternetServices? internetServices,
  }) : _homeService = homeService ?? HomeService(),
       _internetServices = internetServices ?? InternetServices();

  var isOnline = false.obs;
  var isLoading = false.obs;
  final errorMessage = RxnString();
  final stats = <HomeStat>[].obs;
  final assignments = <Assignment>[].obs;
  final _pendingActions = <String>{}.obs;
  final HomeService _homeService;
  final InternetServices _internetServices;
  late final ProfileController _profileController;

  RxBool get hasConnection => _internetServices.hasConnection;

  Future<void> onToggleSwitch() async {
    if (!isOnline.value) {
      final isVerified = _profileController.isVerifiedApproved;
      if (!isVerified) {
        Get.snackbar(
          '',
          '',
          colorText: Colors.white,

          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.black,
          margin: const EdgeInsets.all(16),
          borderRadius: 14,
          duration: const Duration(seconds: 4),
          snackStyle: SnackStyle.FLOATING,

          // 🔽 this reduces snackbar height
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),

          messageText: Row(
            children: [
              const Icon(
                Icons.verified_outlined,
                color: Colors.amber,
                size: 18, // slightly smaller
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Get your account verified to receive orders',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Get.toNamed(AppRoute.uploaddocuments),
                style: TextButton.styleFrom(
                  backgroundColor: Colors.amber,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ), // 🔽
                  minimumSize: Size.zero, // important
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'Verify',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        );

        return;
      }
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

  Future<void> onToggleSwitchAndSyncToken() async {
    final wasOnline = isOnline.value;
    await onToggleSwitch();
    if (!wasOnline && isOnline.value) {
      await _syncFcmTokenForOnline();

    }
  }

  void openNotifications() {
    HapticFeedback.lightImpact();
    Get.to(() => const NotificationsPage(), transition: Transition.fadeIn);
  }

  @override
  void onInit() {
    super.onInit();
    _profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    _internetServices.startMonitoring(onReconnect: _handleReconnect);
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
    final response = await _homeService.fetchOfferedOrders();
    if (!response.isSuccess) {
      throw response.errorMessage.isNotEmpty
          ? response.errorMessage
          : 'Unable to load offered orders.';
    }

    final mapped = _mapAssignmentsResponse(response.responseData);

    return mapped
        .map(
          (assignment) => assignment.copyWith(status: AssignmentStatus.pending),
        )
        .toList();
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
        final response = await _homeService.acceptOfferedOrder(
          orderId: assignment.id,
        );
        if (!response.isSuccess) {
          _showStatusSnack(
            duration: 3,

            title: 'Accept failed',
            message: response.errorMessage.isNotEmpty
                ? response.errorMessage
                : 'Unable to accept order. Please try again.',
            success: false,
          );
        }
        return response.isSuccess;
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
        final response = await _homeService.rejectOfferedOrder(
          orderId: assignment.id,
          reason: 'string',
        );
        if (!response.isSuccess) {
          _showStatusSnack(
            duration: 3,
            title: 'Reject failed',
            message: response.errorMessage.isNotEmpty
                ? response.errorMessage
                : 'Unable to reject order. Please try again.',
            success: false,
          );
        }
        return response.isSuccess;
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
      final response = await _homeService.toggleOnlineStatus(
        isOnline: goOnline,
      );
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
          duration: 3,
          title: 'Status updated',
          message: message,
          success: true,
        );
      } else {
        _showStatusSnack(
          duration: 3,
          title: 'Update failed',
          message: response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Unable to update status. Please try again.',
          success: false,
        );
      }
    } catch (error) {
      _showStatusSnack(
        duration: 3,
        title: 'Update failed',
        message: 'Unable to update status. Please try again.',
        success: false,
      );
    }
  }

  Future<void> _syncFcmTokenForOnline() async {
    try {
      final userId = StorageService.userId;
      final accessToken = StorageService.accessToken;
      if (userId == null || accessToken == null || accessToken.isEmpty) {
        AppLoggerHelper.debug('FCM sync skipped: missing user or token.');
        return;
      }

      final refreshedToken = await FirebaseService.instance.refreshToken();
      final cachedToken = StorageService.cachedFcmToken;
      final token = refreshedToken?.isNotEmpty == true
          ? refreshedToken
          : cachedToken?.isNotEmpty == true
          ? cachedToken
          : await FirebaseService.instance.waitForToken();

      if (token == null || token.isEmpty) {
        AppLoggerHelper.debug('FCM sync skipped: token unavailable.');
        return;
      }

      await StorageService.cacheFcmToken(token);
      final tokenType = (StorageService.tokenType ?? '').trim();
      final platform = Platform.isIOS
          ? 'ios'
          : Platform.isAndroid
          ? 'android'
          : Platform.operatingSystem;

      final success = await NotificationService.instance.saveFcmToken(
        userId: userId,
        token: token,
        platform: platform,
        authorization:
            '${tokenType.isEmpty ? 'Bearer' : tokenType} $accessToken',
      );

      AppLoggerHelper.debug(
        success
            ? 'FCM token synced on go-online.$userId'
            : 'FCM token sync failed on go-online.',
      );
    } catch (error) {
      AppLoggerHelper.debug('FCM sync failed on go-online: $error');
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
    required int duration,
  }) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: success ? Colors.green : Colors.redAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: Duration(seconds: duration),
    );
  }

  void _handleReconnect() {
    if (stats.isEmpty && !isLoading.value) {
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
    _internetServices.dispose();
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
