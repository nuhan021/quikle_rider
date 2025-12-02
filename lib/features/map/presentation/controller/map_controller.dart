import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/utils/device/device_utility.dart';
import 'package:quikle_rider/features/map/presentation/model/delivery_model.dart';

class MapController extends GetxController {
  final RxBool isOnline = true.obs;
  final Rx<DeliveryModel?> currentDelivery = Rx<DeliveryModel?>(null);
  final RxBool isFetchingLocation = false.obs;
  final Rxn<LatLng> currentPosition = Rxn<LatLng>();
  final RxnString locationError = RxnString();
  final RxString currentAddress = 'Fetching location...'.obs;
  final Rxn<LatLng> selectedDestination = Rxn<LatLng>();
  final RxString selectedDestinationAddress = ''.obs;
  GoogleMapController? _mapController;

  LatLng get fallbackLocation =>
      const LatLng(37.42796133580664, -122.085749655962);

  bool get hasUserLocation => currentPosition.value != null;
  bool get hasActiveRoute =>
      hasUserLocation && selectedDestination.value != null;

  Set<Marker> get mapMarkers {
    final markers = <Marker>{
      Marker(
        
        markerId: const MarkerId('current-location'),
        position: currentPosition.value ?? fallbackLocation,
        infoWindow: const InfoWindow(title: 'You are here'),
      ),
    };

    final destination = selectedDestination.value;
    if (destination != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('selected-destination'),
          position: destination,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: 'Destination',
            snippet: selectedDestinationAddress.value.isNotEmpty
                ? selectedDestinationAddress.value
                : _formatLatLng(destination),
          ),
          draggable: true,
          onDragEnd: updateDestinationFromDrag,
        ),
      );
    }
    return markers;
  }

  Set<Polyline> get activePolylines {
    if (!hasActiveRoute) return {};
    return {
      Polyline(
        polylineId: const PolylineId('selected-route'),
        points: _routePoints,
        color: Colors.blueAccent,
        width: 5,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
      ),
    };
  }

  String get destinationInfoText {
    final destination = selectedDestination.value;
    if (destination == null) {
      return 'Tap anywhere on the map to choose a destination.';
    }

    if (selectedDestinationAddress.value.isNotEmpty &&
        selectedDestinationAddress.value != 'Resolving address...') {
      return selectedDestinationAddress.value;
    }

    return _formatLatLng(destination);
  }

  String get routeDistanceLabel {
    final distance = _routeDistanceInMeters;
    if (distance == null) return '';
    if (distance >= 1000) {
      return '${(distance / 1000).toStringAsFixed(2)} km away';
    }
    return '${distance.toStringAsFixed(0)} m away';
  }

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
      if (selectedDestination.value != null) {
        _fitCameraToRoute();
      }
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

      currentAddress.value = formatted.isNotEmpty
          ? formatted
          : 'Unable to determine address.';
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

  void handleMapTap(LatLng position) {
    selectedDestination.value = position;
    selectedDestinationAddress.value = 'Resolving address...';
    _resolveDestinationAddress(position);
    _fitCameraToRoute();
  }

  void updateDestinationFromDrag(LatLng position) {
    selectedDestination.value = position;
    selectedDestinationAddress.value = 'Resolving address...';
    _resolveDestinationAddress(position);
    _fitCameraToRoute();
  }

  void clearSelectedDestination() {
    selectedDestination.value = null;
    selectedDestinationAddress.value = '';
    _moveCameraToCurrentLocation();
  }

  Future<void> openRouteInMaps() async {
    final destination = selectedDestination.value;
    if (destination == null) {
      Get.snackbar(
        'No destination',
        'Tap on the map to select a destination first.',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    final buffer = StringBuffer('https://www.google.com/maps/dir/?api=1');
    final origin = currentPosition.value;
    if (origin != null) {
      buffer.write('&origin=${origin.latitude},${origin.longitude}');
    }
    buffer.write(
      '&destination=${destination.latitude},${destination.longitude}',
    );
    buffer.write('&travelmode=driving');

    try {
      AppDeviceUtility.launchUrl(buffer.toString());
    } catch (_) {
      Get.snackbar(
        'Unable to launch Maps',
        'Please install Google Maps or try again later.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
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

  List<LatLng> get _routePoints {
    final start = currentPosition.value;
    final destination = selectedDestination.value;
    if (start == null || destination == null) return const [];
    return [start, destination];
  }

  double? get _routeDistanceInMeters {
    final start = currentPosition.value;
    final destination = selectedDestination.value;
    if (start == null || destination == null) return null;
    return Geolocator.distanceBetween(
      start.latitude,
      start.longitude,
      destination.latitude,
      destination.longitude,
    );
  }

  void _resolveDestinationAddress(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) {
        selectedDestinationAddress.value = _formatLatLng(position);
        return;
      }
      final place = placemarks.first;
      final segments = [
        if ((place.name ?? '').isNotEmpty) place.name!,
        if ((place.locality ?? '').isNotEmpty) place.locality!,
        if ((place.administrativeArea ?? '').isNotEmpty)
          place.administrativeArea!,
        if ((place.country ?? '').isNotEmpty) place.country!,
      ];
      final formatted = segments.where((e) => e.trim().isNotEmpty).join(', ');
      selectedDestinationAddress.value = formatted.isNotEmpty
          ? formatted
          : _formatLatLng(position);
    } catch (error) {
      debugPrint('MapController: Failed to resolve destination - $error');
      selectedDestinationAddress.value = _formatLatLng(position);
    }
  }

  String _formatLatLng(LatLng position) {
    return '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}';
  }

  void _fitCameraToRoute() {
    final start = currentPosition.value;
    final destination = selectedDestination.value;
    if (_mapController == null || start == null || destination == null) return;

    final southwest = LatLng(
      min(start.latitude, destination.latitude),
      min(start.longitude, destination.longitude),
    );
    final northeast = LatLng(
      max(start.latitude, destination.latitude),
      max(start.longitude, destination.longitude),
    );

    _mapController!.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(southwest: southwest, northeast: northeast),
        60,
      ),
    );
  }
}
