// models/combined_order_model.dart
import 'dart:ui';

class CombinedOrderModel {
  final String customerName;
  final String customerImage;
  final String deliveryAddress;
  final List<PickupPoint> pickupPoints;
  final List<Restaurant> restaurants;
  final int completedSteps;
  final int totalSteps;

  CombinedOrderModel({
    required this.customerName,
    required this.customerImage,
    required this.deliveryAddress,
    required this.pickupPoints,
    required this.restaurants,
    required this.completedSteps,
    required this.totalSteps,
  });

  String get progressText => '$completedSteps of $totalSteps steps';
  double get progressWidth => (completedSteps / totalSteps) * 328;
  
  bool get isPickedUp => completedSteps >= 1;
  bool get isInProgress => completedSteps >= 2;
  bool get isDelivered => completedSteps >= 3;
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