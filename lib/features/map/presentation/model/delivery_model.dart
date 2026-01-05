class DeliveryModel {
  final String orderId;
  final String customerName;
  final String customerAddress;
  final String deliveryAddress;
  final String estimatedTime;
  final String restaurantName;
  final List<DeliveryItem> items;
  final String customerAvatar;
  final String customerPhone;
  final double? totalAmount;
  final String currency;

  const DeliveryModel({
    required this.orderId,
    required this.customerName,
    required this.customerAddress,
    required this.deliveryAddress,
    required this.estimatedTime,
    required this.restaurantName,
    required this.items,
    required this.customerAvatar,
    this.customerPhone = '',
    this.totalAmount,
    this.currency = '₹',
  });

  DeliveryModel copyWith({
    String? orderId,
    String? customerName,
    String? customerAddress,
    String? deliveryAddress,
    String? estimatedTime,
    String? restaurantName,
    List<DeliveryItem>? items,
    String? customerAvatar,
    String? customerPhone,
    double? totalAmount,
    String? currency,
  }) {
    return DeliveryModel(
      orderId: orderId ?? this.orderId,
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
      customerAvatar: customerAvatar ?? this.customerAvatar,
      customerPhone: customerPhone ?? this.customerPhone,
      totalAmount: totalAmount ?? this.totalAmount,
      currency: currency ?? this.currency,
    );
  }
}

class DeliveryItem {
  final String name;
  final String description;
  final String image;
  final int quantity;

  const DeliveryItem({
    required this.name,
    required this.description,
    required this.image,
    required this.quantity,
  });
}
