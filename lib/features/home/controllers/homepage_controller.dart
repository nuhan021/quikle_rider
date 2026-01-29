import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/location_services.dart';
import 'package:quikle_rider/core/services/network/internet_services.dart';
import 'package:quikle_rider/core/services/firebase/firebase_service.dart';
import 'package:quikle_rider/core/services/firebase/notification_service.dart';
import 'package:quikle_rider/core/services/network/webscoket_services.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:quikle_rider/features/home/data/home_service.dart';
import 'package:quikle_rider/features/home/models/home_dashboard_models.dart';
import 'package:quikle_rider/features/home/presentation/screen/goonline.dart';
import 'package:quikle_rider/features/home/presentation/screen/gooffline.dart';
import 'package:quikle_rider/custom_tab_bar/notifications.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:quikle_rider/features/profile/data/services/profile_services.dart';
import 'package:quikle_rider/routes/app_routes.dart';

class HomepageController extends GetxController {
  HomepageController({
    HomeService? homeService,

    InternetServices? internetServices,
    ProfileServices? profileServices,
  }) : _homeService = homeService ?? HomeService(),
       _internetServices = internetServices ?? InternetServices();

  var isOnline = false.obs;
  var isLoading = false.obs;
  var isAssignmentsLoading = false.obs;
  var isFetchingMoreAssignments = false.obs;
  var hasMoreAssignments = true.obs;
  final errorMessage = RxnString();
  final stats = <HomeStat>[].obs;
  final assignments = <Assignment>[].obs;
  final _pendingActions = <String>{}.obs;
  static const int _assignmentsPageSize = 3;
  int _assignmentsOffset = 0;
  final HomeService _homeService;
  final InternetServices _internetServices;
  late final ProfileController _profileController;

