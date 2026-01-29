import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';
import 'package:quikle_rider/core/widgets/connection_lost.dart';
import 'package:quikle_rider/custom_tab_bar/custom_tab_bar.dart';
import 'package:quikle_rider/features/home/controllers/homepage_controller.dart';
import 'package:quikle_rider/features/home/models/home_dashboard_models.dart';
import 'package:quikle_rider/features/home/presentation/widgets/dialogs/alert_dialog.dart';
import 'package:quikle_rider/features/home/presentation/widgets/dialogs/incoming_offer_notification_dialog.dart';
import 'package:quikle_rider/features/home/presentation/widgets/cards/assignment_card.dart';
import 'package:quikle_rider/features/home/presentation/widgets/cards/stat_card.dart';
import 'package:quikle_rider/features/map/presentation/widgets/map_shimmer.dart';

class HomeScreen extends GetView<HomepageController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final incomingOffer = controller.incomingOffer.value;
      if (incomingOffer != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!controller.consumeIncomingOffer(incomingOffer.notificationId)) {
            return;
          }
          _showIncomingOfferDialog(context, incomingOffer);
        });
      }
      return SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomTabBar(
            currentIndex: 0,
            title: 'Home',
            isOnline: controller.isOnline.value,
            onToggle: controller.onToggleSwitch,
          ),
          body: controller.hasConnection.value
              ? (controller.isOnline.value
                    ? _buildOnlineView(context)
                    : _buildOfflineView())
              : const ConnectionLost(),
        ),
      );
    });
  }

  Widget _buildOfflineView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Go Online To Get\nRequests',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Obviously',
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  List<HomeStat> _fallbackStats() {
    return const [
      HomeStat(id: 'upcoming', title: 'Upcoming', subtitle: 'Orders', value: 0),
      HomeStat(
        id: 'payout',
        title: 'Payout',
        subtitle: 'Potential',
        value: 0,
        unit: '₹',
      ),
      HomeStat(id: 'rating', title: 'Rating', subtitle: 'Out of 5', value: 0),
    ];
  }

  Widget _buildOnlineView(BuildContext context) {
    return Obx(() {
      final hasError = controller.errorMessage.value != null;
      final stats = controller.stats.isEmpty
          ? _fallbackStats()
          : controller.stats;
      final assignments = hasError ? <Assignment>[] : controller.assignments;
      final isAssignmentsLoading = controller.isAssignmentsLoading.value;
      final isFetchingMore = controller.isFetchingMoreAssignments.value;
      final hasMoreAssignments = controller.hasMoreAssignments.value;

      final token = StorageService.accessToken;
      AppLoggerHelper.debug('Access token: $token');

      return RefreshIndicator(
        onRefresh: controller.refreshUpcomingAssignments,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            if (notification.metrics.maxScrollExtent <= 0) {
              return false;
            }
            final threshold = 200.0;
            final shouldLoadMore = notification.metrics.pixels >=
                (notification.metrics.maxScrollExtent - threshold);
            if (shouldLoadMore &&
                hasMoreAssignments &&
                !isFetchingMore &&
                !isAssignmentsLoading) {
              controller.loadMoreAssignments();
            }
            return false;
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                SizedBox(height: 16.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: stats.take(3).map((stat) {
                    return StatCard(
                      title: stat.title,
                      value: stat.displayValue,
                      subtitle: stat.subtitle,
                    );
                  }).toList(),
                ),
                SizedBox(height: 24.h),
                Text(
                  'Upcoming Assignments',
                  style: TextStyle(
                    fontFamily: 'Obviously',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16.h),
                if (isAssignmentsLoading && assignments.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      children: [
                        SizedBox(
                          height: 24.h,
                          width: 24.h,
                          child: const CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(height: 12.h),
                        Text(
                          'Loading assignments...',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                else if (assignments.isEmpty)
                  Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(vertical: 32.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Text(
                      'No upcoming assignments right now.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  )
                else
                  Column(
                    children: assignments.map((assignment) {
                      final isPending =
                          assignment.status == AssignmentStatus.pending;
                      final isActionPending = controller
                          .isAssignmentActionPending(assignment.id);
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: AssignmentCard(
                          deleverystatus: assignment.deleverystatus,
                          orderId: assignment.id,
                          customerName: assignment.customerName,
                          arrivalTime: assignment.formattedArrival,
                          address: assignment.address,
                          distance: assignment.formattedDistance,
                          total: assignment.formattedTotal,
                          breakdown: assignment.formattedBreakdown,
                          isUrgent: assignment.isUrgent,
                          isCombined: assignment.isCombined,
                          status: assignment.status,
                          orderStatus: assignment.orderStatus,
                          showActions: isPending,
                          isAccepting: isActionPending,
                          onAccept: isPending
                              ? () async {
                                  if (isActionPending) return;

                                  final success = await controller
                                      .acceptAssignment(assignment);

                                  // Show status dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return OrderStatusDialog(
                                        imageUrl: success
                                            ? "assets/images/success.png"
                                            : "assets/images/cancel.png",
                                        text: success
                                            ? "Order Accepted"
                                            : "Order failed to accept",
                                      );
                                    },
                                  );

                                  // Auto close after 1 second
                                  Future.delayed(
                                    const Duration(seconds: 1),
                                    () {
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                  );
                                }
                              : null,

                          onReject: isPending
                              ? () async {
                                  if (isActionPending) return;

                                  final success = await controller
                                      .rejectAssignment(assignment);

                                  // Show status dialog
                                  showDialog(
                                    context: context,
                                    barrierDismissible: false,
                                    builder: (context) {
                                      return OrderStatusDialog(
                                        imageUrl: success
                                            ? "assets/images/cancel.png"
                                            : "assets/images/success.png",
                                        text: success
                                            ? "Order Rejected"
                                            : "Order failed to reject",
                                      );
                                    },
                                  );

                                  // Auto close after 1 second
                                  Future.delayed(
                                    const Duration(seconds: 1),
                                    () {
                                      if (Navigator.of(context).canPop()) {
                                        Navigator.of(context).pop();
                                      }
                                    },
                                  );
                                }
                              : null,
                        ),
                      );
                    }).toList(),
                  ),
                if (isFetchingMore)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, bottom: 8.h),
                    child: Center(
                      child: SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    ),
                  ),
                SizedBox(height: 24.h),
              ],
              ),
            ),
          ),
        ),
      );
    });
  }

  void _showIncomingOfferDialog(
    BuildContext context,
    IncomingOrderNotification offer,
  ) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        String? actionInProgress;
        return StatefulBuilder(
          builder: (context, setState) {
            final isProcessing = actionInProgress != null;
            final isAccepting = actionInProgress == 'accept';
            final isRejecting = actionInProgress == 'reject';
            return IncomingOfferNotificationDialog(
              title: offer.title,
              body: offer.body,
              orderId: offer.orderId,
              isProcessing: isProcessing,
              isAccepting: isAccepting,
              isRejecting: isRejecting,
              onAccept: () async {
                final orderId = offer.orderId?.trim() ?? '';
                if (orderId.isEmpty) {
                  _showMissingOrderIdSnack();
                  return;
                }
                setState(() => actionInProgress = 'accept');
                final success = await controller.acceptAssignmentById(orderId);
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
                _showOrderStatusDialog(
                  context,
                  success: success,
                  isAccept: true,
                );
              },
              onReject: () async {
                final orderId = offer.orderId?.trim() ?? '';
                if (orderId.isEmpty) {
                  _showMissingOrderIdSnack();
                  return;
                }
                setState(() => actionInProgress = 'reject');
                final success = await controller.rejectAssignmentById(orderId);
                if (Navigator.of(dialogContext).canPop()) {
                  Navigator.of(dialogContext).pop();
                }
                _showOrderStatusDialog(
                  context,
                  success: success,
                  isAccept: false,
                );
              },
            );
          },
        );
      },
    );
  }

  void _showMissingOrderIdSnack() {
    Get.snackbar(
      'Order ID missing',
      'Unable to extract order id from this offer.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.redAccent,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      duration: const Duration(seconds: 2),
    );
  }

  void _showOrderStatusDialog(
    BuildContext context, {
    required bool success,
    required bool isAccept,
  }) {
    final imageUrl = isAccept
        ? (success ? "assets/images/success.png" : "assets/images/cancel.png")
        : (success ? "assets/images/cancel.png" : "assets/images/success.png");
    final text = isAccept
        ? (success ? "Order Accepted" : "Order failed to accept")
        : (success ? "Order Rejected" : "Order failed to reject");

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return OrderStatusDialog(imageUrl: imageUrl, text: text);
      },
    );

    Future.delayed(const Duration(seconds: 1), () {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }
}
