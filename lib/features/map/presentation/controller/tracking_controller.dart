// ignore_for_file: deprecated_member_use

import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quikle_rider/core/services/location_services.dart';
import 'package:quikle_rider/core/utils/logging/logger.dart';

// Load the key from .env or --dart-define.
final String googleMapsApiKey = dotenv.env['GOOGLE_MAP_API_KEY'] ?? '';

class TrackingController extends GetxController {
  final Rxn<LatLng> vendorLocation = Rxn<LatLng>();
  final Rxn<LatLng> customerLocation = Rxn<LatLng>();
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;

  final Completer<GoogleMapController> mapController = Completer();
  final Rxn<LatLng> currentLocation = Rxn<LatLng>();
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final RxBool isTrackingLive = false.obs;
  bool _mapActive = true;
  bool _initialized = false;
  StreamSubscription<Position>? positionSubscription;
  LatLng? _lastPolylineOrigin;
  bool _partnerAndCustomerProvided = false;

  final LocationServices _locationServices = LocationServices.instance;
  StreamSubscription? _locationServiceSubscription;

  TrackingController();

  @override
  void onInit() {
    super.onInit();
    ensureInitialized();
  }

  Future<void> ensureInitialized() async {
    if (_initialized) return;
    _initialized = true;
    await _initTracking();
  }

  Future<void> _initTracking() async {
    _setFixedMarkers();
    await _seedInitialPosition();
    await _determinePosition();

    await _locationServices.connectAndStart();
    _locationServiceSubscription = _locationServices.socketResponse.listen((
      location,
    ) {
      vendorLocation.value = LatLng(location['lat']!, location['lng']!);
      _setFixedMarkers();
      _buildRoutePolylines();
      _fitCameraToPoints();
    });

    // Start live tracking immediately so markers refresh as GPS updates.
    await startLiveTracking();
    AppLoggerHelper.debug(
      'Current location after init: ${currentLocation.value}',
    );
  }

  /// Allow external screens to provide vendor/customer coordinates.
  void updatePartnerAndCustomer({LatLng? vendor, LatLng? customer}) async {
    bool changed = false;
    if (vendor != null) {
      vendorLocation.value = vendor;
      _partnerAndCustomerProvided = true;
      changed = true;
    }
    if (customer != null) {
      customerLocation.value = customer;
      _partnerAndCustomerProvided = true;
      changed = true;
    }

    if (changed) {
      _setFixedMarkers();
      await _buildRoutePolylines();
      _fitCameraToPoints();
    }
  }

  @override
  void onClose() {
    _mapActive = false;
    positionSubscription?.cancel();
    _locationServiceSubscription?.cancel();
    _locationServices.disconnect();
    super.onClose();
  }

  Future<void> cleanUp() async {
    _mapActive = false;
    positionSubscription?.cancel();
    if (mapController.isCompleted) {
      final controller = await mapController.future;
      controller.dispose();
    }
  }

  Future<void> onMapCreated(GoogleMapController controller) async {
    if (!mapController.isCompleted) {
      mapController.complete(controller);
    }
    _mapActive = true;

    final startPosition = currentLocation.value;
    if (startPosition != null) {
      await _moveCameraToPosition(startPosition, 16);
    }
    await _fitCameraToPoints();
  }

