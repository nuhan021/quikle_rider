import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/features/all_orders/models/single_oder_model.dart';

class OrderController extends GetxController {
  final Rx<OrderModel> order = _getDummyOrder().obs;

  // Dummy data
  static OrderModel _getDummyOrder() {
    return OrderModel(
      id: '#5680',
      customerName: 'John Smith',
      restaurant: 'Pizza Palace',
      address: '123 Main Street, Downtown',
      estimatedTime: '25 min',
      distance: '1.5 miles',
      amount: '\$18.50',
      status: OrderStatus.readyForPickup, // Ensures "Pick Up" button shows initially
      restaurantImage: 'assets/images/foodimage.png',
      customerImage: 'assets/images/avatar.png',
      items: [
        OrderItem(name: 'Margherita Pizza X 1', details: 'Extra cheese'),
        OrderItem(name: 'Garlic Bread X 2', details: 'With dipping sauce'),
      ],
    );
  }

  void cancelOrder() {
    Get.dialog(
      _buildActionDialog(
        'Cancel Order',
        'Are you sure you want to cancel order ${order.value.id}?',
        onConfirm: () {
          Get.back();
          _showSnackbar('Order ${order.value.id} has been cancelled');
        },
      ),
    );
  }


  void markAsPickedUp() {
    this.order.value = this.order.value.copyWith(
      status: OrderStatus.inProgress,
    );
    update();
    _showSnackbar('Order ${order.value.id} marked as picked up');
  }

  void navigateToDetails() {
    try {
      Get.toNamed('/mapScreen'); // Use named route for robustness
      _showSnackbar('Navigated to details for ${order.value.id}');
    } catch (e) {
      _showSnackbar('Error navigating to map: $e');
    }
  }

  void makePhoneCall() {
    _showSnackbar('Calling ${order.value.customerName}');
  }

  void sendMessage() {
    _showSnackbar('Opening chat with ${order.value.customerName}');
  }


  Widget _buildActionDialog(
    String title,
    String content, {
    required VoidCallback onConfirm,
  }) {
    return AlertDialog(
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w900,
          color: Color.fromARGB(255, 0, 0, 0),
          fontFamily: 'Obviously',
          height: 1.40,
        ),
      ),
      content: Text(
        content,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w400,
          color: Color(0xFF7C7C7C),
          fontFamily: 'Inter',
          height: 1.50,
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: const Text(
            'Cancel',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF7C7C7C),
              fontFamily: 'Manrope',
              height: 1.50,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: onConfirm,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFEF5350),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          child: const Text(
            'Confirm',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.white,
              fontFamily: 'Manrope',
              height: 1.50,
            ),
          ),
        ),
      ],
    );
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
}

