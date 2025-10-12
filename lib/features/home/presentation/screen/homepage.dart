import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/custom_tab_bar/custom_tab_bar.dart';
import 'package:quikle_rider/features/home/controllers/homepage_controller.dart';
import 'package:quikle_rider/features/home/presentation/widgets/alert_dialog.dart';
import 'package:quikle_rider/features/home/presentation/widgets/assignment_card.dart';
import 'package:quikle_rider/features/home/presentation/widgets/stat_card.dart';

class HomeScreen extends GetView<HomepageController> {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomTabBar(
          currentIndex: 0,
          title: 'Home',
          isOnline: controller.isOnline.value,
          onToggle: controller.onToggleSwitch,
        ),
        body: controller.isOnline.value
            ? _buildOnlineView(context)
            : _buildOfflineView(),
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

  Widget _buildOnlineView(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            // Stats Row
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                StatCard(title: 'Today', value: '5', subtitle: 'Deliveries'),
                StatCard(
                  title: 'This Week',
                  value: '32',
                  subtitle: 'Deliveries',
                ),
                StatCard(title: 'Rating', value: '4.8', subtitle: 'Out of 5'),
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
            AssignmentCard(
              orderId: '#5678',
              customerName: 'Aanya Desai',
              arrivalTime: 'Arrives by 4:00 PM',
              address: '456 Oak Ave, Downtown',
              distance: '2.1 mile',
              total: '24.00',
              isUrgent: true,
              isCombined: true,
              onAccept: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return OrderStatusDialog(
                      imageUrl: "assets/images/success.png",
                      text: "Order Accepted",
                    );
                  },
                );
              },

              onReject: () {
                showDialog(
                  context: context,
                  builder: (context) {
                    return OrderStatusDialog(
                      imageUrl: "assets/images/cancel.png",
                      text: "Order Rejected",
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
