// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/services/storage_service.dart';
import 'package:quikle_rider/core/widgets/connection_lost.dart';
import 'package:quikle_rider/core/widgets/unverified/unverified.dart';
import 'package:quikle_rider/custom_tab_bar/notifications.dart';
import 'package:quikle_rider/features/all_orders/data/services/order_services.dart';
import 'package:quikle_rider/features/all_orders/models/rider_order_model.dart';
import 'package:quikle_rider/features/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:quikle_rider/features/home/controllers/homepage_controller.dart';
import 'package:quikle_rider/features/map/presentation/controller/map_controller.dart';
import 'package:quikle_rider/features/map/presentation/model/delivery_model.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:quikle_rider/features/profile/presentation/screen/live_tracking.dart';

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
  Worker? _navIndexWorker;
  BottomNavbarController? _bottomNavController;
  HomepageController homepageController = Get.find<HomepageController>();

  @override
  void initState() {
    super.initState();
    mapController = Get.isRegistered<MapController>()
        ? Get.find<MapController>()
        : Get.put(MapController());
    profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    _bottomNavController = Get.isRegistered<BottomNavbarController>()
        ? Get.find<BottomNavbarController>()
        : null;
    if (_bottomNavController != null) {
      _navIndexWorker = ever<int>(
        _bottomNavController!.selectedIndex,
        _handleNavIndexChange,
      );
      _handleNavIndexChange(_bottomNavController!.selectedIndex.value);
    } else if (profileController.isVerifiedApproved) {
      _triggerVerifiedLoad();
    }
    _verificationWorker = ever<String?>(profileController.isVerified, (_) {
      if (profileController.isVerifiedApproved &&
          _shouldTriggerVerifiedLoad &&
          !_hasTriggeredVerifiedLoad) {
        _triggerVerifiedLoad();
      }
    });
  }

  @override
  void dispose() {
    mapController.detachMapController();
    _verificationWorker?.dispose();
    _navIndexWorker?.dispose();
    super.dispose();
  }

  bool get _isMapTabActive =>
      _bottomNavController?.selectedIndex.value == 2;

  bool get _shouldTriggerVerifiedLoad =>
      _bottomNavController == null || _isMapTabActive;

  void _handleNavIndexChange(int index) {
    if (index == 2 && profileController.isVerifiedApproved) {
      final args = Get.arguments;
      if (args is RiderOrder) {
        return;
      }
      mapController.clearCurrentDelivery();
      _triggerVerifiedLoad();
    } else if (index != 2) {
      _hasTriggeredVerifiedLoad = false;
    }
  }

  void _triggerVerifiedLoad() {
    final args = Get.arguments;
    if (args is RiderOrder) {
      return;
    }
    _hasTriggeredVerifiedLoad = true;
    debugPrint('MapScreen: opening, requesting current location...');
    mapController.requestCurrentLocation();
    _loadCurrentOrder();
  }

  Future<void> _loadCurrentOrder() async {
    if (_isFetchingCurrentOrder) return;
    if (!profileController.isVerifiedApproved) {
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
      final response = await _orderServices.fetchActiveOrders(
        accessToken: accessToken,
      );

      if (response.isSuccess) {
        final data = response.responseData;
        if (data is List) {
          Map<String, dynamic>? firstOrder;
          for (final entry in data) {
            if (entry is Map<String, dynamic>) {
              firstOrder = entry;
              break;
            }
          }
          if (firstOrder != null) {
            final delivery = _deliveryFromActiveOrder(firstOrder);
            mapController.applyDeliverySnapshot(
              delivery,
              orderId: delivery.orderId,
            );
            return;
          }
        } else if (data is Map<String, dynamic>) {
          final orders = data['orders'];
          if (orders is List) {
            Map<String, dynamic>? firstOrder;
            for (final entry in orders) {
              if (entry is Map<String, dynamic>) {
                firstOrder = entry;
                break;
              }
            }
            if (firstOrder != null) {
              final delivery = _deliveryFromActiveOrder(firstOrder);
              mapController.applyDeliverySnapshot(
                delivery,
                orderId: delivery.orderId,
              );
              return;
            }
          }
        }
      }

      debugPrint('MapScreen: no current orders available or failed response.');
    } catch (error) {
      debugPrint('MapScreen: failed to load current order - $error');
    } finally {
      _isFetchingCurrentOrder = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isVerified = profileController.isVerifiedApproved;
      if (homepageController.hasConnection.value == false) {
        return ConnectionLost();
      }
      if (!isVerified) {
        return SafeArea(
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: UnifiedProfileAppBar(
              isback: false,
              showActionButton: true,
              title: "Map",
              action: "Notification",
              onActionPressed: () {
                Get.to(NotificationsPage());
              },
            ),

            body: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: EdgeInsets.all(16.h),
                  child: UnverifiedBanner(),
                ),
              ],
            ),
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
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildTrackingMap(controller),
                      if (delivery != null)
                        _buildActiveOrderSummary(delivery)
                      else
                        _buildNoActiveOrders(controller),
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

  Widget _buildTrackingMap(MapController controller) {
    final vendor = controller.vendorPosition.value;
    final customer = controller.customerPosition.value;
    final key = ValueKey(
      '${vendor?.latitude ?? ''},${vendor?.longitude ?? ''}|'
      '${customer?.latitude ?? ''},${customer?.longitude ?? ''}',
    );

    return LiveMap(
      key: key,
      vendorLocation: vendor,
      customerLocation: customer,
    );
  }

  Widget _buildNoActiveOrders(MapController controller) {
    final address = controller.currentAddress.value.trim();
    final hasLocation = controller.hasUserLocation;
    final locationMessage = controller.locationError.value?.trim() ?? '';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'No active orders found',
            style: headingStyle2(color: Colors.black87),
          ),
          SizedBox(height: 10.h),
          Text(
            locationMessage.isNotEmpty
                ? locationMessage
                : (hasLocation
                    ? (address.isNotEmpty
                        ? 'Showing your current location:\n$address'
                        : 'Showing your current location.')
                    : 'Fetching your current location...'),
            style: getTextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }

  Widget _buildActiveOrderSummary(DeliveryModel delivery) {
    final totalLabel = _formatCurrency(delivery.totalAmount, delivery.currency);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Active Order', style: headingStyle2(color: Colors.black87)),
          SizedBox(height: 6.h),
          Text(
            totalLabel.isNotEmpty ? totalLabel : '--',
            style: getTextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Order ID: ${delivery.orderId.isNotEmpty ? delivery.orderId : '--'}',
            style: getTextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
          if ((delivery.status ?? '').trim().isNotEmpty)
            Text(
              'Status: ${delivery.status}',
              style: getTextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          if (delivery.restaurantName.trim().isNotEmpty)
            Text(
              'Vendor: ${delivery.restaurantName}',
              style: getTextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          if (delivery.customerName.trim().isNotEmpty)
            Text(
              'Customer: ${delivery.customerName}',
              style: getTextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
        ],
      ),
    );
  }

  String _formatCurrency(double? amount, String currency) {
    if (amount == null) {
      return '$currency--';
    }
    return '$currency${amount.toStringAsFixed(2)}';
  }

  DeliveryModel _deliveryFromActiveOrder(Map<String, dynamic> order) {
    final orderId = order['order_id']?.toString() ?? '';
    final customerName = order['customer_name']?.toString().trim() ?? '';
    final customerPhone = order['customer_phone']?.toString().trim() ?? '';
    final totalAmount = _parseDouble(order['total']);
    final baseRate = _parseDouble(order['base_rate']);
    final pickupDistance = _parseDouble(order['pickup_distance_km']);
    final items = <DeliveryItem>[];
    final rawItems = order['items'];
    if (rawItems is List) {
      for (final item in rawItems.whereType<Map<String, dynamic>>()) {
        final title = item['title']?.toString().trim();
        final quantity = _parseInt(item['quantity']) ?? 1;
        final price = item['price']?.toString();
        items.add(
          DeliveryItem(
            name: title?.isNotEmpty == true ? title! : 'Item',
            description: price != null && price.isNotEmpty ? '₹$price' : '',
            image: 'assets/images/foodimage.png',
            quantity: quantity,
          ),
        );
      }
    }

    return DeliveryModel(
      orderId: orderId,
      parentOrderId: order['parent_order_id']?.toString(),
      status: order['status']?.toString(),
      deliveryType: order['delivery_type']?.toString(),
      baseRate: baseRate,
      pickupDistanceKm: pickupDistance,
      customerName: customerName.isNotEmpty ? customerName : 'Customer',
      customerPhone: customerPhone,
      customerAddress: '',
      deliveryAddress: '',
      estimatedTime: '',
      restaurantName: 'Vendor',
      customerAvatar: 'assets/images/avatar.png',
      items: items,
      totalAmount: totalAmount,
      currency: '₹',
    );
  }

  double? _parseDouble(Object? value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString());
  }

  int? _parseInt(Object? value) {
    if (value == null) return null;
    if (value is int) return value;
    return int.tryParse(value.toString());
  }
}
