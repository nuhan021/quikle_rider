// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quikle_rider/features/profile/presentation/controller/tracking_controller.dart';

class LiveMap extends StatefulWidget {
  const LiveMap({super.key});

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  late final TrackingController controller;

  @override
  void initState() {
    super.initState();
    controller = Get.put(TrackingController());
  }

  @override
  void dispose() {
    controller.cleanUp();
    Get.delete<TrackingController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isTrackingLive = controller.isTrackingLive.value;
      final currentLocation = controller.currentLocation.value;

      return Container(
        height: 400.h,
        color: Colors.white,
        child: currentLocation == null
            ? const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.blueAccent),
                    SizedBox(height: 16),
                    Text('Fetching initial location and permissions...'),
                  ],
                ),
              )
            : Stack(
                children: [
                  /// --- GOOGLE MAP ---
                  GoogleMap(
                    scrollGesturesEnabled: true,
                    zoomGesturesEnabled: true,
                    mapType: MapType.normal,
                    circles: {
                      Circle(
                        circleId: const CircleId('current-location'),
                        center: currentLocation,
                        radius: 6437, // ~4 miles in meters
                        fillColor: Colors.blue.withOpacity(0.1),
                        strokeColor: Colors.blue.withOpacity(0.5),
                        strokeWidth: 2,
                      ),
                    },

                    initialCameraPosition: CameraPosition(
                      target: currentLocation,
                      zoom: 14,
                    ),
                    onMapCreated: controller.onMapCreated,
                    onTap: controller.onMapTapped,
                    markers: Set<Marker>.from(controller.markers),
                    polylines: Set<Polyline>.from(controller.polylines),
                    zoomControlsEnabled: true,
                    myLocationEnabled: true,
                    myLocationButtonEnabled: true,
                    gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                  ),

                  /// --- TRACKING BUTTON ---
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: AbsorbPointer(
                      absorbing: false, // allow map gestures under empty area
                      child: ElevatedButton.icon(
                        onPressed: controller.toggleLiveTracking,
                        icon: Icon(
                          isTrackingLive
                              ? Icons.pause_circle_outline
                              : Icons.near_me,
                          size: 20,
                        ),
                        label: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            isTrackingLive
                                ? 'STOP LIVE TRACKING'
                                : 'START LIVE TRACKING',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: isTrackingLive
                              ? Colors.red.shade700
                              : Colors.blue.shade700,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 3,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      );
    });
  }
}
