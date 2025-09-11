import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:quikle_rider/custom_tab_bar/custom_tab_bar.dart';
import 'package:quikle_rider/features/map/presentation/controller/map_controller.dart';
import 'package:quikle_rider/features/map/presentation/model/delivery_model.dart';
import 'package:quikle_rider/features/map/presentation/screen/parcel_done.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil if not already done in your app
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return ChangeNotifierProvider(
      create: (context) => MapController(),
      child: Consumer<MapController>(
        builder: (context, controller, child) {
          return Scaffold(
            backgroundColor: Colors.white,
            appBar: CustomTabBar(
              title: 'Map',
              isOnline: controller.isOnline,
              onToggle: controller.toggleOnlineStatus,
              currentIndex: 2,
            ),
            body: controller.currentDelivery == null
                ? const Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Map Area
                      _buildMapArea(),
                      // Delivery Information
                      _buildDeliveryInfo(context, controller),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildMapArea() {
    return Expanded(
      flex: 3,
      child: Container(
        width: double.infinity,
        child: Stack(
          children: [
            // Map background
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                image: const DecorationImage(
                  image: AssetImage('assets/images/mapdemo.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Route line and markers
            Positioned(
              top: 50.h,
              right: 20.w,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.yellow[700],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
            Positioned(
              bottom: 80.h,
              left: 20.w,
              child: Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.yellow[700],
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.location_on,
                  color: Colors.white,
                  size: 20.sp,
                ),
              ),
            ),
          ],
        ),
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
        Text(
          'Delivery Address',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white10,
            borderRadius: BorderRadius.circular(15.r),
          ),
          child: Text(
            delivery.estimatedTime,
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
              fontFamily: 'Obviously',
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
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              Text(
                delivery.customerAddress,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
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
            style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
          ),
        ),
      ],
    );
  }

  Widget _buildItemsSection(DeliveryModel delivery) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items to Deliver',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: Colors.black87,
            fontFamily: 'Obviously',
          ),
        ),
        SizedBox(height: 10.h),
        Text(
          delivery.restaurantName,
          style: TextStyle(
            fontSize: 14.sp,
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
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                Text(
                  item.description,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
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
              style: TextStyle(color: Colors.black87, fontSize: 14.sp),
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ParcelDone()),
              );
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
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w500,
                fontSize: 14.sp,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
