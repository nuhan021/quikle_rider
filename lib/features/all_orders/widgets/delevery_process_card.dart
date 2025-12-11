// widgets/combined_order_widgets.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/route_manager.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/features/all_orders/controllers/all_order_combioned_controller.dart';
import 'package:quikle_rider/features/all_orders/models/combine_ordermodel.dart';
import 'package:quikle_rider/features/messages/presentation/conversations_list.dart';
import 'package:quikle_rider/features/messages/presentation/massage_screen.dart';

class DeliveryProgressCard extends StatelessWidget {
  final CombinedOrderModel order;

  const DeliveryProgressCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final totalSteps = 3;
    final completedSteps = [
      order.isPickedUp,
      order.isInProgress,
      order.isDelivered,
    ].where((step) => step).length;

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
          _ProgressHeader(
            completedSteps: completedSteps,
            totalSteps: totalSteps,
          ),
          SizedBox(height: 12.h),
          _ProgressSteps(
            order: order,
            completedSteps: completedSteps,
            totalSteps: totalSteps,
          ),
          SizedBox(height: 24.h),
          _PickupPointsSection(pickupPoints: order.pickupPoints),
        ],
      ),
    );
  }
}

class _ProgressHeader extends StatelessWidget {
  final int completedSteps;
  final int totalSteps;

  const _ProgressHeader({
    required this.completedSteps,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Delivery Progress',
          style: headingStyle2(color: const Color(0xFF000000)),
        ),
        Text(
          '$completedSteps of $totalSteps steps',
          style: getTextStyle(
            fontSize: 16,
            color: const Color(0xFF919191),
          ),
        ),
      ],
    );
  }
}

class _ProgressSteps extends StatelessWidget {
  final CombinedOrderModel order;
  final int completedSteps;
  final int totalSteps;

  const _ProgressSteps({
    required this.order,
    required this.completedSteps,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    final steps = [
      ('Picked Up', order.isPickedUp),
      ('In Progress', order.isInProgress),
      ('Delivered', order.isDelivered),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          height: 1.h,
          color: const Color(0x3FB7B7B7),
        ),
        SizedBox(height: 12.h),
        Row(
          children: List.generate(steps.length, (index) {
            final label = steps[index].$1;
            final isActive = index < completedSteps;

            final textAlign = index == 0
                ? TextAlign.left
                : index == steps.length - 1
                    ? TextAlign.right
                    : TextAlign.center;

            return Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: index == 1 ? 12.w : 0),
                child: Text(
                  label,
                  textAlign: textAlign,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 8.h),
        LayoutBuilder(
          builder: (context, constraints) {
            final double segmentWidth = constraints.maxWidth / totalSteps;
            final double filledWidth =
                (completedSteps.clamp(0, totalSteps)) * segmentWidth;

            return Container(
              width: double.infinity,
              height: 6.h,
              decoration: BoxDecoration(
                color: const Color(0xFFF0F0F0),
                borderRadius: BorderRadius.circular(4.r),
              ),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Container(
                  width: filledWidth,
                  height: 6.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFC200),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
              ),
            );
          },
        ),
      ],
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
        Text(
          'Pickup Points',
          style: headingStyle2(color: const Color(0xFF000000)),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          height: 1.h,
          color: const Color(0x3FB7B7B7),
        ),
        SizedBox(height: 16.h),
        ...pickupPoints.asMap().entries.map((entry) {
          final isLast = entry.key == pickupPoints.length - 1;
          return Column(
            children: [
              _PickupPointItem(pickupPoint: entry.value),
              if (!isLast) ...[
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  height: 1.h,
                  color: const Color(0x3FB7B7B7),
                ),
                SizedBox(height: 16.h),
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 6.0),
              child: Container(
                width: 20.w,
                height: 20.h,
                decoration: BoxDecoration(
              
            
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Icon(
                    pickupPoint.status == PickupStatus.completed
                        ? Icons.check_circle
                        : Icons.more_horiz,
                    color: pickupPoint.dotColor,
                    size: 20.w,
                  ),
                ),
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              width: 180.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pickupPoint.name,
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    pickupPoint.address,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF484848),
                    ),
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    pickupPoint.statusText,
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
            color: pickupPoint.statusBgColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
          child: Text(
            pickupPoint.statusString,
            style: getTextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: pickupPoint.statusTextColor,
            ),
          ),
        ),
      ],
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
          _DeliveryInfoSection(order: order, controller: controller),
          SizedBox(height: 24.h),
          _OrderPayoutSection(order: order),
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
                          lineHeight: 1.3,
                        ),
                      ),
                      Text(
                        '123 Main St, Bangkok',
                        style: getTextStyle(
                          fontSize: 14,
                          color: const Color(0xFF7C7C7C),
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
                  onTap: (){
                       Get.to(MassageScreen());


                  },
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

class _OrderPayoutSection extends StatelessWidget {
  final CombinedOrderModel order;

  const _OrderPayoutSection({required this.order});

  @override
  Widget build(BuildContext context) {
    final String currency = order.currency;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Order Payout Breakdown',
          style: headingStyle2(color: const Color(0xFF000000)),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(12.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF8F8F8),
            borderRadius: BorderRadius.circular(8.r),
            border: Border.all(color: const Color(0x3FB7B7B7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _PayoutRow(
                label: 'Total Order Payout',
                value: '$currency${order.formattedTotalPayout}',
              ),
              SizedBox(height: 8.h),
              ...order.pickupPayouts.asMap().entries.map((entry) {
                final index = entry.key + 1;
                final pickup = entry.value;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: index == order.pickupPayouts.length ? 0 : 8.h,
                  ),
                  child: _PayoutRow(
                    label: 'Pickup $index: ${pickup.pickupName}',
                    value: 'Base: $currency${pickup.formatAmount()}',
                  ),
                );
              }),
              if (order.pickupPayouts.isNotEmpty) SizedBox(height: 8.h),
              _PayoutRow(
                label: 'Distance (${order.formattedDistance}km)',
                value: '$currency${order.formatAmount(order.distancePay)}',
              ),
              SizedBox(height: 8.h),
              _PayoutRow(
                label: 'Combined Order Bonus',
                value:
                    '$currency${order.formatAmount(order.combinedOrderBonus)}',
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _PayoutRow extends StatelessWidget {
  final String label;
  final String value;

  const _PayoutRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            label,
            style: getTextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF333333),
              lineHeight: 1.4,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Text(
          value,
          style: getTextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF484848),
            lineHeight: 1.4,
          ),
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

class _ItemsToDeliverSection extends StatelessWidget {
  final List<Restaurant> restaurants;

  const _ItemsToDeliverSection({required this.restaurants});

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
        ...restaurants.map(
          (restaurant) => _RestaurantSection(restaurant: restaurant),
        ),
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
          style: getTextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: const Color(0xFF333333),
            lineHeight: 1.3,
          ),
        ),
        SizedBox(height: 10.h),
        Container(
          width: double.infinity,
          height: 1.h,
          color: const Color(0x3FB7B7B7),
        ),
        SizedBox(height: 10.h),
        ...restaurant.items.map(
          (item) => Padding(
            padding: EdgeInsets.only(bottom: 10.h),
            child: _MenuItemWidget(item: item),
          ),
        ),
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.asset(
              item.imagePath,
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
                  lineHeight: 1.3,
                ),
              ),
              Text(
                item.details,
                style: getTextStyle(
                  fontSize: 12,
                  color: const Color(0xFF7C7C7C),
                  lineHeight: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
