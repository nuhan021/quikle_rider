import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              blurRadius: 10,
              offset: Offset(0, 2),
            ),
          ],
          border: Border.all(color: const Color(0xFFEDEDED)),
        );

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(12.w),
      decoration: effectiveBox,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Left: order id + badge
              Expanded(
                child: Row(
                  children: [
                    Text(
                      'Order $orderId',
                      style: TextStyle(
                        fontFamily: 'Obviously',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: _statusColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        _statusText,
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w600,
                          color: _statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // Right: amount + tip/fee
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  if (rightSubline != null) ...[
                    SizedBox(height: 2.h),
                    Text(
                      rightSubline!,
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: status == DeliveryStatus.delivered
                            ? AppColors.beakYellow
                            : Colors.black54,
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),

          // Customer + View details
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                customerName,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              GestureDetector(
                onTap: onViewDetails,
                child: Text(
                  'View Details',
                  style: TextStyle(

                    fontSize: 12.sp,
                    color: const Color.fromARGB(255, 0, 0, 0),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 6.h),

          // Delivered on...
          Text(
            '${status == DeliveryStatus.delivered ? "Delivered" : "Cancelled"} on $dateTime',
            style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
          ),

          // distance + bottom note
          if (distance != null || bottomNote != null) SizedBox(height: 6.h),
          if (distance != null)
            Row(
              children: [
                Image.asset('assets/icons/location.png', width: 10.sp, height: 10.sp, ),
                SizedBox(width: 6.w),
                Text(
                  distance!,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ],
            ),
          if (bottomNote != null) ...[
            SizedBox(height: 6.h),
            Text(
              bottomNote!,
              style: TextStyle(
                fontSize: 12.sp,
                color: const Color(0xFFE74C3C),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
