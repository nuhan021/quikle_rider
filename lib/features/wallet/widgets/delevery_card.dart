import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';

enum DeliveryStatus { delivered, cancelled }

class DeliveryCard extends StatelessWidget {
  final String orderId;
  final DeliveryStatus status;
  final String amount;
  final String customerName;
  final String dateTime;
  final String? distance;     
  final String? rightSubline;  
  final String? bottomNote;     
  final VoidCallback? onViewDetails;
  final BoxDecoration? box;
  final BoxDecoration? decoration;

  const DeliveryCard({
    super.key,
    required this.orderId,
    required this.status,
    required this.amount,
    required this.customerName,
    required this.dateTime,
    this.distance,
    this.rightSubline,
    this.bottomNote,
    this.onViewDetails,
    this.box,
    this.decoration,
  });

  Color get _statusColor =>
      status == DeliveryStatus.delivered ? AppColors.greenbutton : AppColors.error;

  String get _statusText =>
      status == DeliveryStatus.delivered ? 'Delivered' : 'Cancelled';

  @override
  Widget build(BuildContext context) {
    // prefer the new `box`, fallback to `decoration` for backward compatibility
    final BoxDecoration effectiveBox = box ??
        decoration ??
        BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: const [
            BoxShadow(
              color: Color(0x14000000),
              blurRadius: 8,
              offset: Offset(0, 4),
            ),
          ],
        );

    final bool isDelivered = status == DeliveryStatus.delivered;
    final Color badgeColor = isDelivered
        ? AppColors.greenbutton.withValues(alpha: 0.15)
        : AppColors.error.withValues(alpha: 0.2);
    final Color badgeTextColor = isDelivered ? AppColors.greenbutton : AppColors.error;

    final Color statusNoteColor = isDelivered ? AppColors.greenbutton : AppColors.error;
    final String statusContextText = bottomNote ??
        (isDelivered ? 'Completed successfully' : 'Customer cancelled');

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.w),
      clipBehavior: Clip.antiAlias,
      decoration: effectiveBox,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section: Order info + amount
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Order #$orderId',
                    style: getTextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF333333),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: badgeColor,
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Text(
                      _statusText,
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: badgeTextColor,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                amount,
                style: headingStyle2(color: const Color(0xFF333333)),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Customer name + right subline
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                customerName,
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              if (rightSubline != null)
                Text(
                  rightSubline!,
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF919191),
                  ),
                ),
            ],
          ),
          SizedBox(height: 6.h),

          // Delivered time
          Text(
            '${isDelivered ? "Delivered" : "Cancelled"} on $dateTime',
            style: getTextStyle(
              fontSize: 14,
              color: const Color(0xFF7C7C7C),
            ),
          ),
          if (distance != null) ...[
            SizedBox(height: 8.h),
            Row(
              children: [
                Image.asset(
                  'assets/icons/location.png',
                  width: 12.sp,
                  height: 12.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  distance!,
                  style: getTextStyle(
                    fontSize: 14,
                    color: const Color(0xFF7C7C7C),
                  ),
                ),
              ],
            ),
          ],
          SizedBox(height: 16.h),

          // Status note + action
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                statusContextText,
                style: getTextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: statusNoteColor,
                ),
              ),
              GestureDetector(
                onTap: onViewDetails,
                child: Text(
                  'View Details',
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF333333),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
