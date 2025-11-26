// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/core/widgets/shimmer/shimmer_card.dart';
import 'package:quikle_rider/core/widgets/shimmer/shimmer_loading.dart';

class ProfileListShimmerCard extends StatelessWidget {
  const ProfileListShimmerCard({
    super.key,
    this.showAvatar = false,
    this.margin,
    this.padding,
    this.lineWidths = const <double>[140, 100, 180],
    this.lineHeight = 14,
    this.showStatusBadge = false,
    this.statusBadgeWidth = 90,
  });

  final bool showAvatar;
  final EdgeInsetsGeometry? margin;
  final EdgeInsetsGeometry? padding;
  final List<double> lineWidths;
  final double lineHeight;
  final bool showStatusBadge;
  final double statusBadgeWidth;

  @override
  Widget build(BuildContext context) {
    return ShimmerLoading(
      child: Container(
        margin: margin ?? EdgeInsets.zero,
        padding: padding ?? EdgeInsets.all(16.w),
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showAvatar) ...[
              ShimmerCard.circular(diameter: 48.r),
              SizedBox(width: 16.w),
            ],
            Expanded(child: _buildLines()),
          ],
        ),
      ),
    );
  }

  Widget _buildLines() {
    final widgets = <Widget>[];
    for (var i = 0; i < lineWidths.length; i++) {
      widgets.add(
        ShimmerCard.rectangular(
          height: lineHeight.h,
          width: lineWidths[i].isFinite ? lineWidths[i].w : double.infinity,
        ),
      );
      if (i != lineWidths.length - 1) {
        widgets.add(SizedBox(height: 8.h));
      }
    }

    if (showStatusBadge) {
      if (widgets.isNotEmpty) widgets.add(SizedBox(height: 12.h));
      widgets.add(
        ShimmerCard.rectangular(height: 22.h, width: statusBadgeWidth.w),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: widgets,
    );
  }
}
