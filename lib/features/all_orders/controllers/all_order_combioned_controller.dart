// controllers/combined_order_controller.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/features/all_orders/models/combine_ordermodel.dart';


class CombinedOrderController extends GetxController {
  final Rx<CombinedOrderModel> order = _getDummyOrder().obs;

  // Dummy data
  static CombinedOrderModel _getDummyOrder() {
    return CombinedOrderModel(
      customerName: 'Aanya Desai',
      customerImage: 'assets/images/avatar.png',
      deliveryAddress: '789 River Rd, Apartment 3B, Riverside Mohakhali',
      completedSteps: 2,
      totalSteps: 3,
      pickupPoints: [
        PickupPoint(
          name: 'Thai Spice Restaurant',
          address: '123 Main St, Bangkok',
          statusText: 'Pickup completed at 15:10 PM',
          status: PickupStatus.completed,
        ),
        PickupPoint(
          name: 'Sushi Express',
          address: '456 Central Ave, Bangkok',
          statusText: 'Estimated arrival in 5 min',
          status: PickupStatus.pending,
        ),
      ],
      restaurants: [
        Restaurant(
          name: 'Thai Spice Restaurant',
          items: [
            MenuItem(
              name: 'Pad Thai Chicken X 1',
              details: 'Medium spicy, no peanuts',
              imagePath: 'assets/images/foodimage.png',
            ),
            MenuItem(
              name: 'Spring Rolls X 2',
              details: 'Vegetarian',
              imagePath: 'assets/images/foodimage02.png',
            ),
          ],
        ),
        Restaurant(
          name: 'Sushi Express',
          items: [
            MenuItem(
              name: 'Dragon Roll Set X 1',
              details: '8 pieces, extra wasabi',
              imagePath: 'assets/images/foodimage03.png',
            ),
            MenuItem(
              name: 'Miso Soup X 1',
              details: 'Regular size',
              imagePath: 'assets/images/foodimage03.png',
            ),
          ],
        ),
      ],
    );
  }

  void makePhoneCall() {
    _showSnackbar('Calling ${order.value.customerName}');
  }

  void sendMessage() {
    _showSnackbar('Opening chat with ${order.value.customerName}');
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