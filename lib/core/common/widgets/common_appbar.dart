import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';

//common appbar
class UnifiedProfileAppBar extends StatelessWidget
    implements PreferredSizeWidget {
  final String title;
  final String? action;
  final VoidCallback? onActionPressed;
  final bool showActionButton;
  final double height;

  const UnifiedProfileAppBar({
    super.key,
    required this.title,
    this.action,
    this.onActionPressed,
    this.showActionButton = false,
    this.height = 72.0,
  });

  @override
  Size get preferredSize => Size.fromHeight(height.h);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: preferredSize.height,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        border: Border(
          bottom: BorderSide(color: AppColors.gradientColor, width: 2.w),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A616161),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
        child: Row(
          children: [
            // // Back button
            // GestureDetector(
            //   onTap: () => Get.back(),
            //   child: Container(
            //     padding: EdgeInsets.all(8.w),
            //     child: Icon(
            //       Icons.arrow_back_ios,
            //       color: AppColors.blackText,
            //       size: 20.sp,
            //     ),
            //   ),
            // ),

            SizedBox(width: 8.w),

            // Title
            Expanded(
              child: Text(
                title,
                style: getTextStyle2(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w500,
                  color: AppColors.blackText,
                ),
              ),
            ),

            // Action button
            if (showActionButton && action != null)
              InkWell(
                child: Image.asset(
                  'assets/images/notification.png',
                  width: 40.w,
                  height: 40.h,
                ),
                onTap: onActionPressed,
              ),
          ],
        ),
      ),
    );
  }
}
