// screens/all_orders_single.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/features/all_orders/controllers/all_order_controller.dart';
import 'package:quikle_rider/features/all_orders/controllers/all_order_single.dart';
import 'package:quikle_rider/features/all_orders/widgets/order_card.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';

class AllOrdersSingle extends StatelessWidget {
  const AllOrdersSingle({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.put(OrderController());
    final AllOrdersController allOrdersController =
        Get.find<AllOrdersController>();
    final ProfileController profileController =
        Get.isRegistered<ProfileController>()
            ? Get.find<ProfileController>()
            : Get.put(ProfileController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Obx(() {
        final isVerified = profileController.isVerified.value == true;
        if (!isVerified) {
          return Center(
            child: Text(
              'Your profile not verified',
              style: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF7C7C7C),
              ),
            ),
          );
        }

        if (allOrdersController.isOrdersLoading.value &&
            allOrdersController.singleOrders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (allOrdersController.singleOrders.isEmpty) {
          return Center(
            child: Text(
              'No single orders found',
              style: getTextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF7C7C7C),
              ),
            ),
          );
        }
        return SingleChildScrollView(
          child: Container(
            width: 360.w,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                OrderCard(controller: controller),
                SizedBox(height: 80.h), // Bottom padding for nav bar
              ],
            ),
          ),
        );
      }),
    );
  }
}
