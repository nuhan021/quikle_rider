import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WeeklyPerformanceCard extends StatelessWidget {
  final String acceptanceRate;
  final String onTimeRate;
  final int totalDeliveries;
  final String acceptanceTarget;
  final String onTimeTarget;

  const WeeklyPerformanceCard({
    Key? key,
    required this.acceptanceRate,
    required this.onTimeRate,
    required this.totalDeliveries,
    this.acceptanceTarget = '90%',
    this.onTimeTarget = '92%',
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
                  Icons.timeline_rounded,
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
                child: _MetricTile(
                  label: 'Acceptance Rate',
                  value: acceptanceRate,
                  target: acceptanceTarget,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: _MetricTile(
                  label: 'On-Time Rate',
                  value: onTimeRate,
                  target: onTimeTarget,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Icon(Icons.delivery_dining_rounded, color: Colors.black54, size: 20.w),
                SizedBox(width: 8.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Deliveries',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.black54,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '$totalDeliveries',
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
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

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.target,
  });

  final String label;
  final String value;
  final String target;

  @override
  Widget build(BuildContext context) {
    final meetsTarget = _parsePercent(value) >= _parsePercent(target);
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              color: Colors.black54,
            ),
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black87,
                ),
              ),
              SizedBox(width: 6.w),
              if (value != '--')
                Icon(
                  meetsTarget ? Icons.check_circle : Icons.info_outline,
                  color: meetsTarget ? Colors.green : Colors.orangeAccent,
                  size: 18.w,
                ),
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            'Target: $target',
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.black45,
            ),
          ),
        ],
      ),
    );
  }

  double _parsePercent(String input) {
    final cleaned = input.replaceAll('%', '').trim();
    return double.tryParse(cleaned) ?? 0;
  }
}
