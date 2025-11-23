import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

class WalletShimmerList extends StatelessWidget {
  const WalletShimmerList({super.key});

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      );

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        children: [
          _block(height: 160.h),
          SizedBox(height: 12.h),
          _block(height: 140.h),
          SizedBox(height: 12.h),
          _statRow(),
          SizedBox(height: 12.h),
          _statRow(),
          SizedBox(height: 12.h),
          _statRow(),
          SizedBox(height: 12.h),
          _block(height: 120.h),
          SizedBox(height: 12.h),
          _deliveriesPlaceholder(),
        ],
      ),
    );
  }

  Widget _block({required double height}) {
    return Container(
      height: height,
      decoration: _cardDecoration,
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line(widthFactor: 0.4),
          SizedBox(height: 12.h),
          _line(widthFactor: 0.6, height: 18.h),
          const Spacer(),
          _line(widthFactor: 0.8),
          SizedBox(height: 8.h),
          _line(widthFactor: 0.5),
        ],
      ),
    );
  }

  Widget _statRow() {
    return Row(
      children: [
        Expanded(child: _statTile()),
        SizedBox(width: 12.w),
        Expanded(child: _statTile()),
      ],
    );
  }

  Widget _statTile() {
    return Container(
      height: 110.h,
      decoration: _cardDecoration,
      padding: EdgeInsets.all(14.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _line(widthFactor: 0.5),
          const Spacer(),
          _line(widthFactor: 0.7, height: 18.h),
        ],
      ),
    );
  }

  Widget _deliveriesPlaceholder() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: List.generate(3, (index) {
        return Padding(
          padding: EdgeInsets.only(bottom: index == 2 ? 0 : 12.h),
          child: Container(
            decoration: _cardDecoration,
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _line(widthFactor: 0.6, height: 16.h),
                      SizedBox(height: 8.h),
                      _line(widthFactor: 0.4),
                    ],
                  ),
                ),
                SizedBox(width: 12.w),
                _line(width: 50.w, height: 16.h),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _line({double? width, double widthFactor = 1, double height = 12}) {
    return FractionallySizedBox(
      widthFactor: width != null ? null : widthFactor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.r),
        ),
      ),
    );
  }
}
