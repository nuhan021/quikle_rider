import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

// Assuming your enhanced package imports these core classes
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// Import PolylineResult

class LiveTrackingGoogleMap extends StatefulWidget {
  const LiveTrackingGoogleMap({super.key});

  @override
  State<LiveTrackingGoogleMap> createState() => _LiveTrackingGoogleMapState();
}

class _LiveTrackingGoogleMapState extends State<LiveTrackingGoogleMap> {
  // 🔑 IMPORTANT: Replace with your actual Google Maps API Key
  static const String GOOGLE_MAPS_API_KEY =
      "AIzaSyD65cza7lynnmbhCN44gs7HupKMnuoU-bo";

  GoogleMapController? mapController;

  Position? _currentPosition;
  String _currentAddress = "";

  StreamSubscription<Position>? positionStream;
  LatLng? currentLatLng;

  // 👇 Initialize the enhanced PolylinePoints class with the API key
  late PolylinePoints polylinePoints;

  // New State Variables
  LatLng? destinationLatLng;
  String _destinationAddress = "";
  Map<PolylineId, Polyline> polylines = {};
  Set<Marker> markers = {};

  // Combined marker set getter (logic remains the same)
  Set<Marker> get mapMarkers => {
    ...markers,
    if (currentLatLng != null)
      Marker(
        markerId: const MarkerId("current"),
        position: currentLatLng!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: InfoWindow(title: "My Location", snippet: _currentAddress),
      ),
  };

  @override
  void initState() {
    super.initState();
    // 👇 Initialize PolylinePoints here, as the constructor now requires the apiKey
    polylinePoints = PolylinePoints.enhanced(GOOGLE_MAPS_API_KEY);
    _startLiveTracking();
  }

  @override
  void dispose() {
    positionStream?.cancel();
    super.dispose();
  }

  // ... (_startLiveTracking logic remains the same)

