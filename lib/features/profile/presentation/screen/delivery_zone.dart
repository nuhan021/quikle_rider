// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import 'package:quikle_rider/core/utils/constants/enums.dart';
import 'package:quikle_rider/features/map/presentation/controller/map_controller.dart';

class DeliveryZonePage extends StatelessWidget {
  DeliveryZonePage({super.key});

  final MapController mapController = Get.isRegistered<MapController>()
      ? Get.find<MapController>()
      : Get.put(MapController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: UnifiedProfileAppBar(
        showActionButton: true,
        title: "Delivery Zone",
        onActionPressed: () {},
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Obx(() {
            final target =
                mapController.currentPosition.value ??
                mapController.fallbackLocation;
            final zoom = mapController.currentPosition.value != null
                ? 15.5
                : 14.0;
            final isLoading = mapController.isFetchingLocation.value;
            final address = mapController.currentAddress.value.isNotEmpty
                ? mapController.currentAddress.value
                : 'Fetching location...';

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                GestureDetector(
                  onTap: isLoading
                      ? null
                      : () => mapController.requestCurrentLocation(),
                  child: Row(
                    children: [
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Delivery Location',
                              style: getTextStyle(
                                font: CustomFonts.inter,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Image(
                                  height: 24.h,
                                  image: const AssetImage(
                                    "assets/icons/location.png",
                                  ),
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    address,
                                    style: getTextStyle(
                                      font: CustomFonts.inter,
                                      fontSize: 14,
                                      fontWeight: FontWeight.w400,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  AppColors.beakYellow,
                                ),

                                color: Colors.grey,
                              ),
                            )
                          : Icon(
                              Icons.keyboard_arrow_down,
                              color: Colors.grey[600],
                            ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Container(
                  height: 200,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.grey[200],
                  ),
                  child: GoogleMap(
                    circles: {
                      Circle(
                        circleId: const CircleId('current-location'),
                        center: target,
                        radius: 6437, // ~4 miles in meters
                        fillColor: Colors.blue.withValues(alpha: 0.1),
                        strokeColor: Colors.blue.withValues(alpha: 0.5),
                        strokeWidth: 2,
                      ),
                    },
                    markers: {
                      Marker(
                        markerId: const MarkerId('current-location'),
                        position: target,
                      ),
                    },
                    initialCameraPosition: CameraPosition(
                      target: target,
                      zoom: zoom,
                    ),
                    myLocationEnabled: mapController.hasUserLocation,
                    myLocationButtonEnabled: true,
                    zoomControlsEnabled: false,
                    onMapCreated: mapController.attachMapController,
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}
