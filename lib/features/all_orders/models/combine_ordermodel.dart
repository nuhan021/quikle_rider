// models/combined_order_model.dart
import 'dart:ui';

import 'package:quikle_rider/features/all_orders/models/rider_order_model.dart';

class CombinedOrderModel {
  final String customerName;
  final String customerImage;
  final String deliveryAddress;
  final List<PickupPoint> pickupPoints;
  final List<Restaurant> restaurants;
  final int completedSteps;
  final int totalSteps;
  final double totalPayout;
  final double distanceInKm;
  final double distancePay;
  final double combinedOrderBonus;
  final List<PickupPayout> pickupPayouts;
  final String currency;

  CombinedOrderModel({
    required this.customerName,
    required this.customerImage,
    required this.deliveryAddress,
    required this.pickupPoints,
    required this.restaurants,
    required this.completedSteps,
    required this.totalSteps,
    required this.totalPayout,
    required this.distanceInKm,
    required this.distancePay,
    required this.combinedOrderBonus,
    required this.pickupPayouts,
    this.currency = '₹',
  });

  factory CombinedOrderModel.fromRiderOrder(RiderOrder order) {
    final shipping = order.metadata?.shippingAddress;
    final vendor = order.metadata?.vendorInfo;

    final completedSteps = _mapCompletedSteps(order.status);
    final pickupPoints = <PickupPoint>[
      if (vendor?.storeName != null || shipping?.addressLine1 != null)
        PickupPoint(
          name: vendor?.storeName ?? 'Pickup',
          address: shipping?.addressLine1 ?? '',
          statusText: order.status ?? '',
          status: completedSteps >= 1 ? PickupStatus.completed : PickupStatus.pending,
        ),
    ];

    return CombinedOrderModel(
      customerName: shipping?.fullName ?? '',
      customerImage: 'assets/images/avatar.png',
      deliveryAddress: shipping?.addressLine1 ?? '',
      pickupPoints: pickupPoints,
      restaurants: const [],
      completedSteps: completedSteps,
      totalSteps: 3,
      totalPayout: double.tryParse(order.total ?? '') ?? 0,
      distanceInKm: order.pickupDistanceKm ?? 0,
      distancePay: double.tryParse(order.distanceBonus ?? '') ?? 0,
      combinedOrderBonus: 0,
      pickupPayouts: const [],
    );
  }

  String get progressText => '$completedSteps of $totalSteps steps';
  double get progressWidth => (completedSteps / totalSteps) * 328;
  
  bool get isPickedUp => completedSteps >= 1;
  bool get isInProgress => completedSteps >= 2;
  bool get isDelivered => completedSteps >= 3;

  String formatAmount(double amount) {
    return amount % 1 == 0
        ? amount.toStringAsFixed(0)
        : amount.toStringAsFixed(2);
  }

  String get formattedTotalPayout => formatAmount(totalPayout);
  String get formattedDistance => distanceInKm % 1 == 0
      ? distanceInKm.toStringAsFixed(0)
      : distanceInKm.toStringAsFixed(1);

  static int _mapCompletedSteps(String? apiStatus) {
    switch (apiStatus) {
      case 'delivered':
      case 'completed':
        return 3;
      case 'outForDelivery':
      case 'out_for_delivery':
      case 'inProgress':
      case 'in_progress':
        return 2;
      case 'pickedUp':
      case 'picked_up':
      case 'readyForPickup':
      case 'ready_for_pickup':
        return 1;
      default:
        return 0;
    }
  }
}

class PickupPoint {
  final String name;
  final String address;
  final String statusText;
  final PickupStatus status;

  PickupPoint({
    required this.name,
    required this.address,
    required this.statusText,
    required this.status,
  });

  Color get statusBgColor {
    return status == PickupStatus.completed 
        ? const Color(0x264CAF50) 
        : const Color(0x26FF6F00);
  }

  Color get statusTextColor {
    return status == PickupStatus.completed 
        ? const Color(0xFF4CAF50) 
        : const Color(0xFFFF6F00);
  }

  String get statusString {
    return status == PickupStatus.completed ? 'Completed' : 'Pending';
  }

  Color get dotColor {
    return status == PickupStatus.completed 
        ? const Color(0xFF4CAF50) 
        : const Color(0xFFFF6F00);
  }
}

enum PickupStatus { completed, pending }

class Restaurant {
  final String name;
  final List<MenuItem> items;

  Restaurant({
    required this.name,
    required this.items,
  });
}

class MenuItem {
  final String name;
  final String details;
  final String imagePath;

  MenuItem({
    required this.name,
    required this.details,
    required this.imagePath,
  });
}

class PickupPayout {
  final String pickupName;
  final double baseAmount;

  PickupPayout({
    required this.pickupName,
    required this.baseAmount,
  });

  String formatAmount() {
    return baseAmount % 1 == 0
        ? baseAmount.toStringAsFixed(0)
        : baseAmount.toStringAsFixed(2);
  }
}
