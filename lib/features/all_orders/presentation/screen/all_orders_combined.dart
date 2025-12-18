import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/features/all_orders/controllers/all_order_combioned_controller.dart';
import 'package:quikle_rider/features/all_orders/controllers/all_order_controller.dart';
import 'package:quikle_rider/features/all_orders/models/combine_ordermodel.dart';
import 'package:quikle_rider/features/all_orders/models/rider_order_model.dart';
import 'package:quikle_rider/features/all_orders/widgets/delevery_process_card.dart';

class AllOrdersCombined extends StatelessWidget {
  const AllOrdersCombined({super.key});

  @override
  Widget build(BuildContext context) {
    final AllOrdersController allOrdersController = Get.find<AllOrdersController>();
    final CombinedOrderController controller = Get.put(CombinedOrderController());

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Obx(() {
        if (allOrdersController.isOrdersLoading.value &&
            allOrdersController.combinedOrders.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        final combinedOrders = allOrdersController.combinedOrders;
        if (combinedOrders.isEmpty) {
          return const Center(child: Text('No combined orders found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 8.h),
              ...combinedOrders.map((apiOrder) {
                final CombinedOrderModel model =
                    CombinedOrderModel.fromRiderOrder(apiOrder);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DeliveryProgressCard(order: model),
                    SizedBox(height: 24.h),
                    DeliveryInfoCard(
                      order: model,
                      controller: controller,
                      onCancel: () => _showCancelDialog(apiOrder),
                      onViewDetails: () => Get.toNamed(
                        '/mapScreen',
                        arguments: apiOrder,
                      ),
                    ),
                    SizedBox(height: 24.h),
                  ],
                );
              }),
              SizedBox(height: 80.h), // Bottom padding for nav bar
            ],
          ),
        );
      }),
    );
  }

  void _showCancelDialog(RiderOrder order) {
    Get.dialog(
      AlertDialog(
        title: const Text('Cancel Order'),
        content: Text('Are you sure you want to cancel ${order.id}?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('No'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.snackbar(
                'Not available',
                'Cancel is not implemented yet.',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
  }
}
