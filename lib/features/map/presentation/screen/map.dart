// ignore_for_file: deprecated_member_use

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/features/all_orders/data/services/order_services.dart';
import 'package:quikle_rider/features/all_orders/models/rider_order_model.dart';
import 'package:quikle_rider/features/map/presentation/controller/map_controller.dart';
import 'package:quikle_rider/features/map/presentation/model/delivery_model.dart';
import 'package:quikle_rider/features/map/presentation/widgets/map_shimmer.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late final MapController mapController;
  late final ProfileController profileController;
  final OrderServices _orderServices = OrderServices();
  bool _isFetchingCurrentOrder = false;
  bool _hasTriggeredVerifiedLoad = false;
  Worker? _verificationWorker;

  @override
  void initState() {
    super.initState();
    mapController = Get.isRegistered<MapController>()
        ? Get.find<MapController>()
        : Get.put(MapController());
    profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    if (profileController.isVerified.value == true) {
      _triggerVerifiedLoad();
    } else {
      _verificationWorker =
          ever<bool?>(profileController.isVerified, (value) {
        if (value == true && !_hasTriggeredVerifiedLoad) {
          _triggerVerifiedLoad();
        }
      });
    }
  }

  @override
  void dispose() {
    mapController.detachMapController();
    _verificationWorker?.dispose();
    super.dispose();
  }

  void _triggerVerifiedLoad() {
    _hasTriggeredVerifiedLoad = true;
    debugPrint('MapScreen: opening, requesting current location...');
    mapController.requestCurrentLocation();
    _loadCurrentOrder();
  }

  Future<void> _loadCurrentOrder() async {
    if (_isFetchingCurrentOrder) return;
    if (profileController.isVerified.value != true) {
      return;
    }
    final args = Get.arguments;
    if (args is RiderOrder) {
      return;
    }

    final accessToken = StorageService.accessToken;
    if (accessToken == null || accessToken.isEmpty) {
      debugPrint('MapScreen: missing access token for current orders.');
      return;
    }

    _isFetchingCurrentOrder = true;
    try {
      final response = await _orderServices.fetchcurrent_order(
        accessToken: accessToken,
      );

      if (response.isSuccess && response.responseData is List) {
        final list = response.responseData as List;
        final parsedOrders = list
            .whereType<Map<String, dynamic>>()
            .map(RiderOrder.fromJson)
            .toList(growable: false);
        if (parsedOrders.isNotEmpty) {
          mapController.applyOrderIfNeeded(parsedOrders.first);
          return;
        }
      }

      debugPrint(
        'MapScreen: no current orders available or failed response.',
      );
    } catch (error) {
      debugPrint('MapScreen: failed to load current order - $error');
    } finally {
      _isFetchingCurrentOrder = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isVerified = profileController.isVerified.value == true;
      if (!isVerified) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: UnifiedProfileAppBar(
              isback: false,
              showActionButton: true,
              title: "Map",
              action: "Notification",
              onActionPressed: () {},
            ),
            body: const Center(child: Text('Your profile not verified')),
          ),
        );
      }

      final args = Get.arguments;
      if (args is RiderOrder) {
        mapController.applyOrderIfNeeded(args);
      }

      return GetX<MapController>(
        init: mapController,
        builder: (controller) {
          final delivery = controller.currentDelivery.value;
          return WillPopScope(
            onWillPop: () async {
              Get.back(); // Handle device back button
              return false; // Prevent default pop
            },
            child: SafeArea(
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: UnifiedProfileAppBar(
                  isback: false,
                  showActionButton: true,
                  title: "Map",
                  action: "Notification",
                  onActionPressed: () {},
                ),
                body: delivery == null
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            _buildMapArea(controller),
                            _buildDeliveryInfo(context, controller, delivery),
                          ],
                        ),
                      ),
              ),
            ),
          );
        },
      );
    });
  }

  Widget _buildMapArea(MapController controller) {
    final showLoading =
        controller.isFetchingLocation.value || !controller.hasUserLocation;

    if (showLoading) {
      return SizedBox(height: 400.h, child: const MapShimmer());
    }

    final current = controller.currentPosition.value!;

    return SizedBox(
      height: 400.h,
      child: GoogleMap(
        mapType: MapType.normal,
        initialCameraPosition: CameraPosition(target: current, zoom: 15),
        onMapCreated: controller.attachMapController,
        markers: controller.mapMarkers,
        polylines: controller.activePolylines,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        zoomControlsEnabled: true,
        gestureRecognizers: <Factory<OneSequenceGestureRecognizer>>{
          Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
        },
      ),
    );
  }

  Widget _buildDeliveryInfo(
    BuildContext context,
    MapController controller,
    DeliveryModel delivery,
  ) {
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
          _buildPickupInfo(controller, delivery),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text('Order Details', style: headingStyle2(color: Colors.black87)),
        Container(
          padding: EdgeInsets.symmetric(vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Text(
            maxLines: 2,
            delivery.estimatedTime,
            style: TextStyle(
              
              overflow: TextOverflow.ellipsis,

              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPickupInfo(MapController controller, DeliveryModel delivery) {
    final pickupAddress = controller.vendorPickupAddress.value.trim();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pickup', style: headingStyle2(color: Colors.black87)),
        SizedBox(height: 8.h),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.store, color: Colors.grey[600], size: 16.sp),
            SizedBox(width: 8.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    delivery.restaurantName,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.grey[800],
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    pickupAddress.isNotEmpty
                        ? pickupAddress
                        : 'Pickup location not available',
                    style: getTextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ],
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
