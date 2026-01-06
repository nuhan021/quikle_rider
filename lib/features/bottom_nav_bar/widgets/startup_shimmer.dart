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
              ShimmerCard.rectangular(height: 20.h, width: 160.w),
              SizedBox(height: 16.h),
              ShimmerCard.rectangular(height: 52.h),
              SizedBox(height: 24.h),
              Expanded(
                child: ListView.separated(
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: 4,
                  separatorBuilder: (_, __) => SizedBox(height: 16.h),
                  itemBuilder: (_, __) => Container(
                    padding: EdgeInsets.all(16.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.04),
                          blurRadius: 12.r,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerCard.rectangular(height: 16.h, width: 140.w),
                        SizedBox(height: 12.h),
                        ShimmerCard.rectangular(height: 12.h, width: 200.w),
                        SizedBox(height: 8.h),
                        ShimmerCard.rectangular(height: 12.h, width: 120.w),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
