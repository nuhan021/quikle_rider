import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class BonusTracking extends StatelessWidget {
  const BonusTracking({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DailyBonusTracker(
          deliveriesToday: 8,
          targetDeliveries: 10,
          nextBonus: '₹80',
          remainingDeliveries: 2,
        ),
        SizedBox(height: 12.h),
        WeeklyPerformanceCard(
          currentRating: 4.6,
          targetRating: 4.5,
          weeklyBonus: '₹400',
          isEligible: true,
        ),
        SizedBox(height: 12.h),
        MonthlyTopPerformerCard(
          currentRank: 3,
          totalDeliveries: 287,
          prize: '₹250',
        ),
      ],
    );
  }
}

// Daily Bonus Tracker Widget
class DailyBonusTracker extends StatelessWidget {
  final int deliveriesToday;
  final int targetDeliveries;
  final String nextBonus;
  final int remainingDeliveries;

  const DailyBonusTracker({
    Key? key,
    required this.deliveriesToday,
    required this.targetDeliveries,
    required this.nextBonus,
    required this.remainingDeliveries,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final progress = deliveriesToday / targetDeliveries;

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
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.blue.shade600,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Daily Bonus Tracker',
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Deliveries Today',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.black54,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                '$deliveriesToday/$targetDeliveries',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8.h,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
            ),
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: Colors.green.shade50,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Next Bonus',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      nextBonus,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.green.shade700,
                      ),
                    ),
                  ],
                ),
                Text(
                  '$remainingDeliveries more deliveries',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.black54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Weekly Performance Widget
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
                    color: isEligible
                        ? Colors.green.shade50
                        : Colors.grey.shade50,
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
                          color: isEligible
                              ? Colors.green.shade700
                              : Colors.black87,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        isEligible ? 'Eligible' : 'Not Eligible',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: isEligible
                              ? Colors.green.shade700
                              : Colors.black45,
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

// Monthly Top Performer Widget
class MonthlyTopPerformerCard extends StatelessWidget {
  final int currentRank;
  final int totalDeliveries;
  final String prize;

  const MonthlyTopPerformerCard({
    Key? key,
    required this.currentRank,
    required this.totalDeliveries,
    required this.prize,
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
                  color: Colors.purple.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Icon(
                  Icons.emoji_events_rounded,
                  color: Colors.purple.shade600,
                  size: 20.w,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                'Monthly Top Performer',
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
                child: _StatCard(
                  label: 'Current Rank',
                  value: '#$currentRank',
                  icon: Icons.military_tech_rounded,
                  color: Colors.amber,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _StatCard(
                  label: 'Total Deliveries',
                  value: '$totalDeliveries',
                  icon: Icons.inventory_2_rounded,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.amber.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Prize Money',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.black54,
                      ),
                    ),
                    Text(
                      prize,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.amber.shade700,
                      ),
                    ),
                  ],
                ),
                Icon(
                  Icons.card_giftcard_rounded,
                  color: Colors.amber.shade700,
                  size: 28.w,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 18.w),
          SizedBox(height: 8.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }
}