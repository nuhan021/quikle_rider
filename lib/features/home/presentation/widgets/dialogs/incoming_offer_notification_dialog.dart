import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';

class IncomingOfferNotificationDialog extends StatelessWidget {
  final String title;
  final String body;
  final String? orderId;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;
  final bool isProcessing;
  final bool isAccepting;
  final bool isRejecting;

  const IncomingOfferNotificationDialog({
    super.key,
    required this.title,
    required this.body,
    this.orderId,
    this.onAccept,
    this.onReject,
    this.isProcessing = false,
    this.isAccepting = false,
    this.isRejecting = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      backgroundColor: Colors.transparent,
      child: Container(
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
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Obviously',
                fontSize: 16.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF484848),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              body,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w400,
              ),
            ),
            if (orderId != null && orderId!.trim().isNotEmpty) ...[
              SizedBox(height: 10.h),
              Text(
                'Order: $orderId',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.sp,
                  color: const Color(0xFF6B7280),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 40.h,
                    child: OutlinedButton(
                      onPressed: isProcessing ? null : onReject,
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
                      child: isRejecting
                          ? SizedBox(
                              width: 18.sp,
                              height: 18.sp,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Color(0xFFE03E1A),
                                ),
                              ),
                            )
                          : Text(
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
                      onPressed: isProcessing ? null : onAccept,
                      style: ElevatedButton.styleFrom(
                        side: BorderSide.none,
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        elevation: 0,
                      ),
                      child: isAccepting
                          ? SizedBox(
                              width: 18.sp,
                              height: 18.sp,
                              child: const CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
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
      ),
    );
  }
}
