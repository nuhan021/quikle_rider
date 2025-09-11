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
