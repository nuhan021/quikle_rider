// screens/all_orders_combined.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/features/all_orders/controllers/all_order_combioned_controller.dart';
import 'package:quikle_rider/features/all_orders/widgets/delevery_process_card.dart';


class AllOrdersCombined extends StatelessWidget {
  const AllOrdersCombined({super.key});

  @override
  Widget build(BuildContext context) {
    final CombinedOrderController controller = Get.put(CombinedOrderController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Container(
          width: 360.w,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Obx(() => DeliveryProgressCard(order: controller.order.value)),
              SizedBox(height: 24.h),
              Obx(() => DeliveryInfoCard(
                order: controller.order.value,
                controller: controller,
              )),
              SizedBox(height: 80.h), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }
}