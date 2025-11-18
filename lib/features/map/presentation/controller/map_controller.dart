import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quikle_rider/features/map/presentation/model/delivery_model.dart';

class MapController extends ChangeNotifier {
  bool _isOnline = true;
  DeliveryModel? _currentDelivery;
  bool _isFetchingLocation = false;
  LatLng? _currentPosition;
  String? _locationError;
  GoogleMapController? _mapController;

  // Getters
  bool get isOnline => _isOnline;
  DeliveryModel? get currentDelivery => _currentDelivery;
  bool get isFetchingLocation => _isFetchingLocation;
  LatLng? get currentPosition => _currentPosition;
  bool get hasUserLocation => _currentPosition != null;
  String? get locationError => _locationError;

  LatLng get fallbackLocation =>
      const LatLng(37.42796133580664, -122.085749655962);

  // Constructor
  MapController() {
    _loadDeliveryData();
    requestCurrentLocation();
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

  Future<void> requestCurrentLocation() async {
    _isFetchingLocation = true;
    _locationError = null;
    notifyListeners();

    try {
      final hasPermission = await _ensurePermissions();
      if (!hasPermission) return;

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      _currentPosition = LatLng(position.latitude, position.longitude);
      _moveCameraToCurrentLocation();
    } catch (error) {
      _locationError = 'Unable to fetch current location. Please try again.';
      debugPrint('MapController: $error');
    } finally {
      _isFetchingLocation = false;
      notifyListeners();
    }
  }

  Future<bool> _ensurePermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _locationError =
          'Enable location services to view your position on the map.';
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      _locationError =
          'Location permission is permanently denied. Please enable it from Settings.';
      return false;
    }

    if (permission == LocationPermission.denied) {
      _locationError =
          'Location permission denied. Please allow access to continue.';
      return false;
    }

    return true;
  }

  void attachMapController(GoogleMapController controller) {
    _mapController = controller;
    _moveCameraToCurrentLocation();
  }

  void _moveCameraToCurrentLocation() {
    if (_mapController == null || _currentPosition == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: _currentPosition!, zoom: 15.5),
      ),
    );
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
    _mapController?.dispose();
    super.dispose();
  }
}
