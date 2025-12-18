class DeliveryModel {
  final String customerName;
  final String customerAddress;
  final String deliveryAddress;
  final String estimatedTime;
  final String restaurantName;
  final List<DeliveryItem> items;
  final String customerAvatar;

  const DeliveryModel({
    required this.customerName,
    required this.customerAddress,
    required this.deliveryAddress,
    required this.estimatedTime,
    required this.restaurantName,
    required this.items,
    required this.customerAvatar,
  });

  DeliveryModel copyWith({
    String? customerName,
    String? customerAddress,
    String? deliveryAddress,
    String? estimatedTime,
    String? restaurantName,
    List<DeliveryItem>? items,
    String? customerAvatar,
  }) {
    return DeliveryModel(
      customerName: customerName ?? this.customerName,
      customerAddress: customerAddress ?? this.customerAddress,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      estimatedTime: estimatedTime ?? this.estimatedTime,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
      customerAvatar: customerAvatar ?? this.customerAvatar,
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
