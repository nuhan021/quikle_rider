import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeeklyPerformanceCard extends StatelessWidget {
  final double currentRating;
  final double targetRating;
  final String weeklyBonus;
  final bool isEligible;

  const WeeklyPerformanceCard({
    Key? key,
    required this.currentRating,
    required this.targetRating,
    required this.weeklyBonus,
    required this.isEligible,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10.r,
            offset: Offset(0, 4.h),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.star_rounded,
                  color: Colors.orange.shade600,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Weekly Performance',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Current Rating',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            '$currentRating★',
                            style: TextStyle(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          if (currentRating >= targetRating)
                            Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 18.w,
                            ),
                        ],
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'Target: $targetRating★',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: Colors.black45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: isEligible ? Colors.green.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Weekly Bonus',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        weeklyBonus,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w700,
                          color: isEligible ? Colors.green.shade700 : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isEligible ? 'Eligible' : 'Not Eligible',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isEligible ? Colors.green.shade700 : Colors.black45,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
