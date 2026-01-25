import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RatingCard extends StatelessWidget {
  final double rating;
  final String totalRatings;
  final int reviewCount;

  const RatingCard({
    Key? key,
    required this.rating,
    required this.totalRatings,
    required this.reviewCount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.white,
      elevation: 3,
      shadowColor: Colors.black.withValues(alpha: 0.2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
      child: Padding(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 40.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                    height: 1,
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: List.generate(5, (index) {
                        return Icon(
                          _getStarIcon(index),
                          color: Color(0xFFFFA726),
                          size: 20.w,
                        );
                      }),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        Text(
                          '${rating.toStringAsFixed(1)} · $totalRatings',
                          style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          '$reviewCount reviews',
                          style: TextStyle(
                            fontSize: 13.sp,
                            decoration: TextDecoration.underline,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _getStarIcon(int index) {
    final fullStars = rating.floor();
    final hasHalfStar = (rating - fullStars) >= 0.3;

    if (index < fullStars) {
      return Icons.star;
    } else if (index == fullStars && hasHalfStar) {
      return Icons.star_half;
    } else {
      return Icons.star_border;
    }
  }
}