  Future<void> _startLiveTracking() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }
    }

    Position pos = await Geolocator.getCurrentPosition();
    _updateLocation(pos);

    positionStream =
        Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            distanceFilter: 5,
            accuracy: LocationAccuracy.high,
          ),
        ).listen((Position pos) {
          _updateLocation(pos);
        });
  }

  void _updateLocation(Position pos) {
    setState(() {
      _currentPosition = pos;
      currentLatLng = LatLng(pos.latitude, pos.longitude);
    });

    _getAddressFromLatLng(pos.latitude, pos.longitude, isDestination: false);

    // RE-CALCULATE ROUTE LIVE IF DESTINATION IS SET
    if (destinationLatLng != null) {
      _getPolyline(currentLatLng!, destinationLatLng!);
    }
  }

  // ... (_getAddressFromLatLng logic remains the same)
  Future<void> _getAddressFromLatLng(
    double lat,
    double lng, {
    required bool isDestination,
  }) async {
    try {
      List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
      if (placemarks.isNotEmpty) {
        Placemark place = placemarks.first;
        String address =
            "${place.street ?? ''}, ${place.locality ?? ''}, ${place.country ?? ''}";
        setState(() {
          if (isDestination) {
            _destinationAddress = address;
          } else {
            _currentAddress = address;
          }
        });
      }
    } catch (e) {
      print("Address error: $e");
    }
  }

  void _onMapTap(LatLng tappedPoint) {
    setState(() {
      destinationLatLng = tappedPoint;

      markers.removeWhere((m) => m.markerId.value == 'destination');
      markers.add(
        Marker(
          markerId: const MarkerId("destination"),
          position: destinationLatLng!,
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: "Destination",
            snippet: _destinationAddress,
          ),
        ),
      );
    });

    _getAddressFromLatLng(
      tappedPoint.latitude,
      tappedPoint.longitude,
      isDestination: true,
    );

    if (currentLatLng != null) {
      _getPolyline(currentLatLng!, destinationLatLng!);
    }
  }

  // =====================================================
  // DRAW POLYLINE ROUTE - UPDATED FOR ENHANCED API
  // =====================================================
  Future<void> _getPolyline(LatLng origin, LatLng destination) async {
    // 1. Create the RoutesApiRequest object
    RoutesApiRequest routesRequest = RoutesApiRequest(
      origin: PointLatLng(origin.latitude, origin.longitude),
      destination: PointLatLng(destination.latitude, destination.longitude),
      travelMode: TravelMode.driving,
      routingPreference:
          RoutingPreference.trafficAware, // Use enhanced features
    );

    PolylineResult polylineResult;

    // 2. Call the enhanced method getRouteBetweenCoordinatesV2()
    try {
      final routesResponse = await polylinePoints.getRouteBetweenCoordinatesV2(
        request: routesRequest,
      );

      // 3. Convert the Routes API Response (V2) to the Legacy PolylineResult
      polylineResult = polylinePoints.convertToLegacyResult(routesResponse);
    } catch (e) {
      // Fallback or error handling if V2 call fails
      print("Routes API V2 failed: $e. Clearing polyline.");
      setState(() {
        polylines.clear();
      });
      return;
    }

    if (polylineResult.status == 'OK' && polylineResult.points.isNotEmpty) {
      List<LatLng> polylineCoordinates = polylineResult.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();

      PolylineId id = const PolylineId("route");
      Polyline polyline = Polyline(
        polylineId: id,
        color: Colors.blueAccent,
        points: polylineCoordinates,
        width: 5,
        geodesic: true,
      );

      setState(() {
        polylines = {id: polyline};
      });
    } else {
      print("Error getting polyline points: ${polylineResult.errorMessage}");
      setState(() {
        polylines.clear();
      });
    }
  }

  // ... (rest of the Widget build method and helper functions remain the same)

  // =====================================================
  // UI + GOOGLE MAP WIDGET
  // =====================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Live Tracking & Enhanced Route"),
        backgroundColor: Colors.blueAccent,
      ),

      body: Stack(
        children: [
          // GOOGLE MAP
          currentLatLng == null
              ? const Center(child: CircularProgressIndicator())
              : GoogleMap(
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,

                  initialCameraPosition: CameraPosition(
                    target: currentLatLng!,
                    zoom: 16,
                  ),

                  onMapCreated: (controller) {
                    mapController = controller;
                  },

                  onTap: _onMapTap,

                  markers: mapMarkers,
                  polylines: Set<Polyline>.of(polylines.values),
                ),

          // TOP INFO CARD (Current Location & Destination)
          Positioned(
            top: 16,
            left: 16,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: const [
                  BoxShadow(color: Colors.black26, blurRadius: 8),
                ],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildLocationInfo(
                    "Your Current Location",
                    _currentPosition == null
                        ? "Getting location..."
                        : "Lat: ${_currentPosition!.latitude.toStringAsFixed(4)}, Lng: ${_currentPosition!.longitude.toStringAsFixed(4)}",
                    _currentAddress.isEmpty
                        ? "Getting address..."
                        : _currentAddress,
                    Colors.blueAccent,
                  ),

                  if (destinationLatLng != null) ...[
                    const Divider(height: 16),
                    _buildLocationInfo(
                      "Destination",
                      "Lat: ${destinationLatLng!.latitude.toStringAsFixed(4)}, Lng: ${destinationLatLng!.longitude.toStringAsFixed(4)}",
                      _destinationAddress.isEmpty
                          ? "Getting destination address..."
                          : _destinationAddress,
                      Colors.red,
                    ),
                  ],
                ],
              ),
            ),
          ),

          // RECENTER BUTTON
          Positioned(
            bottom: 30,
            right: 20,
            child: FloatingActionButton(
              heroTag: "recenter",
              backgroundColor: Colors.blueAccent,
              child: const Icon(Icons.my_location),
              onPressed: _recenterMap,
            ),
          ),

          // CLEAR DESTINATION BUTTON
          if (destinationLatLng != null)
            Positioned(
              bottom: 100,
              right: 20,
              child: FloatingActionButton(
                heroTag: "clearDestination",
                backgroundColor: Colors.red,
                child: const Icon(Icons.clear),
                onPressed: _clearDestination,
              ),
            ),
        ],
      ),
    );
  }

  // Helper Widget for Info Card
  Widget _buildLocationInfo(
    String title,
    String coords,
    String address,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(coords, style: const TextStyle(fontSize: 15)),
        Text(address, style: const TextStyle(fontSize: 14, color: Colors.grey)),
      ],
    );
  }

  // Helper function to recenter map
  void _recenterMap() {
    if (currentLatLng != null && mapController != null) {
      mapController!.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng!, 16),
      );
    }
  }

  // Helper function to clear destination
  void _clearDestination() {
    setState(() {
      destinationLatLng = null;
      _destinationAddress = "";
      polylines.clear();
      markers.removeWhere((m) => m.markerId.value == 'destination');
    });
  }
}
