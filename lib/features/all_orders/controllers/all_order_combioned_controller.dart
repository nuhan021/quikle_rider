// controllers/combined_order_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/features/all_orders/models/combine_ordermodel.dart';
import 'package:quikle_rider/features/all_orders/controllers/all_order_controller.dart';


class CombinedOrderController extends GetxController {
  final Rxn<CombinedOrderModel> order = Rxn<CombinedOrderModel>();
  Worker? _ordersWorker;

  @override
  void onInit() {
    super.onInit();
    if (Get.isRegistered<AllOrdersController>()) {
      final allOrdersController = Get.find<AllOrdersController>();
      _syncFromAllOrders(allOrdersController);
      _ordersWorker = ever(allOrdersController.orders, (_) {
        _syncFromAllOrders(allOrdersController);
      });
    }
  }

  void _syncFromAllOrders(AllOrdersController allOrdersController) {
    final combined = allOrdersController.combinedOrders;
    if (combined.isEmpty) {
      order.value = null;
      return;
    }
    order.value = CombinedOrderModel.fromRiderOrder(combined.first);
  }

  void makePhoneCall([CombinedOrderModel? target]) {
    final current = target ?? order.value;
    if (current == null) {
      _showSnackbar('No combined order loaded');
      return;
    }
    _showSnackbar('Calling ${current.customerName}');
  }

  void sendMessage([CombinedOrderModel? target]) {
    final current = target ?? order.value;
    if (current == null) {
      _showSnackbar('No combined order loaded');
      return;
    }
    _showSnackbar('Opening chat with ${current.customerName}');
  }

  void _showSnackbar(String message) {
    Get.snackbar(
      '',
      message,
      titleText: const SizedBox.shrink(),
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Manrope',
          height: 1.50,
        ),
      ),
      backgroundColor: const Color(0xFFFFC200),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    _ordersWorker?.dispose();
    super.onClose();
  }
}
