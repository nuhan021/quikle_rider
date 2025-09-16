// models/order_model.dart
import 'dart:ui';

class OrderModel {
  final String id;
  final String customerName;
  final String restaurant;
  final String address;
  final String estimatedTime;
  final String distance;
  final String amount;
  final OrderStatus status;
  final String restaurantImage;
  final String customerImage;
  final List<OrderItem> items;

  OrderModel({
    required this.id,
    required this.customerName,
    required this.restaurant,
    required this.address,
    required this.estimatedTime,
    required this.distance,
    required this.amount,
    required this.status,
    required this.restaurantImage,
    required this.customerImage,
    required this.items,
  });

  OrderModel copyWith({
    String? id,
    String? customerName,
    String? restaurant,
    String? address,
    String? estimatedTime,
    String? distance,
    String? amount,
    OrderStatus? status,
    String? restaurantImage,
    String? customerImage,
    List<OrderItem>? items,
  }) {
    return OrderModel(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      restaurant: restaurant ?? this.restaurant,
      address: address ?? this.address,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      distance: distance ?? this.distance,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      restaurantImage: restaurantImage ?? this.restaurantImage,
      customerImage: customerImage ?? this.customerImage,
      items: items ?? this.items,
    );
  }
  // Helper methods
  Color get statusColor {
    switch (status) {
      case OrderStatus.preparing:
        return const Color(0xFFFF6F00);
      case OrderStatus.readyForPickup:
        return const Color(0xFF4CAF50);
      case OrderStatus.inProgress:
        return const Color(0xFFFF6F00);
      case OrderStatus.delivered:
        return const Color(0xFF4CAF50);
    }
  }

  Color get statusBgColor {
    switch (status) {
      case OrderStatus.preparing:
        return const Color(0x26FF6F00);
      case OrderStatus.readyForPickup:
        return const Color(0x264CAF50);
      case OrderStatus.inProgress:
        return const Color(0x26FF6F00);
      case OrderStatus.delivered:
        return const Color(0x264CAF50);
    }
  }

  String get statusText {
    switch (status) {
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.readyForPickup:
        return 'Ready for Pickup';
      case OrderStatus.inProgress:
        return 'In Progress';
      case OrderStatus.delivered:
        return 'Delivered';
    }
  }

  bool get isCompleted => status == OrderStatus.delivered;
  bool get isReadyForPickup => status == OrderStatus.readyForPickup;
  bool get isInProgress => status == OrderStatus.inProgress || status == OrderStatus.readyForPickup;

  double get progressWidth {
    switch (status) {
      case OrderStatus.preparing:
        return 0;
      case OrderStatus.readyForPickup:
      case OrderStatus.inProgress:
        return 158;
      case OrderStatus.delivered:
        return 328;
    }
  }

  String get pickupStatusText {
    switch (status) {
      case OrderStatus.delivered:
        return 'Pickup completed';
      case OrderStatus.readyForPickup:
        return 'Ready for pickup';
      default:
        return 'Estimated arrival in $estimatedTime';
    }
  }

  String get pickupStatus {
    return (status == OrderStatus.inProgress || status == OrderStatus.delivered)
        ? 'Completed'
        : 'Pending';
  }
}

enum OrderStatus { preparing, readyForPickup, inProgress, delivered }

class OrderItem {
  final String name;
  final String details;

  OrderItem({required this.name, required this.details});
}

