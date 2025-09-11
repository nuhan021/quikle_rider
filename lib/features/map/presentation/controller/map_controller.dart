import 'package:flutter/material.dart';
import 'package:quikle_rider/features/map/presentation/model/delivery_model.dart';

class MapController extends ChangeNotifier {
  bool _isOnline = true;
  DeliveryModel? _currentDelivery;

  // Getters
  bool get isOnline => _isOnline;
  DeliveryModel? get currentDelivery => _currentDelivery;

  // Constructor
  MapController() {
    _loadDeliveryData();
  }

  // Toggle online status
  void toggleOnlineStatus() {
    _isOnline = !_isOnline;
    notifyListeners();
  }

  // Load delivery data (simulate API call)
  void _loadDeliveryData() {
    _currentDelivery = const DeliveryModel(
      customerName: 'Aanya Desai',
      customerAddress: '123 Main St, Bangkok',
      deliveryAddress: '789 River Rd, Apartment 3B, Riverside Mohakhali',
      estimatedTime: '09:45 min',
      restaurantName: 'Sushi Express',
      customerAvatar: 'assets/images/avatar.png',
      items: [
        DeliveryItem(
          name: 'Dragon Roll Set',
          description: '8 pieces, extra wasabi',
          image: 'assets/images/foodimage.png',
          quantity: 1,
        ),
        DeliveryItem(
          name: 'Miso Soup',
          description: 'Regular size',
          image: 'assets/images/foodimage.png',
          quantity: 1,
        ),
      ],
    );
    notifyListeners();
  }

  // Call customer
  void callCustomer() {
    // Implement call functionality
    debugPrint('Calling customer: ${_currentDelivery?.customerName}');
  }

  // Message customer
  void messageCustomer() {
    // Implement message functionality
    debugPrint('Messaging customer: ${_currentDelivery?.customerName}');
  }

  // Mark as delivered
  void markAsDelivered(BuildContext context) {
    // Navigate to parcel done screen
    Navigator.pushNamed(context, '/parcel-done');
  }

  @override
  void dispose() {
    super.dispose();
  }
}
