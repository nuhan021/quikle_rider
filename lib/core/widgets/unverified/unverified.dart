// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:quikle_rider/routes/app_routes.dart';

class UnverifiedBanner extends StatelessWidget {

  final String title;
  final String subtitle;

  const UnverifiedBanner({
    super.key,
  
    this.title = 'Account not verified',
    this.subtitle = 'Complete verification to unlock assignments and payouts.',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(18.w),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF0A0A0A), // deep black
            Color(0xFF1C1C1C), // charcoal
          ],
        ),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: Colors.amber.withValues(alpha: 0.18),
        ),
        
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          SizedBox(height: 14.h),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Obviously',
              fontSize: 18.sp,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13.sp,
              height: 1.4,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          SizedBox(height: 16.h),
          _CompleteVerificationButton(
            onPressed: (){
              Get.toNamed(AppRoute.uploaddocuments);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.22),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Icon(
            Icons.verified_outlined,
            color: Colors.amber,
            size: 20.sp,
          ),
        ),
        SizedBox(width: 10.w),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: Colors.amber.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(999.r),
          ),
          child: Text(
            'Verification Pending',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: Colors.amber.shade300,
              letterSpacing: 0.2,
            ),
          ),
        ),
      ],
    );
  }
}

class _CompleteVerificationButton extends StatelessWidget {
  final VoidCallback? onPressed;

  const _CompleteVerificationButton({this.onPressed});

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    final List<Color> gradientColors = enabled
        ? const [
            Color(0xFFFFC107), // amber
            Color(0xFFFF8F00), // dark amber
          ]
        : const [
            Color(0x66FFC107),
            Color(0x66FF8F00),
          ];

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(16.r),
        child: Ink(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: gradientColors,
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: Colors.amber.withValues(alpha: 0.35),
                      blurRadius: 12.r,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.task_alt_rounded,
                color: Colors.black,
                size: 18.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Complete verification',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(width: 6.w),
              Icon(
                Icons.arrow_forward_rounded,
                color: Colors.black.withValues(alpha: 0.9),
                size: 18.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
