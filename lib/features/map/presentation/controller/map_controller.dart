import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/utils/device/device_utility.dart';
import 'package:quikle_rider/features/all_orders/models/rider_order_model.dart';
import 'package:quikle_rider/features/map/presentation/model/delivery_model.dart';
import 'package:quikle_rider/features/messages/presentation/massage_screen.dart';

class MapController extends GetxController {
  // Load the key from .env or --dart-define (same as TrackingController).
  static final String _googleMapsApiKey =
      dotenv.env['GOOGLE_MAP_API_KEY'] ?? '';
  static const LatLng _hardcodedLocation = LatLng(28.6139, 77.209);
  final RxBool isOnline = true.obs;
  final Rx<DeliveryModel?> currentDelivery = Rx<DeliveryModel?>(null);
  final RxBool isFetchingLocation = false.obs;
  final Rxn<LatLng> currentPosition = Rxn<LatLng>();
  final Rxn<LatLng> vendorPosition = Rxn<LatLng>();
  final Rxn<LatLng> customerPosition = Rxn<LatLng>();
  final RxnString locationError = RxnString();
  final RxString currentAddress = 'Fetching location...'.obs;
  final RxString vendorPickupAddress = ''.obs;
  final Rxn<LatLng> selectedDestination = Rxn<LatLng>();
  final RxString selectedDestinationAddress = ''.obs;
  final RxSet<Polyline> routePolylines = <Polyline>{}.obs;
  GoogleMapController? _mapController;
  String? _activeOrderId;
  LatLng? _lastPolylineOrigin;
  bool _isBuildingPolylines = false;
  LatLng get fallbackLocation => _hardcodedLocation;
  bool get hasUserLocation => currentPosition.value != null;
  bool get hasActiveRoute =>
      hasUserLocation && selectedDestination.value != null;
  bool get hasActiveOrder => _activeOrderId != null;
  Set<Marker> get mapMarkers {
    final markers = <Marker>{};
    final current = currentPosition.value;
    if (current != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('current-location'),
          position: current,
          infoWindow: const InfoWindow(title: 'You are here'),
        ),
      );
    }

    final vendor = vendorPosition.value;
    if (vendor != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('vendor-location'),
          position: vendor,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueOrange,
          ),
          infoWindow: InfoWindow(
            title: currentDelivery.value?.restaurantName ?? 'Vendor',
          ),
        ),
      );
    }

    final customer = customerPosition.value;
    if (customer != null) {
      markers.add(
        Marker(
          markerId: const MarkerId('customer-location'),
          position: customer,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
          infoWindow: InfoWindow(
            title: currentDelivery.value?.customerName ?? 'Customer',
          ),
        ),
      );
    }

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
    final polylines = <Polyline>{};
    if (routePolylines.isNotEmpty) {
      polylines.addAll(routePolylines);
    } else if (hasActiveRoute) {
      polylines.add(
        Polyline(
          polylineId: const PolylineId('selected-route'),
          points: _routePoints,
          color: Colors.blueAccent,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
        ),
      );
    }
    return polylines;
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
    _loadDeliveryData(Get.arguments);
    requestCurrentLocation();

    super.onInit();
  }

  // Toggle online status
  void toggleOnlineStatus() {
    isOnline.toggle();
  }

  void applyOrderIfNeeded(RiderOrder order) {
    if (_activeOrderId == order.id) return;
    _applyOrder(order);
  }

  // Load delivery data (supports RiderOrder via Get.arguments)
  void _loadDeliveryData(dynamic args) {
    if (args is RiderOrder) {
      _applyOrder(args);
      return;
    }
    currentDelivery.value = null;
  }

  void _applyOrder(RiderOrder order) {
    _activeOrderId = order.id;

    final vendor = order.metadata?.vendorInfo;
    final shipping = order.metadata?.shippingAddress;

    final restaurantName = (vendor?.storeName ?? '').trim();
    final customerName = (shipping?.fullName ?? '').trim();
    final deliveryAddress = (shipping?.addressLine1 ?? '').trim();

    final estimated = order.etaMinutes != null
        ? '${order.etaMinutes} min'
        : (order.estimatedDelivery?.toIso8601String() ?? '');

    currentDelivery.value = DeliveryModel(
      orderId: order.id,
      parentOrderId: order.parentOrderId,
      status: order.status,
      deliveryType: order.deliveryType,
      baseRate: _parseDouble(order.baseRate),
      pickupDistanceKm: order.pickupDistanceKm,
      customerName: customerName.isNotEmpty ? customerName : 'Customer',
      customerAddress: deliveryAddress.isNotEmpty
          ? deliveryAddress
          : 'Delivery location',
      deliveryAddress: deliveryAddress.isNotEmpty
          ? deliveryAddress
          : 'Delivery location',
      estimatedTime: estimated,
      restaurantName: restaurantName.isNotEmpty ? restaurantName : 'Vendor',
      customerAvatar: 'assets/images/avatar.png',
      customerPhone: (shipping?.phoneNumber ?? '').trim(),
      totalAmount: _parseDouble(order.total),
      items: const [],
    );

    if (vendor?.storeLatitude != null && vendor?.storeLongitude != null) {
      vendorPickupAddress.value = 'Resolving pickup address...';
      vendorPosition.value = LatLng(
        vendor!.storeLatitude!,
        vendor.storeLongitude!,
      );
      _resolveVendorAddressFromCoordinates(vendorPosition.value!);
    } else {
      vendorPosition.value = null;
      vendorPickupAddress.value = '';
    }

    if (shipping?.latitude != null && shipping?.longitude != null) {
      customerPosition.value = LatLng(shipping!.latitude!, shipping.longitude!);
    } else if ((shipping?.addressLine1 ?? '').trim().isNotEmpty) {
      _resolveCustomerCoordinatesFromAddress(shipping!.addressLine1!.trim());
    } else {
      customerPosition.value = null;
    }

    _fitCameraToOrder();
    _buildRoutePolylines();
  }

  void applyDeliverySnapshot(DeliveryModel delivery, {String? orderId}) {
    _activeOrderId = (orderId != null && orderId.isNotEmpty) ? orderId : null;
    currentDelivery.value = delivery;
    vendorPosition.value = null;
    customerPosition.value = null;
    vendorPickupAddress.value = '';
    selectedDestination.value = null;
    selectedDestinationAddress.value = '';
    routePolylines.clear();
  }

  void clearCurrentDelivery() {
    _activeOrderId = null;
    currentDelivery.value = null;
    vendorPosition.value = null;
    customerPosition.value = null;
    vendorPickupAddress.value = '';
    selectedDestination.value = null;
    selectedDestinationAddress.value = '';
    routePolylines.clear();
  }

  double? _parseDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
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
        desiredAccuracy: LocationAccuracy.high,
      );
      currentPosition.value = LatLng(position.latitude, position.longitude);
      debugPrint(
        'MapController: Current location → lat=${position.latitude}, '
        'lng=${position.longitude}',
      );
      await _updateAddressFromCoordinates();
      if (hasActiveOrder) {
        _fitCameraToOrder();
      } else {
        _moveCameraToCurrentLocation();
      }
      await _buildRoutePolylines();
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
    _fitCameraToOrder();
  }

  void detachMapController() {
    _mapController = null;
  }

  void _moveCameraToCurrentLocation() {
    final target = currentPosition.value;
    if (_mapController == null || target == null) return;
    try {
      _mapController!.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: target, zoom: 15.5),
        ),
      );
    } catch (error) {
      debugPrint('MapController: animateCamera failed - $error');
      _mapController = null;
    }
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
    Get.to(MassageScreen());
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

  /// Refresh route polylines - called when vendor/customer positions are updated
  Future<void> refreshRoutePolylines() async {
    await _buildRoutePolylines();
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
    detachMapController();
    super.onClose();
  }

  Future<void> _buildRoutePolylines() async {
    if (_isBuildingPolylines) return;
    final origin = currentPosition.value;
    final vendor = vendorPosition.value;
    final customer = customerPosition.value;
    if (origin == null || vendor == null || customer == null) return;

    if (_lastPolylineOrigin != null) {
      final diff = Geolocator.distanceBetween(
        _lastPolylineOrigin!.latitude,
        _lastPolylineOrigin!.longitude,
        origin.latitude,
        origin.longitude,
      );
      if (diff < 15) return;
    }

    final apiKey = _googleMapsApiKey;
    if (apiKey.isEmpty) {
      debugPrint(
        'MapController: Missing Google Maps API key for polyline routes.',
      );
      return;
    }

    _isBuildingPolylines = true;
    final polylinePoints = PolylinePoints(apiKey: apiKey);
    final legs = [
      (origin, vendor, 'current-to-vendor'),
      (vendor, customer, 'vendor-to-customer'),
    ];

    routePolylines.clear();

    try {
      for (final leg in legs) {
        final result = await polylinePoints.getRouteBetweenCoordinates(
          // ignore: deprecated_member_use
          request: PolylineRequest(
            origin: PointLatLng(leg.$1.latitude, leg.$1.longitude),
            destination: PointLatLng(leg.$2.latitude, leg.$2.longitude),
            mode: TravelMode.driving,
          ),
        );

        if (result.points.isEmpty) {
          debugPrint(
            'MapController: Polyline empty for ${leg.$3} (status: ${result.status}).',
          );
          continue;
        }

        final points = result.points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList();

        routePolylines.add(
          Polyline(
            polylineId: PolylineId(leg.$3),
            color: Colors.blue.shade700,
            width: 6,
            points: points,
          ),
        );
      }
      routePolylines.refresh();
      _lastPolylineOrigin = origin;
    } catch (error) {
      debugPrint('MapController: Failed to build polylines - $error');
    } finally {
      _isBuildingPolylines = false;
    }
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

    try {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(southwest: southwest, northeast: northeast),
          60,
        ),
      );
    } catch (error) {
      debugPrint('MapController: animateCamera failed - $error');
      _mapController = null;
    }
  }

  void _fitCameraToOrder() {
    if (_mapController == null) return;
    final current = currentPosition.value;
    final vendor = vendorPosition.value;
    final customer = customerPosition.value;

    final points = <LatLng>[
      if (current != null) current,
      if (vendor != null) vendor,
      if (customer != null) customer,
    ];
    if (points.length < 2) return;

    var minLat = points.first.latitude;
    var maxLat = points.first.latitude;
    var minLng = points.first.longitude;
    var maxLng = points.first.longitude;

    for (final p in points.skip(1)) {
      minLat = min(minLat, p.latitude);
      maxLat = max(maxLat, p.latitude);
      minLng = min(minLng, p.longitude);
      maxLng = max(maxLng, p.longitude);
    }

    try {
      _mapController!.animateCamera(
        CameraUpdate.newLatLngBounds(
          LatLngBounds(
            southwest: LatLng(minLat, minLng),
            northeast: LatLng(maxLat, maxLng),
          ),
          60,
        ),
      );
    } catch (error) {
      debugPrint('MapController: animateCamera failed - $error');
      _mapController = null;
    }
  }

  Future<void> _resolveCustomerCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);
      if (locations.isEmpty) return;
      if (isClosed) return;
      final first = locations.first;
      customerPosition.value = LatLng(first.latitude, first.longitude);
      _fitCameraToOrder();
      _buildRoutePolylines();
    } catch (error) {
      debugPrint('MapController: Failed to geocode delivery address - $error');
    }
  }

  Future<void> _resolveVendorAddressFromCoordinates(LatLng position) async {
    try {
      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      if (placemarks.isEmpty) return;
      if (isClosed) return;
      final place = placemarks.first;
      final segments = <String>[
        if ((place.name ?? '').trim().isNotEmpty) place.name!,
        if ((place.street ?? '').trim().isNotEmpty) place.street!,
        if ((place.locality ?? '').trim().isNotEmpty) place.locality!,
      ];
      final formatted = segments.where((e) => e.trim().isNotEmpty).join(', ');
      if (formatted.isNotEmpty) {
        vendorPickupAddress.value = formatted;
      }
    } catch (error) {
      debugPrint('MapController: Failed to reverse-geocode vendor - $error');
    }
  }
}
