// widgets/combined_order_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/features/all_orders/controllers/all_order_combioned_controller.dart';
import 'package:quikle_rider/features/all_orders/models/combine_ordermodel.dart';


class DeliveryProgressCard extends StatelessWidget {
  final CombinedOrderModel order;

  const DeliveryProgressCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
          _ProgressHeader(progressText: order.progressText),
          SizedBox(height: 8.h),
          _ProgressSteps(order: order),
          SizedBox(height: 24.h),
          _PickupPointsSection(pickupPoints: order.pickupPoints),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final String progressText;

  const _ProgressHeader({required this.progressText});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Delivery Progress',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 0, 0, 0),
            fontFamily: 'Obviously',
            height: 1.40,
          ),
        ),
        Text(
          progressText,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Color(0xFF919191),
            fontFamily: 'Inter',
            height: 1.50,
          ),
        ),
      ],
    );
  }
}

class _ProgressSteps extends StatelessWidget {
  final CombinedOrderModel order;

  const _ProgressSteps({required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(width: double.infinity, height: 1.h, color: const Color(0x3FB7B7B7)),
        SizedBox(height: 4.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _ProgressStep('Picked Up', order.isPickedUp, true),
            _ProgressStep('In Progress', order.isInProgress, false),
            _ProgressStep('Delivered', order.isDelivered, false),
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
              ),
            ),
            Container(
              width: order.progressWidth.w,
              height: 6.h,
              decoration: ShapeDecoration(
                color: const Color(0xFFFFC200),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4.r)),
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
              style: TextStyle(
                fontSize: 14,
                color: const Color(0xFF333333),
                fontWeight: isCompleted || isActive ? FontWeight.w600 : FontWeight.w400,
                fontFamily: 'Inter',
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PickupPointsSection extends StatelessWidget {
  final List<PickupPoint> pickupPoints;

  const _PickupPointsSection({required this.pickupPoints});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Pickup Points',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 0, 0, 0),
            fontFamily: 'Obviously',
            height: 1.40,
          ),
        ),
        SizedBox(height: 12.h),
        ...pickupPoints.asMap().entries.map((entry) {
          final index = entry.key;
          final point = entry.value;
          return Column(
            children: [
              _PickupPointItem(pickupPoint: point),
              if (index < pickupPoints.length - 1) ...[
                SizedBox(height: 12.h),
                Container(
                  width: double.infinity,
                  height: 1.h,
                  color: const Color(0x3FB7B7B7),
                ),
                SizedBox(height: 12.h),
              ],
            ],
          );
        }),
      ],
    );
  }
}

class _PickupPointItem extends StatelessWidget {
  final PickupPoint pickupPoint;

  const _PickupPointItem({required this.pickupPoint});

  @override
  Widget build(BuildContext context) {
    return Container(
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
                  color: pickupPoint.dotColor,
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                width: 168.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pickupPoint.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: 'Inter',
                        height: 1.50,
                      ),
                    ),
                    Text(
                      pickupPoint.address,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF484848),
                        fontFamily: 'Inter',
                        height: 1.20,
                      ),
                    ),
                    Text(
                      pickupPoint.statusText,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Color(0xFF9B9B9B),
                        fontFamily: 'Inter',
                        height: 1.30,
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
              color: pickupPoint.statusBgColor,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              pickupPoint.statusString,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: pickupPoint.statusTextColor,
                fontFamily: 'Manrope',
                height: 1.50,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DeliveryInfoCard extends StatelessWidget {
  final CombinedOrderModel order;
  final CombinedOrderController controller;

  const DeliveryInfoCard({
    super.key,
    required this.order,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
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
          _DeliveryInfoSection(order: order, controller: controller),
          SizedBox(height: 24.h),
          _DeliveryAddressSection(address: order.deliveryAddress),
          SizedBox(height: 24.h),
          _ItemsToDeliverSection(restaurants: order.restaurants),
        ],
      ),
    );
  }
}

class _DeliveryInfoSection extends StatelessWidget {
  final CombinedOrderModel order;
  final CombinedOrderController controller;

  const _DeliveryInfoSection({required this.order, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Information',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 0, 0, 0),
            fontFamily: 'Obviously',
            height: 1.40,
          ),
        ),
        SizedBox(height: 8.h),
        Container(width: double.infinity, height: 1.h, color: const Color(0x3FB7B7B7)),
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
                        return const Icon(Icons.person, size: 20, color: Color(0xFF7C7C7C));
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
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF333333),
                          fontFamily: 'Inter',
                          height: 1.20,
                        ),
                      ),
                      const Text(
                        '123 Main St, Bangkok',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                          color: Color(0xFF7C7C7C),
                          fontFamily: 'Inter',
                          height: 1.50,
                        ),
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

class _DeliveryAddressSection extends StatelessWidget {
  final String address;

  const _DeliveryAddressSection({required this.address});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Delivery Address',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 0, 0, 0),
            fontFamily: 'Obviously',
            height: 1.40,
          ),
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            const Icon(Icons.location_on_outlined, size: 18, color: Color(0xFF333333)),
            SizedBox(width: 2.w),
            Expanded(
              child: Text(
                address,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF333333),
                  fontFamily: 'Manrope',
                  height: 1.50,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ItemsToDeliverSection extends StatelessWidget {
  final List<Restaurant> restaurants;

  const _ItemsToDeliverSection({required this.restaurants});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Items to Deliver',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w900,
            color: Color.fromARGB(255, 0, 0, 0),
            fontFamily: 'Obviously',
            height: 1.40,
          ),
        ),
        SizedBox(height: 10.h),
        ...restaurants.map((restaurant) => _RestaurantSection(restaurant: restaurant)),
      ],
    );
  }
}

class _RestaurantSection extends StatelessWidget {
  final Restaurant restaurant;

  const _RestaurantSection({required this.restaurant});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          restaurant.name,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Color(0xFF333333),
            fontFamily: 'Inter',
            height: 1.20,
          ),
        ),
        SizedBox(height: 10.h),
        Container(width: double.infinity, height: 1.h, color: const Color(0x3FB7B7B7)),
        SizedBox(height: 10.h),
        ...restaurant.items.map((item) => Padding(
          padding: EdgeInsets.only(bottom: 10.h),
          child: _MenuItemWidget(item: item),
        )),
      ],
    );
  }
}

class _MenuItemWidget extends StatelessWidget {
  final MenuItem item;

  const _MenuItemWidget({required this.item});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6.r)),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.asset(
              item.imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.orange[100],
                  child: const Icon(Icons.restaurant, size: 24, color: Colors.orange),
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
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontFamily: 'Inter',
                  height: 1.20,
                ),
              ),
              Text(
                item.details,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: Color(0xFF7C7C7C),
                  fontFamily: 'Inter',
                  height: 1.30,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}