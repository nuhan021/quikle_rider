import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/widgets/connection_lost.dart';
import 'package:quikle_rider/custom_tab_bar/custom_tab_bar.dart';
import 'package:quikle_rider/features/home/controllers/homepage_controller.dart';
import 'package:quikle_rider/features/home/models/home_dashboard_models.dart';
import 'package:quikle_rider/features/home/presentation/widgets/alert_dialog.dart';
import 'package:quikle_rider/features/home/presentation/widgets/assignment_card.dart';
import 'package:quikle_rider/features/home/presentation/widgets/stat_card.dart';
import 'package:quikle_rider/features/map/presentation/widgets/map_shimmer.dart';

class HomeScreen extends GetView<HomepageController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SafeArea(
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: CustomTabBar(
            currentIndex: 0,
            title: 'Home',
            isOnline: controller.isOnline.value,
            onToggle: controller.onToggleSwitchAndSyncToken,
          ),
          body: controller.hasConnection.value
              ? (controller.isOnline.value
                  ? _buildOnlineView(context)
                  : _buildOfflineView())
              : const ConnectionLost(),
        ),
      ),
    );
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
      HomeStat(
        id: 'upcoming',
        title: 'Upcoming',
        subtitle: 'Orders',
        value: 0,
      ),
      HomeStat(
        id: 'payout',
        title: 'Payout',
        subtitle: 'Potential',
        value: 0,
        unit: '₹',
      ),
      HomeStat(
        id: 'rating',
        title: 'Rating',
        subtitle: 'Out of 5',
        value: 0,
      ),
    ];
  }

  Widget _buildOnlineView(BuildContext context) {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: MapShimmer());
      }

      final hasError = controller.errorMessage.value != null;
      final stats =
          controller.stats.isEmpty ? _fallbackStats() : controller.stats;
      final assignments =
          hasError ? <Assignment>[] : controller.assignments;

      return SingleChildScrollView(
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
              if (assignments.isEmpty)
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
                        onAccept: isPending
                            ? () async {
                                final pending = controller
                                    .isAssignmentActionPending(assignment.id);
                                if (pending) return;

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
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                });
                              }
                            : null,

                        onReject: isPending
                            ? () async {
                                final pending = controller
                                    .isAssignmentActionPending(assignment.id);
                                if (pending) return;

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
                                Future.delayed(const Duration(seconds: 1), () {
                                  if (Navigator.of(context).canPop()) {
                                    Navigator.of(context).pop();
                                  }
                                });
                              }
                            : null,
                      ),
                    );
                  }).toList(),
                ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      );
    });
  }
}
