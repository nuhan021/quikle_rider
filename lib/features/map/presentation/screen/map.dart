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
import 'package:quikle_rider/core/widgets/connection_lost.dart';
import 'package:quikle_rider/core/widgets/unverified/unverified.dart';
import 'package:quikle_rider/custom_tab_bar/notifications.dart';
import 'package:quikle_rider/features/all_orders/controllers/all_order_controller.dart';
import 'package:quikle_rider/features/all_orders/data/services/order_services.dart';
import 'package:quikle_rider/features/all_orders/models/rider_order_model.dart';
import 'package:quikle_rider/features/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:quikle_rider/features/home/controllers/homepage_controller.dart';
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
  late final AllOrdersController _allOrdersController;
  final OrderServices _orderServices = OrderServices();
  bool _isFetchingCurrentOrder = false;
  bool _hasTriggeredVerifiedLoad = false;
  bool _isUpdatingStatus = false;
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
    _allOrdersController = Get.isRegistered<AllOrdersController>()
        ? Get.find<AllOrdersController>()
        : Get.put(AllOrdersController());
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

  void _setFetchingCurrentOrder(bool value) {
    if (_isFetchingCurrentOrder == value) return;
    if (!mounted) {
      _isFetchingCurrentOrder = value;
      return;
    }
    setState(() {
      _isFetchingCurrentOrder = value;
    });
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

    _setFetchingCurrentOrder(true);
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

      if (response.isSuccess) {
        mapController.clearCurrentDelivery();
      }
      debugPrint('MapScreen: no current orders available or failed response.');
    } catch (error) {
      debugPrint('MapScreen: failed to load current order - $error');
    } finally {
      _setFetchingCurrentOrder(false);
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
                body: delivery == null
                    ? (_isFetchingCurrentOrder
                        ? const Center(child: MapShimmer())
                        : _buildNoActiveOrderView(controller))
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

  Widget _buildNoActiveOrderView(MapController controller) {
    final locationError = controller.locationError.value?.trim() ?? '';
    final address = controller.currentAddress.value.trim();
    final position = controller.currentPosition.value;
    final fallbackText = position != null
        ? '${position.latitude.toStringAsFixed(5)}, ${position.longitude.toStringAsFixed(5)}'
        : 'Location unavailable';
    final locationLabel = address.isNotEmpty
        ? address
        : (locationError.isNotEmpty ? locationError : fallbackText);

    return SingleChildScrollView(
      child: Column(
        children: [
          _buildMapArea(controller),
          Container(
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
                Text(
                  'No Active order found',
                  style: headingStyle2(color: Colors.black87),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Current location',
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey[600],
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  locationLabel,
                  style: getTextStyle(
                    fontSize: 13,
                    color: Colors.grey[700],
                  ),
                ),
              ],
            ),
          ),
        ],
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
          _buildHeader(delivery),
          SizedBox(height: 10.h),
          _buildOrderMeta(delivery),
          SizedBox(height: 8.h),
          _buildOrderAttributes(delivery),
          SizedBox(height: 16.h),
          _buildPickupInfo(controller, delivery),
          SizedBox(height: 15.h),
          _buildCustomerInfo(delivery, controller),
          SizedBox(height: 20.h),
          _buildItemsSection(delivery),
          SizedBox(height: 20.h),
          _buildActionButtons(delivery),
        ],
      ),
    );
  }

  Widget _buildHeader(DeliveryModel delivery) {
    final totalLabel = _formatCurrency(delivery.totalAmount, delivery.currency);
    final estimatedLabel = _formatEstimatedTimeLabel(delivery.estimatedTime);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                'Order Details',
                style: headingStyle2(color: Colors.black87),
              ),
            ),
            if (estimatedLabel.isNotEmpty)
              Text(
                estimatedLabel,
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey[700],
                ),
              ),
          ],
        ),
        SizedBox(height: 6.h),
        Text(
          totalLabel,
          style: getTextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }

  Widget _buildOrderMeta(DeliveryModel delivery) {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Order ID: ${delivery.orderId.isNotEmpty ? delivery.orderId : '--'}',
            style: getTextStyle(fontSize: 13, color: Colors.grey[700]),
          ),
        ),
      ],
    );
  }

  Widget _buildOrderAttributes(DeliveryModel delivery) {
    final rows = <String>[];
    final status = delivery.status?.trim() ?? '';
    if (status.isNotEmpty) {
      rows.add('Status: $status');
    }
    final deliveryType = delivery.deliveryType?.trim() ?? '';
    if (deliveryType.isNotEmpty) {
      rows.add('Type: $deliveryType');
    }
    final parentId = delivery.parentOrderId?.trim() ?? '';
    if (parentId.isNotEmpty) {
      rows.add('Parent ID: $parentId');
    }
    if (delivery.baseRate != null) {
      rows.add(
        'Base rate: ${_formatCurrency(delivery.baseRate, delivery.currency)}',
      );
    }
    if (delivery.pickupDistanceKm != null) {
      rows.add(
        'Pickup distance: ${delivery.pickupDistanceKm!.toStringAsFixed(1)} km',
      );
    }

    if (rows.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final row in rows)
          Padding(
            padding: EdgeInsets.only(bottom: 4.h),
            child: Text(
              row,
              style: getTextStyle(fontSize: 12, color: Colors.grey[700]),
            ),
          ),
      ],
    );
  }

  Widget _buildPickupInfo(MapController controller, DeliveryModel delivery) {
    final pickupAddress = controller.vendorPickupAddress.value.trim();
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Pickup', style: headingStyle2(color: Colors.black87)),
          SizedBox(height: 8.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.store, color: Colors.grey[700], size: 18.sp),
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
                      style: getTextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCustomerInfo(DeliveryModel delivery, MapController controller) {
    final address = delivery.customerAddress.trim();
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22.r,
            backgroundImage: AssetImage(delivery.customerAvatar),
            backgroundColor: Colors.grey[300],
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  delivery.customerName,
                  style: getTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                if (delivery.customerPhone.trim().isNotEmpty)
                  Text(
                    delivery.customerPhone,
                    style: getTextStyle(fontSize: 13, color: Colors.grey[600]),
                  ),
                Text(
                  address.isNotEmpty ? address : 'Delivery address unavailable',
                  style: getTextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: GestureDetector(
                  onTap: controller.messageCustomer,
                  child: Image.asset(
                    'assets/images/message.png',
                    width: 18.sp,
                    height: 18.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: GestureDetector(
                  onTap: controller.callCustomer,
                  child: Image.asset(
                    'assets/images/call.png',
                    width: 18.sp,
                    height: 18.sp,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildItemsSection(DeliveryModel delivery) {
    final items = delivery.items;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Items to Deliver', style: headingStyle2(color: Colors.black87)),
        SizedBox(height: 10.h),
        Container(
          padding: EdgeInsets.all(15.w),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Column(
            children: items.isNotEmpty
                ? [
                    for (var i = 0; i < items.length; i++)
                      _buildDeliveryItem(
                        items[i],
                        isLast: i == items.length - 1,
                      ),
                  ]
                : [
                    Text(
                      'No items available for this order.',
                      style: getTextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
          ),
        ),
      ],
    );
  }

  Widget _buildDeliveryItem(DeliveryItem item, {required bool isLast}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '•',
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.grey[700],
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${item.quantity} x ${item.name}',
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                if (item.description.isNotEmpty)
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

  String _formatCurrency(double? amount, String currency) {
    if (amount == null) {
      return '$currency--';
    }
    return '$currency${amount.toStringAsFixed(2)}';
  }

  String _formatEstimatedTimeLabel(String raw) {
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      return 'ETA pending';
    }
    final formatted = _formatEstimatedTime(trimmed);
    return formatted.isNotEmpty ? formatted : trimmed;
  }

  String _formatEstimatedTime(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) {
      return raw;
    }
    final local = parsed.toLocal();
    final months = const [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    final hour = local.hour % 12 == 0 ? 12 : local.hour % 12;
    final minute = local.minute.toString().padLeft(2, '0');
    final meridiem = local.hour >= 12 ? 'PM' : 'AM';
    return '${months[local.month - 1]} ${local.day}, ${local.year} • '
        '$hour:$minute $meridiem';
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

  Future<void> _handleMarkOnWay(DeliveryModel delivery) async {
    if (_isUpdatingStatus) return;
    final orderId = delivery.orderId.trim();
    if (orderId.isEmpty) {
      _showStatusMessage('Missing order ID for status update.');
      return;
    }

    setState(() {
      _isUpdatingStatus = true;
    });

    final response = await _allOrdersController.markOrderOnWay(
      orderId: orderId,
    );

    if (!mounted) return;

    if (response.isSuccess) {
      mapController.currentDelivery.value = delivery.copyWith(
        status: 'ON_THE_WAY',
      );
      _showStatusMessage('Order marked as on the way.');
    } else {
      _showStatusMessage(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to update order status.',
      );
    }

    if (mounted) {
      setState(() {
        _isUpdatingStatus = false;
      });
    }
  }

  Future<void> _handleMarkDelivered(DeliveryModel delivery) async {
    if (_isUpdatingStatus) return;
    final orderId = delivery.orderId.trim();
    if (orderId.isEmpty) {
      _showStatusMessage('Missing order ID for status update.');
      return;
    }

    setState(() {
      _isUpdatingStatus = true;
    });

    final response = await _allOrdersController.markOrderDelivered(
      orderId: orderId,
    );

    if (!mounted) return;

    if (response.isSuccess) {
      mapController.currentDelivery.value = delivery.copyWith(
        status: 'DELIVERED',
      );
      _showStatusMessage('Order marked as delivered.');
    } else {
      _showStatusMessage(
        response.errorMessage.isNotEmpty
            ? response.errorMessage
            : 'Unable to update order status.',
      );
    }

    if (mounted) {
      setState(() {
        _isUpdatingStatus = false;
      });
    }
  }

  void _showStatusMessage(String message) {
    Get.snackbar(
      '',
      message,
      titleText: const SizedBox.shrink(),
      messageText: Text(
        message,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: Colors.white,
          fontFamily: 'Manrope',
          height: 1.50,
        ),
      ),
      backgroundColor: const Color(0xFF222222),
      colorText: Colors.white,
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  String _normalizeStatus(String? status) {
    return status?.trim().toLowerCase() ?? '';
  }

  bool _isOnTheWayStatus(String status) {
    return status == 'on_the_way' ||
        status == 'on the way' ||
        status == 'on-way' ||
        status == 'on_way' ||
        status == 'ontheway';
  }

  bool _isDeliveredStatus(String status) {
    return status == 'delivered' || status == 'completed';
  }

  Widget _buildActionButtons(DeliveryModel delivery) {
    final status = _normalizeStatus(delivery.status);
    final isShipped = status == 'shipped';
    final isOnWay = _isOnTheWayStatus(status);
    final isDelivered = _isDeliveredStatus(status);
    String actionLabel;
    VoidCallback? actionHandler;
    Color actionColor = Colors.black87;

    if (_isUpdatingStatus) {
      actionLabel = 'Updating...';
      actionHandler = null;
      actionColor = Colors.black54;
    } else if (isShipped) {
      actionLabel = 'On the way';
      actionHandler = () => _handleMarkOnWay(delivery);
    } else if (isOnWay) {
      actionLabel = 'Mark as Delivered';
      actionHandler = () => _handleMarkDelivered(delivery);
    } else if (isDelivered) {
      actionLabel = 'Delivered';
      actionHandler = null;
      actionColor = Colors.grey;
    } else {
      actionLabel = 'Awaiting Status';
      actionHandler = null;
      actionColor = Colors.grey;
    }

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed:(){},
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
            onPressed: actionHandler,
            style: ElevatedButton.styleFrom(
              backgroundColor: actionColor,
              padding: EdgeInsets.symmetric(vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              elevation: 0,
              side: BorderSide.none,
              overlayColor: Colors.transparent,
            ),
            child: Text(
              actionLabel,
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
