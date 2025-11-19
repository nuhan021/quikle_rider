import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/features/map/presentation/model/delivery_model.dart';

class MapController extends GetxController {
  final RxBool isOnline = true.obs;
  final Rx<DeliveryModel?> currentDelivery = Rx<DeliveryModel?>(null);
  final RxBool isFetchingLocation = false.obs;
  final Rxn<LatLng> currentPosition = Rxn<LatLng>();
  final RxnString locationError = RxnString();
  final RxString currentAddress = 'Fetching location...'.obs;
  GoogleMapController? _mapController;

  LatLng get fallbackLocation =>
      const LatLng(37.42796133580664, -122.085749655962);

  bool get hasUserLocation => currentPosition.value != null;

  @override
  void onInit() {
    _loadDeliveryData();
    requestCurrentLocation();
    super.onInit();
  }

  // Toggle online status
  void toggleOnlineStatus() {
    isOnline.toggle();
  }

  // Load delivery data (simulate API call)
  void _loadDeliveryData() {
    currentDelivery.value = const DeliveryModel(
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
  }

  Future<void> requestCurrentLocation() async {
    isFetchingLocation.value = true;
    locationError.value = null;
    currentAddress.value = 'Fetching location...';

    try {
      final hasPermission = await _ensurePermissions();
      if (!hasPermission) {
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      currentPosition.value = LatLng(position.latitude, position.longitude);
      await _updateAddressFromCoordinates();
      _moveCameraToCurrentLocation();
    } catch (error) {
      locationError.value =
          'Unable to fetch current location. Please try again.';
      debugPrint('MapController: $error');
    } finally {
      isFetchingLocation.value = false;
    }
  }

  Future<bool> _ensurePermissions() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      locationError.value =
          'Enable location services to view your position on the map.';
      return false;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {
      locationError.value =
          'Location permission is permanently denied. Please enable it from Settings.';
      return false;
    }

    if (permission == LocationPermission.denied) {
      locationError.value =
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
    final target = currentPosition.value;
    if (_mapController == null || target == null) return;
    _mapController!.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: target, zoom: 15.5),
      ),
    );
  }

  Future<void> _updateAddressFromCoordinates() async {
    final position = currentPosition.value;
    if (position == null) return;

    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      if (placemarks.isEmpty) {
        currentAddress.value = 'No address found for the current location.';
        return;
      }

      final place = placemarks.first;
      final line1Segments = <String>[
        if ((place.street ?? '').trim().isNotEmpty) place.street!,
        if ((place.locality ?? '').trim().isNotEmpty) place.locality!,
      ];
      final line2Segments = <String>[
        if ((place.administrativeArea ?? '').trim().isNotEmpty)
          place.administrativeArea!,
        if ((place.country ?? '').trim().isNotEmpty) place.country!,
      ];

      final formatted = [
        line1Segments.join(', '),
        line2Segments.join(', '),
      ].where((line) => line.trim().isNotEmpty).join('\n');

      currentAddress.value =
          formatted.isNotEmpty ? formatted : 'Unable to determine address.';
    } catch (error) {
      debugPrint('MapController: Failed to resolve address - $error');
      currentAddress.value = 'Unable to determine address.';
    }
  }

  // Call customer
  void callCustomer() {
    // Implement call functionality
    debugPrint('Calling customer: ${currentDelivery.value?.customerName}');
  }

  // Message customer
  void messageCustomer() {
    // Implement message functionality
    debugPrint('Messaging customer: ${currentDelivery.value?.customerName}');
  }

  // Mark as delivered
  void markAsDelivered(BuildContext context) {
    // Navigate to parcel done screen
    Navigator.pushNamed(context, '/parcel-done');
  }

  @override
  void onClose() {
    _mapController?.dispose();
    super.onClose();
  }
}
