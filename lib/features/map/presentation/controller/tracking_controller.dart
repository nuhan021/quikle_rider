// ignore_for_file: deprecated_member_use

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// Static points for vendor and customer; swap with live values when wired.
const LatLng _vendorLocation = LatLng(26.78559602360313, 73.59072604921964); // Bengaluru vendor
const LatLng _userLocation = LatLng(26.791236475585176, 73.58672901218489); // Bengaluru customer
const LatLng _dummyCurrentLocation = LatLng(26.788910909422594, 73.58118541371569); // Bengaluru rider



//Load the key from .env
final String googleMapsApiKey =
    dotenv.env['GOOGLE_MAP_API_KEY']?.trim() ??
        const String.fromEnvironment(
          'GOOGLE_MAP_API_KEY',
          defaultValue: '',
        );
class TrackingController extends GetxController {
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  final Completer<GoogleMapController> mapController = Completer();
  final Rxn<LatLng> currentLocation = Rxn<LatLng>();
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final RxBool isTrackingLive = false.obs;
  bool _mapActive = true;
  StreamSubscription<Position>? positionSubscription;
  LatLng? _lastPolylineOrigin;

  TrackingController();

  @override
  void onInit() {
    super.onInit();
    _setFixedMarkers();
    _determinePosition();
  }

  @override
  void onClose() {
    _mapActive = false;
    positionSubscription?.cancel();
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

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled. Showing dummy location.');
      await _useDummyLocation();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permissions are denied. Showing dummy location.');
        await _useDummyLocation();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError(
        'Location permissions are permanently denied. Showing dummy location.',
      );
      await _useDummyLocation();
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        // ignore: deprecated_member_use
        desiredAccuracy: LocationAccuracy.high,
      );

      final newLocation = LatLng(position.latitude, position.longitude);
      currentLocation.value = newLocation;
      _setCurrentMarker(newLocation);
      _setFixedMarkers();
      await _buildRoutePolylines();
      await _fitCameraToPoints();
      await _moveCameraToPosition(newLocation, 16);
    } catch (e) {
      _showError('Unable to fetch GPS location. Showing dummy location.');
      await _useDummyLocation();
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
        _setCurrentMarker(newLocation);
        _buildRoutePolylines();
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
      (marker) => marker.markerId.value == 'vendor' || marker.markerId.value == 'user',
    );
    markers.addAll([
      _buildMarker(
        'vendor',
        'Vendor Location',
        _vendorLocation,
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueOrange),
        zIndex: 0.5,
      ),
      _buildMarker(
        'user',
        'Customer Location',
        _userLocation,
        BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        zIndex: 0.5,
      ),
    ]);
  }

  Future<void> _buildRoutePolylines() async {
    final origin = currentLocation.value;
    if (origin == null) return;

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
      (origin, _vendorLocation, 'current-to-vendor'),
      (_vendorLocation, _userLocation, 'vendor-to-user'),
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
    _lastPolylineOrigin = origin;
    await _fitCameraToPoints();
  }

  Future<void> _useDummyLocation() async {
    currentLocation.value = _dummyCurrentLocation;
    _setCurrentMarker(_dummyCurrentLocation);
    _setFixedMarkers();
    await _buildRoutePolylines();
    await _fitCameraToPoints();
    await _moveCameraToPosition(_dummyCurrentLocation, 14);
  }

  Future<void> _fitCameraToPoints() async {
    final current = currentLocation.value;
    if (!_mapActive || !mapController.isCompleted || current == null) return;

    final boundsPoints = [current, _vendorLocation, _userLocation];
    double? south, north, west, east;
    for (final p in boundsPoints) {
      south = south == null ? p.latitude : (south > p.latitude ? p.latitude : south);
      north = north == null ? p.latitude : (north < p.latitude ? p.latitude : north);
      west = west == null ? p.longitude : (west > p.longitude ? p.longitude : west);
      east = east == null ? p.longitude : (east < p.longitude ? p.longitude : east);
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
}
