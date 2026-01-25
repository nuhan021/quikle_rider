import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/core/widgets/shimmer/shimmer_card.dart';
import 'package:quikle_rider/core/widgets/shimmer/shimmer_loading.dart';

class StartupShimmer extends StatelessWidget {
  const StartupShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: _StatCardShimmer(height: 78.h)),
                  SizedBox(width: 12.w),
                  Expanded(child: _StatCardShimmer(height: 78.h)),
                  SizedBox(width: 12.w),
                  Expanded(child: _StatCardShimmer(height: 78.h)),
                ],
              ),
              SizedBox(height: 22.h),
              ShimmerCard.rectangular(height: 18.h, width: 220.w),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .04),
                      blurRadius: 12.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ShimmerCard.rectangular(height: 14.h, width: 220.w),
                    SizedBox(height: 10.h),
                    ShimmerCard.rectangular(height: 12.h, width: 180.w),
                    SizedBox(height: 30.h),
                    ShimmerCard.rectangular(height: 80.h, width: 180.w),
                     SizedBox(height: 30.h),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ShimmerCard.rectangular(height: 80.h, width: 180.w),
                    ),
                    

                  ],
                ),
              ),
              SizedBox(height: 12.h),
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 18.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12.r),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .04),
                      blurRadius: 12.r,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    ShimmerCard.rectangular(height: 14.h, width: 220.w),
                    SizedBox(height: 10.h),
                    ShimmerCard.rectangular(height: 12.h, width: 180.w),
                    SizedBox(height: 30.h),
                    ShimmerCard.rectangular(height: 80.h, width: 180.w),
                     SizedBox(height: 30.h),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: ShimmerCard.rectangular(height: 80.h, width: 180.w),
                    ),
                    

                  ],
                ),
              ),
              
                
            ],
          ),
        ),
      ),
    );
  }
}

class _StatCardShimmer extends StatelessWidget {
  const _StatCardShimmer({required this.height});

  final double height;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12.r,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          ShimmerCard.rectangular(height: 10.h, width: 50.w),
          ShimmerCard.rectangular(height: 18.h, width: 36.w),
          ShimmerCard.rectangular(height: 10.h, width: 60.w),
        ],
      ),
    );
  }
}
