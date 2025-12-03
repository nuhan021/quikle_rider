
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class ReferralShimmer extends StatelessWidget {
  const ReferralShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildShimmerContainer(height: 80.h),
            SizedBox(height: 16.h),
            _buildShimmerContainer(height: 320.h),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: _buildShimmerContainer(height: 90.h)),
                SizedBox(width: 12.w),
                Expanded(child: _buildShimmerContainer(height: 90.h)),
                SizedBox(width: 12.w),
                Expanded(child: _buildShimmerContainer(height: 90.h)),
              ],
            ),
            SizedBox(height: 16.h),
            _buildShimmerContainer(height: 200.h),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerContainer({required double height, double? width}) {
    return Container(
      height: height,
      width: width ?? double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
      ),
    );
  }
}
