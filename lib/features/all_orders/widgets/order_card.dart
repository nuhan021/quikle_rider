import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart'; // Added for navigation
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/features/all_orders/controllers/all_order_single.dart';
import 'package:quikle_rider/features/all_orders/models/oder_model.dart';

class OrderCard extends StatelessWidget {
  final OrderController controller;

  const OrderCard({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<OrderController>(
      init: controller,
      builder: (controller) {
        final order = controller.order.value;
        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
            shadows: const [
              BoxShadow(
                color: Color(0x0A606060),
                blurRadius: 8,
                offset: Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _OrderHeader(order: order),
              SizedBox(height: 8.h),
              _DeliveryProgress(order: order),
              SizedBox(height: 24.h),
              _PickupPoints(order: order),
              SizedBox(height: 24.h),
              _DeliveryInformation(order: order, controller: controller),
              SizedBox(height: 24.h),
              _DeliveryAddress(address: order.address),
              SizedBox(height: 24.h),
              _ItemsToDeliver(order: order),
              if (!order.isCompleted) ...[
                SizedBox(height: 12.h),
                _ActionButtons(controller: controller, order: order),
              ],
            ],
          ),
        );
      },
    );
  }
}

class _OrderHeader extends StatelessWidget {
  final OrderModel order;

  const _OrderHeader({required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Order ${order.id}',
          style: headingStyle2(color: const Color(0xFF000000)),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: ShapeDecoration(
            color: order.statusBgColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          child: Text(
            order.statusText,
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: order.statusColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _DeliveryProgress extends StatelessWidget {
  final OrderModel order;

  const _DeliveryProgress({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Progress',
          style: headingStyle2(color: const Color(0xFF000000)),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          height: 1.h,
          color: const Color(0x3FB7B7B7),
        ),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ProgressStep(
              'Picked Up',
              true,
              order.status != OrderStatus.preparing,
            ),
            _ProgressStep('In Progress', order.isInProgress, false),
            _ProgressStep('Delivered', order.isCompleted, false),
          ],
        ),
        SizedBox(height: 4.h),
        Stack(
          children: [
            Container(
              width: 328.w,
              height: 6.h,
              decoration: ShapeDecoration(
                color: const Color(0xFFF0F0F0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
            Container(
              width: order.progressWidth.w,
              height: 6.h,
              decoration: ShapeDecoration(
                color: const Color(0xFFFFC200),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProgressStep extends StatelessWidget {
  final String label;
  final bool isCompleted;
  final bool isActive;

  const _ProgressStep(this.label, this.isCompleted, this.isActive);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          children: [
            SizedBox(height: 1.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: getTextStyle(
                fontSize: 14,
                color: const Color(0xFF333333),
                fontWeight:
                    isCompleted || isActive ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupPoints extends StatelessWidget {
  final OrderModel order;

  const _PickupPoints({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pickup Points',
          style: headingStyle2(color: const Color(0xFF000000)),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0x3FB7B7B7)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: order.pickupStatus == 'Completed'
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFFFF6F00),
                    ),
                  ),
                  SizedBox(width: 8.w),
                  SizedBox(
                    width: 168.w,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          order.restaurant,
                          style: getTextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        Text(
                          order.address,
                          style: getTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF484848),
                          ),
                        ),
                        Text(
                          order.pickupStatusText,
                          style: getTextStyle(
                            fontSize: 12,
                            color: const Color(0xFF9B9B9B),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: order.pickupStatus == 'Completed'
                      ? const Color(0x264CAF50)
                      : const Color(0x26FF6F00),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  order.pickupStatus,
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: order.pickupStatus == 'Completed'
                        ? const Color(0xFF4CAF50)
                        : const Color(0xFFFF6F00),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _DeliveryInformation extends StatelessWidget {
  final OrderModel order;
  final OrderController controller;

  const _DeliveryInformation({required this.order, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Information',
          style: headingStyle2(color: const Color(0xFF000000)),
        ),
        SizedBox(height: 8.h),
        Container(
          width: double.infinity,
          height: 1.h,
          color: const Color(0x3FB7B7B7),
        ),
        SizedBox(height: 12.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.h,
                  decoration: const ShapeDecoration(
                    color: Color(0xFFC4C4C4),
                    shape: OvalBorder(),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      order.customerImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(
                          Icons.person,
                          size: 20,
                          color: Color(0xFF7C7C7C),
                        );
                      },
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                SizedBox(
                  width: 168.w,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.customerName,
                        style: getTextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      Text(
                        order.address,
                        style: getTextStyle(
                          fontSize: 14,
                          color: const Color(0xFF7C7C7C),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
            Row(
              children: [
                _ContactButton(
                  icon: 'assets/images/message.png',
                  onTap: controller.sendMessage,
                ),
                SizedBox(width: 16.w),
                _ContactButton(
                  icon: 'assets/images/call.png',
                  onTap: controller.makePhoneCall,
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }
}

class _ContactButton extends StatelessWidget {
  final String icon;
  final VoidCallback onTap;

  const _ContactButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24.w,
        height: 24.h,
        decoration: BoxDecoration(
          color: Colors.grey[100],
          borderRadius: BorderRadius.circular(6.r),
        ),
        child: Image.asset(
          icon,
          width: 16,
          height: 16,
          color: const Color.fromARGB(255, 0, 0, 0),
        ),
      ),
    );
  }
}

class _DeliveryAddress extends StatelessWidget {
  final String address;

  const _DeliveryAddress({required this.address});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Delivery Address',
          style: headingStyle2(color: const Color(0xFF000000)),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            const Icon(
              Icons.location_on_outlined,
              size: 18,
              color: Color(0xFF333333),
            ),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                address,
                style: getTextStyle(
                  fontSize: 14,
                  color: const Color(0xFF333333),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ItemsToDeliver extends StatelessWidget {
  final OrderModel order;

  const _ItemsToDeliver({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Items to Deliver',
          style: headingStyle2(color: const Color(0xFF000000)),
        ),
        SizedBox(height: 10.h),
        Text(
          order.restaurant,
          style: getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          height: 1.h,
          color: const Color(0x3FB7B7B7),
        ),
        SizedBox(height: 10.h),
        ...order.items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _FoodItem(item: item, imagePath: order.restaurantImage),
          ),
        ),
        SizedBox(height: 10.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Order Total:',
              style: getTextStyle(
                fontSize: 14,
                color: const Color(0xFF7C7C7C),
              ),
            ),
            Text(
              order.amount,
              style: getTextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: const Color(0xFF333333),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _FoodItem extends StatelessWidget {
  final OrderItem item;
  final String imagePath;

  const _FoodItem({required this.item, required this.imagePath});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.orange[100],
                  child: const Icon(
                    Icons.restaurant,
                    size: 24,
                    color: Colors.orange,
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          width: 168.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                item.name,
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              Text(
                item.details,
                style: getTextStyle(
                  fontSize: 12,
                  color: const Color(0xFF7C7C7C),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionButtons extends StatelessWidget {
  final OrderController controller;
  final OrderModel order;

  const _ActionButtons({required this.controller, required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: controller.cancelOrder,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF333333)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.h),
            ),
            child: Text(
              'Cancel',
              style: buttonTextStyle(
                color: const Color(0xFF333333),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ElevatedButton(
            onPressed: () => order.isReadyForPickup
                ? controller
                      .markAsPickedUp() // Call new method for pickup
                : controller
                      .navigateToDetails(), // Navigate to MapScreen for View Details
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF333333),
              side: const BorderSide(color: Color(0xFF333333)),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4.r),
              ),
              padding: EdgeInsets.symmetric(vertical: 10.h),
              elevation: 0,
            ),
            child: Text(
              order.isReadyForPickup ? 'Pick Up' : 'View Details',
              style: buttonTextStyle(
                color: const Color(0xFFFFFFFF),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
