// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quikle_rider/features/map/presentation/widgets/map_shimmer.dart';
import 'package:quikle_rider/features/map/presentation/controller/tracking_controller.dart';

// 4 km radius circle around current location.
const double _currentCircleRadiusMeters = 4000;

class LiveMap extends StatefulWidget {
  const LiveMap({
    super.key,
    this.vendorLocation,
    this.customerLocation,
  });

  final LatLng? vendorLocation;
  final LatLng? customerLocation;

  @override
  State<LiveMap> createState() => _LiveMapState();
}

class _LiveMapState extends State<LiveMap> {
  late final TrackingController controller;
  late final bool _ownsController;

  @override
  void initState() {
    super.initState();
    if (Get.isRegistered<TrackingController>()) {
      controller = Get.find<TrackingController>();
      _ownsController = false;
    } else {
      controller = Get.put(TrackingController());
      _ownsController = true;
    }
    controller.ensureInitialized();
    controller.updatePartnerAndCustomer(
      vendor: widget.vendorLocation,
      customer: widget.customerLocation,
    );
  }

  @override
  void dispose() {
    if (_ownsController) {
      controller.cleanUp();
      Get.delete<TrackingController>();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      // final isTrackingLive = controller.isTrackingLive.value;
      final currentLocation = controller.currentLocation.value;

      return Container(
        height: 400.h,
        color: Colors.white,
        child: currentLocation == null
            ? MapShimmer()
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
                        radius: _currentCircleRadiusMeters,
                        fillColor: Colors.blue.withValues(alpha: 0.1),
                        strokeColor: Colors.blue.withValues(alpha: 0.5),
                        strokeWidth: 2,
                      ),
                    },
                    initialCameraPosition: CameraPosition(
                      target: currentLocation,
                      zoom: 14,
                    ),
                    onMapCreated: controller.onMapCreated,
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
                  // Positioned(
                  //   bottom: 16,
                  //   right: 60,
                  //   child: ElevatedButton.icon(
                  //     onPressed: isTrackingLive
                  //         ? controller.stopLiveTracking
                  //         : controller.startLiveTracking,
                  //     icon: Icon(
                  //       isTrackingLive
                  //           ? Icons.pause_circle_outline
                  //           : Icons.play_arrow,
                  //       size: 18,
                  //     ),
                  //     label: Text(
                  //       isTrackingLive ? 'Stop Live' : 'Start Live',
                  //       style: const TextStyle(fontSize: 14),
                  //     ),
                  //     style: ElevatedButton.styleFrom(
                  //       backgroundColor:
                  //           isTrackingLive ? Colors.red.shade700 : Colors.blue.shade700,
                  //       foregroundColor: Colors.white,
                  //       padding:
                  //           const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  //       shape: RoundedRectangleBorder(
                  //         borderRadius: BorderRadius.circular(12),
                  //       ),
                  //       elevation: 3,
                  //     ),
                  //   ),
                  // ),
                ],
              ),
      );
    });
  }
}