  Future<void> _seedInitialPosition() async {
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null) {
        final known = LatLng(lastKnown.latitude, lastKnown.longitude);
        currentLocation.value = known;
        _setCurrentMarker(known);
        _setFixedMarkers();
        await _buildRoutePolylines();
        await _fitCameraToPoints();
        return;
      }
    } catch (_) {}

    // Don't fall back to a dummy coordinate; wait for a real GPS fix.
    currentLocation.value = null;
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError(
        'Location services are disabled. Unable to show your current location.',
      );
      _clearCurrentMarker();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError(
          'Location permissions are denied. Unable to show your current location.',
        );
        _clearCurrentMarker();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError(
        'Location permissions are permanently denied. Unable to show your current location.',
      );
      _clearCurrentMarker();
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      currentLocation.value = newLocation;
      _ensurePartnerAndCustomerNearCurrent(newLocation);
      _setCurrentMarker(newLocation);
      _setFixedMarkers();
      await _buildRoutePolylines();
      await _fitCameraToPoints();
      await _moveCameraToPosition(newLocation, 16);
    } catch (e) {
      _showError('Unable to fetch GPS location.');
      _clearCurrentMarker();
    }
  }

  Future<void> _moveCameraToPosition(LatLng position, double zoom) async {
    if (!_mapActive || !mapController.isCompleted) return;
    final controller = await mapController.future;
    await controller.animateCamera(
      CameraUpdate.newCameraPosition(
        CameraPosition(target: position, zoom: zoom),
      ),
    );
  }

  Future<void> startLiveTracking() async {
    if (isTrackingLive.value) return;

    if (currentLocation.value == null) {
      await _determinePosition();
    }
    if (currentLocation.value == null) {
      _showError('Current location unavailable. Please enable GPS.');
      return;
    }

    isTrackingLive.value = true;
    positionSubscription = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 5,
      ),
    ).listen(
      (Position position) {
        final newLocation = LatLng(position.latitude, position.longitude);
        currentLocation.value = newLocation;
        _ensurePartnerAndCustomerNearCurrent(newLocation);
        _setCurrentMarker(newLocation);
        _buildRoutePolylines();
        _fitCameraToPoints();
      },
      onError: (e) {
        _showError('Error during live tracking: ${e.toString()}');
        stopLiveTracking();
      },
    );
  }

  void stopLiveTracking() {
    positionSubscription?.cancel();
    positionSubscription = null;
    isTrackingLive.value = false;
  }

  void _clearCurrentMarker() {
    markers.removeWhere((marker) => marker.markerId.value == 'current');
    markers.refresh();
    currentLocation.value = null;
  }

  void _setCurrentMarker(LatLng position) {
    markers.removeWhere((marker) => marker.markerId.value == 'current');
    markers.add(
      _buildMarker(
        'current',
        'Current Location',
        position,
        currentLocationIcon,
        zIndex: 1,
      ),
    );
    markers.refresh();
  }

  Marker _buildMarker(
    String id,
    String title,
    LatLng position,
    BitmapDescriptor icon, {
    double zIndex = 0,
  }) {
    return Marker(
      markerId: MarkerId(id),
      position: position,
      infoWindow: InfoWindow(title: title),
      icon: icon,
      zIndex: zIndex,
    );
  }

  void _setFixedMarkers() {
    markers.removeWhere(
      (marker) =>
          marker.markerId.value == 'vendor' ||
          marker.markerId.value == 'customer' ||
          marker.markerId.value == 'user',
    );
    final vendor = vendorLocation.value;
    final customer = customerLocation.value;
    if (vendor != null) {
      markers.add(
        _buildMarker(
          'vendor',
          'Vendor Location',
          vendor,
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
          zIndex: 0.5,
        ),
      );
    }
    if (customer != null) {
      markers.add(
        _buildMarker(
          'customer',
          'Customer Location',
          customer,
          BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
          zIndex: 0.5,
        ),
      );
    }
    markers.refresh();
  }

  Future<void> _buildRoutePolylines() async {
    final origin = currentLocation.value;
    final vendor = vendorLocation.value;
    final customer = customerLocation.value;
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

    final apiKey = googleMapsApiKey;
    if (apiKey.isEmpty) {
      _showError(
        'Google Maps API key missing. Add GOOGLE_MAP_API_KEY to .env or pass it via --dart-define.',
      );
      return;
    }

    final polylinePoints = PolylinePoints(apiKey: apiKey);
    final legs = [
      (origin, vendor, 'current-to-vendor'),
      (vendor, customer, 'vendor-to-user'),
    ];

    polylines.clear();

    for (final leg in legs) {
      final result = await polylinePoints.getRouteBetweenCoordinates(
        request: PolylineRequest(
          origin: PointLatLng(leg.$1.latitude, leg.$1.longitude),
          destination: PointLatLng(leg.$2.latitude, leg.$2.longitude),
          mode: TravelMode.driving,
        ),
      );

      if (result.points.isEmpty) {
        _showError('Could not draw route for ${leg.$3}.');
        AppLoggerHelper.debug('Polyline empty for ${leg.$3}. Status: ${result.status}');
        continue;
      }

      final points = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      polylines.add(
        Polyline(
          polylineId: PolylineId(leg.$3),
          color: Colors.blue.shade700,
          width: 6,
          points: points,
        ),
      );
    }
    polylines.refresh();
    _lastPolylineOrigin = origin;
    await _fitCameraToPoints();
  }

  Future<void> _fitCameraToPoints() async {
    final current = currentLocation.value;
    if (!_mapActive || !mapController.isCompleted || current == null) return;

    final boundsPoints = <LatLng>[
      current,
      if (vendorLocation.value != null) vendorLocation.value!,
      if (customerLocation.value != null) customerLocation.value!,
    ];
    double? south, north, west, east;
    for (final p in boundsPoints) {
      south = south == null
          ? p.latitude
          : (south > p.latitude ? p.latitude : south);
      north = north == null
          ? p.latitude
          : (north < p.latitude ? p.latitude : north);
      west = west == null
          ? p.longitude
          : (west > p.longitude ? p.longitude : west);
      east = east == null
          ? p.longitude
          : (east < p.longitude ? p.longitude : east);
    }

    if (south == null || north == null || west == null || east == null) return;

    final controller = await mapController.future;
    await controller.animateCamera(
      CameraUpdate.newLatLngBounds(
        LatLngBounds(
          southwest: LatLng(south, west),
          northeast: LatLng(north, east),
        ),
        60,
      ),
    );
  }

  void _showError(String message) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _ensurePartnerAndCustomerNearCurrent(LatLng origin) {
    if (_partnerAndCustomerProvided) return;

    final vendor = vendorLocation.value;
    final customer = customerLocation.value;

    if (vendor == null) {
      vendorLocation.value = _offsetLatLng(
        origin,
        metersNorth: 140,
        metersEast: 90,
      );
    }

    if (customer == null) {
      customerLocation.value = _offsetLatLng(
        origin,
        metersNorth: -120,
        metersEast: -80,
      );
    }
  }

  LatLng _offsetLatLng(
    LatLng origin, {
    required double metersNorth,
    required double metersEast,
  }) {
    const metersPerDegreeLat = 111320.0;
    final dLat = metersNorth / metersPerDegreeLat;
    final metersPerDegreeLng =
        metersPerDegreeLat * cos(origin.latitude * pi / 180);
    final dLng = metersEast / metersPerDegreeLng;
    return LatLng(origin.latitude + dLat, origin.longitude + dLng);
  }
}