  RxBool get hasConnection => _internetServices.hasConnection;
  final LocationServices locationServices = LocationServices.instance;
  final NotificationWebSocketService _notificationSocket =
      NotificationWebSocketService();
  StreamSubscription<Map<String, dynamic>>? _notificationSubscription;
  final Rxn<IncomingOrderNotification> incomingOffer =
      Rxn<IncomingOrderNotification>();
  String? _lastNotificationId;

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
      isOnline.value = true;
      final result = await Get.to(
        () => const GoOnlinePage(),
        opaque: false,
        fullscreenDialog: true,
        transition: Transition.fade,
      );
      if (result == true) {
        unawaited(_changeOnlineStatus(true));
        // await _refreshUpcomingAssignments(assignmentsOnly: true,showLoader: false);
        locationServices.connectAndStart();
        _connectNotificationSocket();
      } else {
        isOnline.value = false;
        stats.clear();
        assignments.clear();
      }
    } else {
      final result = await Get.to(
        () => const GoOfflinePage(),
        opaque: false,
        fullscreenDialog: true,
        transition: Transition.fade,
      );
      if (result == true) {
        isOnline.value = false;
        stats.clear();
        assignments.clear();
        _disconnectNotificationSocket();
        unawaited(_changeOnlineStatus(false));
      }
    }
  }

  void openNotifications() {
    HapticFeedback.lightImpact();
    Get.to(() => const NotificationsPage(), transition: Transition.fadeIn);
  }

  @override
  void onInit() async {
    super.onInit();
    _profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    _internetServices.startMonitoring(onReconnect: _handleReconnect);
    unawaited(
      Future.wait([
        _syncOnlineStatus(),
        _profileController.fetchAvailabilitySettings(),
        fetchDashboardData(),
        _syncFcmToken(),
        _syncOnlineStatus(),
      ]),
    );
  }

  Future<void> _syncOnlineStatus() async {
    final accessToken = StorageService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      AppLoggerHelper.debug('Online status sync skipped: missing access token.');
      return;
    }

    final response = await _homeService.getOnlineStatus(
      accessToken: accessToken,
    );
    if (!response.isSuccess || response.responseData is! Map<String, dynamic>) {
      AppLoggerHelper.debug(
        'Online status sync failed. Status: ${response.statusCode}',
      );
      return;
    }

    final data = response.responseData as Map<String, dynamic>;
    final online = data['is_online'] == true;
    if (online) {
      isOnline.value = true;
      unawaited(_refreshUpcomingAssignments(assignmentsOnly: true));
      locationServices.connectAndStart();
      _connectNotificationSocket();
    }
  }

  Future<void> fetchDashboardData() async {
    await _refreshUpcomingAssignments(assignmentsOnly: true);
  }

  Future<void> refreshUpcomingAssignments() async {
    await _refreshUpcomingAssignments(assignmentsOnly: true);
  }

  Future<HomeDashboardData> _loadDashboardData({
    int offset = 0,
    int limit = _assignmentsPageSize,
  }) async {
    final upcomingAssignments = await _fetchUpcomingAssignments(
      offset: offset,
      limit: limit,
    );
    return HomeDashboardData(
      stats: _buildStats(upcomingAssignments),
      assignments: upcomingAssignments,
    );
  }

  Future<List<Assignment>> _fetchUpcomingAssignments({
    int offset = 0,
    int limit = _assignmentsPageSize,
  }) async {
    final response = await _homeService.fetchOfferedOrders(
      offset: offset,
      limit: limit,
    );
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

  void _updateStatsFromAssignments() {
    final updated = _buildStats(assignments);
    stats.assignAll(updated);
  }

  Future<void> _refreshUpcomingAssignments({
    bool showLoader = false,
    bool assignmentsOnly = false,
  }) async {
    if (showLoader) {
      isLoading.value = true;
    }
    if (assignmentsOnly) {
      isAssignmentsLoading.value = true;
    }
    errorMessage.value = null;

    try {
      _assignmentsOffset = 0;
      hasMoreAssignments.value = true;
      assignments.clear();
      final data = await _loadDashboardData(
        offset: _assignmentsOffset,
        limit: _assignmentsPageSize,
      );
      stats.assignAll(data.stats);
      assignments.assignAll(data.assignments);
      _assignmentsOffset = assignments.length;
      if (data.assignments.length < _assignmentsPageSize) {
        hasMoreAssignments.value = false;
      }
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
      if (assignmentsOnly) {
        isAssignmentsLoading.value = false;
      }
    }
  }

  Future<void> loadMoreAssignments() async {
    if (isFetchingMoreAssignments.value || !hasMoreAssignments.value) return;
    isFetchingMoreAssignments.value = true;
    try {
      final next = await _fetchUpcomingAssignments(
        offset: _assignmentsOffset,
        limit: _assignmentsPageSize,
      );
      if (next.isEmpty) {
        hasMoreAssignments.value = false;
      } else {
        assignments.addAll(next);
        _assignmentsOffset += next.length;
        _updateStatsFromAssignments();
        if (next.length < _assignmentsPageSize) {
          hasMoreAssignments.value = false;
        }
      }
    } catch (_) {
      // keep hasMoreAssignments as-is on failure
    } finally {
      isFetchingMoreAssignments.value = false;
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
      await refreshUpcomingAssignments();
    }
    return result;
  }

  Future<bool> rejectAssignment(Assignment assignment) async {
    final result = await _performAssignmentAction(
      assignmentId: assignment.id,
      action: () async {
        final response = await _homeService.rejectOfferedOrder(
          orderId: assignment.id,
          reason: 'Order Rejected',
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

  Future<bool> acceptAssignmentById(String orderId) async {
    final trimmedId = orderId.trim();
    if (trimmedId.isEmpty) return false;
    final result = await _performAssignmentAction(
      assignmentId: trimmedId,
      action: () async {
        final response = await _homeService.acceptOfferedOrder(
          orderId: trimmedId,
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
      await refreshUpcomingAssignments();
    }
    return result;
  }

  Future<bool> rejectAssignmentById(String orderId) async {
    final trimmedId = orderId.trim();
    if (trimmedId.isEmpty) return false;
    final result = await _performAssignmentAction(
      assignmentId: trimmedId,
      action: () async {
        final response = await _homeService.rejectOfferedOrder(
          orderId: trimmedId,
          reason: 'Order Rejected',
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
      _setAssignmentStatusById(trimmedId, AssignmentStatus.rejected);
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
          unawaited(_refreshUpcomingAssignments(assignmentsOnly: true));
          _connectNotificationSocket();
        } else {
          stats.clear();
          assignments.clear();
          _disconnectNotificationSocket();
        }
        // final message = _extractStatusMessage(response.responseData, goOnline);
        // _showStatusSnack(
        //   duration: 1,
        //   title: '',
        //   message: message,
        //   success: true,
        // );
      } else {
        _showStatusSnack(
          duration: 1,
          title: '',
          message: response.errorMessage.isNotEmpty
              ? response.errorMessage
              : 'Unable to update status. Please try again.',
          success: false,
        );
      }
    } catch (error) {
      _showStatusSnack(
        duration: 1,
        title: '',
        message: 'Unable to update status. Please try again.',
        success: false,
      );
    }
  }

  Future<void> _syncFcmToken() async {
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
            ? 'FCM token synced for user.$userId'
            : 'FCM token sync failed.',
      );
    } catch (error) {
      AppLoggerHelper.debug('FCM sync failed: $error');
    }
  }

  // ignore: unused_element
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
    if (stats.isEmpty && !isAssignmentsLoading.value) {
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

  void _setAssignmentStatusById(String assignmentId, AssignmentStatus status) {
    final idx = assignments.indexWhere((item) => item.id == assignmentId);
    if (idx != -1) {
      assignments[idx] = assignments[idx].copyWith(status: status);
    }
  }

  @override
  void onClose() {
    _internetServices.dispose();
    _disconnectNotificationSocket();
    super.onClose();
  }

  void _connectNotificationSocket() {
    if (_notificationSocket.isConnected) return;
    final riderId = StorageService.userId;
    if (riderId == null) {
      AppLoggerHelper.debug(
        'Notification socket connect skipped: missing riderId.',
      );
      return;
    }
    _notificationSocket.connect(riderId);
    _notificationSubscription?.cancel();
    _notificationSubscription = _notificationSocket.notificationStream.listen(
      _handleIncomingNotification,
      onError: (error) {
        AppLoggerHelper.debug('Notification socket error: $error');
      },
    );
  }

  void _disconnectNotificationSocket() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
    _notificationSocket.disconnect();
  }

  void _handleIncomingNotification(Map<String, dynamic> payload) {
    final notification = IncomingOrderNotification.fromPayload(payload);
    if (notification == null) return;
    if (notification.notificationId == _lastNotificationId) return;
    _lastNotificationId = notification.notificationId;
    incomingOffer.value = notification;
  }

  bool consumeIncomingOffer(String notificationId) {
    final current = incomingOffer.value;
    if (current == null || current.notificationId != notificationId) {
      return false;
    }
    incomingOffer.value = null;
    return true;
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

      if (data['offers'] is List) {
        final offers = data['offers'] as List<dynamic>;
        return offers
            .whereType<Map<String, dynamic>>()
            .map(Assignment.fromUpcomingOrderJson)
            .toList();
      }

      return [Assignment.fromUpcomingOrderJson(data)];
    }

    return [];
  }
}

class IncomingOrderNotification {
  IncomingOrderNotification({
    required this.notificationId,
    required this.title,
    required this.body,
    this.orderId,
    required this.raw,
  });

  final String notificationId;
  final String title;
  final String body;
  final String? orderId;
  final Map<String, dynamic> raw;

  static IncomingOrderNotification? fromPayload(Map<String, dynamic> payload) {
    if (payload.isEmpty) return null;
    final type = payload['type']?.toString().toLowerCase();
    if (type != null &&
        type.isNotEmpty &&
        type != 'notifications' &&
        type != 'notification') {
      return null;
    }

    final rawTitle = payload['title']?.toString();
    final rawBody = payload['body']?.toString();
    if ((rawTitle == null || rawTitle.isEmpty) &&
        (rawBody == null || rawBody.isEmpty)) {
      return null;
    }
    final title = rawTitle != null && rawTitle.isNotEmpty
        ? rawTitle
        : 'New Order Offer';
    final body = rawBody ?? '';
    final notificationId =
        payload['notification_id']?.toString() ??
        payload['id']?.toString() ??
        DateTime.now().microsecondsSinceEpoch.toString();
    final data = payload['data'];
    String? orderId;
    if (data is Map<String, dynamic>) {
      orderId =
          data['order_id']?.toString() ??
          data['orderId']?.toString() ??
          data['id']?.toString();
    }
    orderId ??= _extractOrderId(body);
    if (orderId != null) {
      orderId = orderId.replaceFirst('#', '');
    }

    return IncomingOrderNotification(
      notificationId: notificationId,
      title: title,
      body: body,
      orderId: orderId,
      raw: payload,
    );
  }

  static String? _extractOrderId(String body) {
    if (body.trim().isEmpty) return null;
    final hashMatch = RegExp(r'#([A-Za-z0-9_-]+)').firstMatch(body);
    if (hashMatch != null) {
      return hashMatch.group(1);
    }
    final ordMatch = RegExp(r'ORD[_-]?[A-Za-z0-9]+').firstMatch(body);
    return ordMatch?.group(0);
  }
}
