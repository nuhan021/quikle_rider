// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import 'package:quikle_rider/features/home/models/home_dashboard_models.dart';

class AssignmentCard extends StatelessWidget {
  final String orderId;
  final String customerName;
  final String arrivalTime;
  final String address;
  final String distance;
  final String total;
  final String? breakdown;
  final bool isUrgent;
  final bool isCombined;
  final String? deleverystatus;
  final String? orderStatus;
  final AssignmentStatus? status;
  final bool showActions;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const AssignmentCard({
    super.key,
    required this.orderId,
    required this.deleverystatus,
    required this.customerName,
    required this.arrivalTime,
    required this.address,
    required this.distance,
    required this.total,
    this.breakdown,
    required this.isUrgent,
    required this.isCombined,
    this.orderStatus,
    this.status,
    this.showActions = true,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    final AssignmentStatus? currentStatus = status;
    final bool isPending =
        currentStatus == null || currentStatus == AssignmentStatus.pending;
    final List<String> breakdownLines = breakdown == null
        ? const []
        : breakdown!.split('\n');
    final String? displayStatus =
        orderStatus != null && orderStatus!.trim().isNotEmpty
            ? orderStatus
            : currentStatus?.label;

    Color? statusColor;
    if (currentStatus != null) {
      switch (currentStatus) {
        case AssignmentStatus.pending:
          statusColor = const Color(0xFF6B7280);
          break;
        case AssignmentStatus.accepted:
          statusColor = const Color(0xFF1DAA6F);
          break;
        case AssignmentStatus.rejected:
          statusColor = const Color(0xFFE03E1A);
          break;
        case AssignmentStatus.outForDelivery:
          statusColor = const Color(0xFF2563EB);
          break;
      }
    }

    return Container(
      // width: 350.w,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A606060),
            blurRadius: 8.r,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$orderId',
                style: TextStyle(
                  fontFamily: 'Obviously',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF484848),
                ),
              ),

              if (isUrgent)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: const Color(0x26FF0000),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Urgent',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      color: const Color(0xFFFF0000),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),

              Container(
                padding: EdgeInsets.symmetric(vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  deleverystatus!,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.sp,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (displayStatus != null) ...[
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color:
                        statusColor?.withValues(alpha: 0.12) ??
                        const Color(0x11000000),
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    displayStatus,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      color: statusColor ?? const Color(0xFF6B7280),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ],
          ),

          SizedBox(height: 8.h),

          // Customer Info
          Text(
            customerName,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16.sp,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),

          SizedBox(height: 12.h),

          // Arrival Time
          Row(
            children: [
              Icon(Icons.access_time, size: 18.sp, color: Colors.black),
              SizedBox(width: 6.w),
              Text(
                arrivalTime,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  color: Colors.black,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 18.sp,
                          color: Colors.black,
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          distance,
                          style: TextStyle(
                            fontFamily: 'Manrope',
                            fontSize: 14.sp,
                            color: const Color(0xFF484848),
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          Divider(color: const Color(0x3FB7B7B7), thickness: 1.h),

          SizedBox(height: 16.h),

          // Payout summary
          Text(
            'Order Payout: $total',
            style: TextStyle(
              fontFamily: 'Obviously',
              fontSize: 16.sp,
              fontWeight: FontWeight.w900,
              color: const Color(0xFF333333),
            ),
          ),
          if (breakdown != null) ...[
            SizedBox(height: 6.h),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int index = 0; index < breakdownLines.length; index++)
                  Padding(
                    padding: EdgeInsets.only(
                      bottom: index == breakdownLines.length - 1 ? 0 : 4.h,
                    ),
                    child: Text(
                      breakdownLines[index],
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                  ),
              ],
            ),
          ],

          SizedBox(height: 16.h),

          // Action Buttons
          if (showActions && isPending)
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: OutlinedButton(
                      onPressed: onReject,
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(
                          color: const Color(0xFFE03E1A),
                          width: 1.w,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                      ),
                      child: Text(
                        'Reject',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          color: const Color(0xFFFF0000),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: ElevatedButton(
                      onPressed: onAccept,
                      style: ElevatedButton.styleFrom(
                        side: BorderSide.none,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        elevation: 0,
                      ),
                      child: Text(
                        'Accept',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
