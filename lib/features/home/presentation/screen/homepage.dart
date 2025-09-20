import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/custom_tab_bar/custom_tab_bar.dart';
import 'package:quikle_rider/features/home/controller/home_controller.dart';
import 'package:quikle_rider/features/home/model/home_model.dart';


class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeController>(
      init: HomeController(),
      builder: (controller) {
        return Obx(() {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomTabBar(
              currentIndex: 0,
              title: 'Home',
              isOnline: controller.isOnline,
              onToggle: controller.onToggleSwitch,
            ),
            body: controller.isOnline
                ? _buildOnlineView(controller)
                : _buildOfflineView(),
          );
        });
      },
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

  Widget _buildOnlineView(HomeController controller) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            // Stats Row
            Row(
              children: [
                _buildStatCard(
                  'Today',
                  controller.stats.todayDeliveries,
                  'Deliveries',
                ),
                SizedBox(width: 12.w),
                _buildStatCard(
                  'This Week',
                  controller.stats.weekDeliveries,
                  'Deliveries',
                ),
                SizedBox(width: 12.w),
                _buildStatCard('Rating', controller.stats.rating, 'Out of 5'),
              ],
            ),

            SizedBox(height: 24.h),

            // Upcoming Assignments
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

            // Assignment Cards
            ...controller.assignments
                .map(
                  (assignment) => Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: _buildAssignmentCard(assignment, controller),
                  ),
                )
                .toList(),

            SizedBox(height: 80.h), // Bottom padding for nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Container(
      width: 112.w,
      height: 130.h,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w400,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 14.sp,
              color: Colors.grey[700],
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAssignmentCard(
    AssignmentModel assignment,
    HomeController controller,
  ) {
    return Container(
      width: 350.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A606060),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order ${assignment.orderId}',
                style: TextStyle(
                  fontFamily: 'Obviously',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF484848),
                ),
              ),
              Row(
                children: [
                  if (assignment.isUrgent)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0x26FF0000),
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                      child: Text(
                        'Urgent',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.sp,
                          color: const Color(0xFFFF0000),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF0F0F0),
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      assignment.isCombined ? 'Combined' : 'Single',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 8.h),

          // Customer Info
          Text(
            assignment.customerName,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 12.h),

          // Arrival Time
          Row(
            children: [
              Icon(Icons.access_time, size: 18.sp, color: Colors.black),
              SizedBox(width: 6.w),
              Text(
                assignment.arrivalTime,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Address and Distance
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18.sp,
                    color: Colors.black,
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    assignment.address,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
              Text(
                assignment.distance,
                style: TextStyle(
                  fontFamily: 'Manrope', // Manrope font requested
                  fontSize: 14.sp,
                  color: const Color(0xFF484848),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Divider(color: const Color(0x3FB7B7B7), thickness: 1.h),

          SizedBox(height: 16.h),

          // Total
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontFamily: 'Obviously',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF333333),
                ),
              ),
              Text(
                assignment.total,
                style: TextStyle(
                  fontFamily: 'Obviously',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w900,
                  color: const Color(0xFF333333),
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40.h,
                  child: OutlinedButton(
                    onPressed: () => controller.onRejectOrder(assignment),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(
                        color: const Color(0xFFE03E1A),
                        width: 1.w,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                    ),
                    child: Text(
                      'Reject',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        color: const Color(0xFFFF0000),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: SizedBox(
                  height: 40.h,
                  child: ElevatedButton(
                    onPressed: () => controller.onAcceptOrder(assignment),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 24.w),
                      elevation: 0,
                    ),
                    child: Text(
                      'Accept',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
