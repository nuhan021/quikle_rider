// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/features/map/presentation/controller/map_controller.dart';
import 'package:quikle_rider/features/map/presentation/model/delivery_model.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MapController(),
      child: Consumer<MapController>(
        builder: (context, controller, child) {
          return WillPopScope(
            onWillPop: () async {
              Get.back(); // Handle device back button
              return false; // Prevent default pop
            },
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: UnifiedProfileAppBar(
                  showActionButton: true,
                  title: "Map",
                  action: "Notification",
                  onActionPressed: () {},
                ),
                body: controller.currentDelivery == null
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildMapArea(controller),
                            _buildDeliveryInfo(context, controller),
                          ],
                        ),
                      ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMapArea(MapController controller) {
    final target = controller.currentPosition ?? controller.fallbackLocation;
    final zoom = controller.currentPosition != null ? 15.5 : 14.0;

    return Container(
      height: 320.h,
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: target,
              zoom: zoom,
            ),
            myLocationEnabled: controller.hasUserLocation,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
            onMapCreated: controller.attachMapController,
          ),
          Positioned(
            bottom: 16.h,
            right: 16.w,
            child: FloatingActionButton.small(
              heroTag: 'current-location-button',
              backgroundColor: Colors.white,
              foregroundColor: Colors.black87,
              onPressed: controller.isFetchingLocation
                  ? null
                  : () {
                      controller.requestCurrentLocation();
                    },
              child: controller.isFetchingLocation
                  ? SizedBox(
                      width: 18.w,
                      height: 18.w,
                      child: const CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.my_location),
            ),
          ),
          if (controller.locationError != null)
            Positioned(
              top: 16.h,
              left: 16.w,
              right: 16.w,
              child: _buildLocationBanner(controller),
            ),
        ],
      ),
    );
  }

  Widget _buildLocationBanner(MapController controller) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(Icons.location_off, color: Colors.red[400], size: 20.sp),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              controller.locationError!,
              style: getTextStyle(fontSize: 13, color: Colors.black87),
            ),
          ),
          TextButton(
            onPressed: controller.isFetchingLocation
                ? null
                : () {
                    controller.requestCurrentLocation();
                  },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(BuildContext context, MapController controller) {
    final delivery = controller.currentDelivery!;
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(delivery),
          SizedBox(height: 15.h),
          _buildCustomerInfo(delivery, controller),
          SizedBox(height: 15.h),
          _buildDeliveryAddress(delivery),
          SizedBox(height: 20.h),
          _buildItemsSection(delivery),
          SizedBox(height: 20.h),
          _buildActionButtons(context, controller),
        ],
      ),
    );
  }

  Widget _buildHeader(DeliveryModel delivery) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text('Delivery Address', style: headingStyle2(color: Colors.black87)),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Text(
            delivery.estimatedTime,
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCustomerInfo(DeliveryModel delivery, MapController controller) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25.r,
          backgroundImage: AssetImage(delivery.customerAvatar),
          backgroundColor: Colors.grey[300],
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                delivery.customerName,
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                delivery.customerAddress,
                style: getTextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: GestureDetector(
                onTap: controller.messageCustomer,
                child: Image.asset(
                  'assets/images/message.png',
                  width: 20.sp,
                  height: 20.sp,
                ),
              ),
            ),
            SizedBox(width: 10.w),
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: GestureDetector(
                onTap: controller.callCustomer,
                child: Image.asset(
                  'assets/images/call.png',
                  width: 20.sp,
                  height: 20.sp,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDeliveryAddress(DeliveryModel delivery) {
    return Row(
      children: [
        Icon(Icons.location_on, color: Colors.grey[600], size: 16.sp),
        SizedBox(width: 5.w),
        Expanded(
          child: Text(
            delivery.deliveryAddress,
            style: getTextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(DeliveryModel delivery) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Items to Deliver', style: headingStyle2(color: Colors.black87)),
        SizedBox(height: 10.h),
        Text(
          delivery.restaurantName,
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: Colors.grey[700],
          ),
        ),
        SizedBox(height: 15.h),
        Container(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            children: delivery.items
                .map((item) => _buildDeliveryItem(delivery, item))
                .toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryItem(DeliveryModel delivery, DeliveryItem item) {
    return Padding(
      padding: EdgeInsets.only(bottom: delivery.items.last == item ? 0 : 10.h),
      child: Row(
        children: [
          Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8.r),
              image: DecorationImage(
                image: AssetImage(item.image),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.name} X ${item.quantity}',
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  item.description,
                  style: getTextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, MapController controller) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: controller.callCustomer,
            icon: Image.asset(
              'assets/images/call.png',
              color: Colors.black87,
              width: 20.sp,
              height: 20.sp,
            ),
            label: Text(
              'Call Customer',
              style: buttonTextStyle(
                color: Colors.black87,
                fontWeight: FontWeight.w600,
              ),
            ),
            style: OutlinedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              side: BorderSide(color: Colors.grey[300]!),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
        SizedBox(width: 15.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              try {
                Get.toNamed('/parcelDone'); // Navigate to ParcelDone
              } catch (e) {
                Get.snackbar(
                  'Error',
                  'Failed to navigate to ParcelDone: $e',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.red,
                  colorText: Colors.white,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black87,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
              side: BorderSide.none,
              overlayColor: Colors.transparent,
            ),
            child: Text(
              'Mark as Delivered',
              style: buttonTextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
