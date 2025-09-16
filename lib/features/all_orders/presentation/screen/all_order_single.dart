// screens/all_orders_single.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/features/all_orders/controllers/all_order_single.dart';
import 'package:quikle_rider/features/all_orders/widgets/order_card.dart';


class AllOrdersSingle extends StatelessWidget {
  const AllOrdersSingle({super.key});

  @override
  Widget build(BuildContext context) {
    final OrderController controller = Get.put(OrderController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Container(
          width: 360.w,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              OrderCard(controller: controller),
              SizedBox(height: 80.h), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }
}

