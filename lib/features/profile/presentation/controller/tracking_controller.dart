import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// --- IMPORTANT: REPLACE WITH YOUR GOOGLE MAPS API KEY ---
// WARNING: Using a key publicly is unsafe. This key is used for PolylinePoints only.
const String googleMapsApiKey = 'AIzaSyD65cza7lynnmbhCN44gs7HupKMnuoU-bo';

class TrackingController extends GetxController {
  BitmapDescriptor sourceIcon = BitmapDescriptor.defaultMarkerWithHue(
    BitmapDescriptor.hueGreen,
  );
  BitmapDescriptor destinationIcon = BitmapDescriptor.defaultMarker;
  BitmapDescriptor currentLocationIcon = BitmapDescriptor.defaultMarker;
  final Completer<GoogleMapController> mapController = Completer();
  final Rxn<LatLng> currentLocation = Rxn<LatLng>();
  final Rxn<LatLng> destination = Rxn<LatLng>();
  final RxSet<Marker> markers = <Marker>{}.obs;
  final RxSet<Polyline> polylines = <Polyline>{}.obs;
  final RxList<LatLng> polylineCoordinates = <LatLng>[].obs;
  int polylineIdCounter = 1;
  StreamSubscription<Position>? positionSubscription;
  final RxBool isTrackingLive = false.obs;
  bool _mapActive = true;
  static const double destinationThresholdMeters = 50.0;

  void onChangeIcon() async {
    // Load custom marker for source
    final BitmapDescriptor customSource = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(200, 100)),
      'assets/images/riderpick.png',
    );

    // Keep current location marker using default styling
    currentLocationIcon = BitmapDescriptor.defaultMarker;

    sourceIcon = customSource;

    // Destination marker also uses default styling
    destinationIcon = BitmapDescriptor.defaultMarker;

    update();
  }

  @override
  void onInit() {
    super.onInit();
    _determinePosition();
    onChangeIcon();
  }

  @override
  void onClose() {
    _mapActive = false;
    positionSubscription?.cancel();
    super.onClose();
  }

  Future<void> cleanUp() async {
    _stopLiveTracking(showMessage: false);
    _mapActive = false;
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
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showError('Location services are disabled.');
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showError('Location permissions are denied.');
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showError(
        'Location permissions are permanently denied, we cannot request permissions.',
      );
      return;
    }

    final position = await Geolocator.getCurrentPosition(
      // ignore: deprecated_member_use
      desiredAccuracy: LocationAccuracy.high,
    );

    final newLocation = LatLng(position.latitude, position.longitude);
    currentLocation.value = newLocation;
    _setCurrentMarker(newLocation);

    await _moveCameraToPosition(newLocation, 16);
  }

  void onMapTapped(LatLng destinationPoint) {
    if (isTrackingLive.value) return;

    destination.value = destinationPoint;
    markers.removeWhere((marker) => marker.markerId.value == 'source');
    markers.removeWhere((marker) => marker.markerId.value == 'destination');

    final current = currentLocation.value;
    if (current != null) {
      _setSourceMarker(current);
    }

    markers.add(
      _buildMarker(
        'destination',
        'Destination',
        destinationPoint,
        destinationIcon,
      ),
    );

    polylines.clear();
    polylineCoordinates.clear();

    _getPolylinePoints();
  }

  Future<void> _getPolylinePoints() async {
    if (currentLocation.value == null || destination.value == null) return;

    _showInfo('Calculating optimal route...');

    final polylinePoints = PolylinePoints(apiKey: googleMapsApiKey);

    final result = await polylinePoints.getRouteBetweenCoordinates(
      // ignore: deprecated_member_use
      request: PolylineRequest(
        origin: PointLatLng(
          currentLocation.value!.latitude,
          currentLocation.value!.longitude,
        ),
        destination: PointLatLng(
          destination.value!.latitude,
          destination.value!.longitude,
        ),
        mode: TravelMode.walking,
      ),
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates.clear();
      for (final point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }

      final polylineId = PolylineId('poly$polylineIdCounter');
      polylineIdCounter++;

      polylines
        ..clear()
        ..add(
          Polyline(
            polylineId: polylineId,
            color: Colors.blue.shade800,
            width: 5,
            points: polylineCoordinates.toList(),
          ),
        );
      _showInfo('Route calculated. Ready for tracking.');
    } else {
      _showError(
        'Could not find a route. Check API key or if route is walkable.',
      );
    }
  }

  void toggleLiveTracking() {
    if (destination.value == null) {
      _showError('Please tap on the map to select a destination first.');
      return;
    }

    if (isTrackingLive.value) {
      _stopLiveTracking(showMessage: true);
      return;
    }

    isTrackingLive.value = true;

    _showInfo(
      'Live tracking started. Move your device to update your position.',
    );

    if (_hasSourceMarker) {
      markers.removeWhere((marker) => marker.markerId.value == 'current');
    }

    positionSubscription =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.bestForNavigation,
            distanceFilter: 5,
          ),
        ).listen(
          (Position position) {
            final newLocation = LatLng(position.latitude, position.longitude);
            currentLocation.value = newLocation;

            if (_hasSourceMarker) {
              _setSourceMarker(newLocation);
            } else {
              _setCurrentMarker(newLocation);
            }

            _moveCameraToPosition(newLocation, 18);
            _checkDestinationReached(newLocation);
          },
          onError: (e) {
            _showError('Error during location stream: ${e.toString()}');
            _stopLiveTracking(showMessage: false);
          },
        );
  }

  void _checkDestinationReached(LatLng current) {
    if (destination.value == null) return;

    final distance = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      destination.value!.latitude,
      destination.value!.longitude,
    );

    if (distance < destinationThresholdMeters) {
      _stopLiveTracking(showMessage: false);
      _showCongratulations();
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

  void setCustomMarkerIcon() {
    // ignore: deprecated_member_use
    BitmapDescriptor.fromAssetImage(
      ImageConfiguration.empty,
      'assets/icons/car.png',
    ).then((icon) {
      // ignore: unused_local_variable
      final customIcon = icon;
    });
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

  void _setSourceMarker(LatLng position) {
    markers.removeWhere((marker) => marker.markerId.value == 'source');
    markers.add(
      _buildMarker('source', 'Source', position, sourceIcon, zIndex: 2),
    );
  }

  bool get _hasSourceMarker =>
      markers.any((marker) => marker.markerId.value == 'source');

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

  void _showInfo(String message) {
    Get.showSnackbar(
      GetSnackBar(
        messageText: Text(message),
        backgroundColor: Colors.blueAccent,
        duration: const Duration(milliseconds: 1500),
      ),
    );
  }

  void _showCongratulations() {
    Get.showSnackbar(
      const GetSnackBar(
        messageText: Text('Destination Reached! Tracking stopped.'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 5),
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

  void _stopLiveTracking({required bool showMessage}) {
    positionSubscription?.cancel();
    isTrackingLive.value = false;
    if (showMessage) _showInfo('Live tracking stopped.');

    markers.removeWhere((marker) => marker.markerId.value == 'source');
    final latest = currentLocation.value;
    if (latest != null) {
      _setCurrentMarker(latest);
    }
  }
}
