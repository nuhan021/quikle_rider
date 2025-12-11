import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/features/wallet/controllers/wallet_controller.dart';

class BonusProgressCard extends StatelessWidget {
  final WalletController controller;

  const BonusProgressCard({
    Key? key,
    required this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.isBonusProgressLoading.value) {
        return Center(
          child: Padding(
            padding: EdgeInsets.symmetric(vertical: 20.h),
            child: const CircularProgressIndicator(),
          ),
        );
      }

      if (controller.bonusProgressError.value != null && controller.bonusProgressError.value!.isNotEmpty) {
        return SizedBox.shrink();
      }

      final bonusData = controller.bonusProgress.value ?? {};
      final criteria = (bonusData['criteria'] as List?)?.cast<Map<String, dynamic>>() ?? [];
      final month = bonusData['month'] as String? ?? 'N/A';
      final criteriasMet = (bonusData['criteria_met'] ?? 0) as int;
      final totalCriteria = (bonusData['total_criteria'] ?? 0) as int;
      final bonusAmount = (bonusData['bonus_amount'] ?? 0) as num;
      final eligibleForBonus = bonusData['eligible_for_bonus'] ?? false;

      final progressPercent = totalCriteria > 0 ? (criteriasMet / totalCriteria).clamp(0, 1) : 0.0;

      return Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.06),
              blurRadius: 10.r,
              offset: Offset(0, 4.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with icon
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFE8A3),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        Icons.card_giftcard,
                        color: Colors.amber.shade700,
                        size: 20.w,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Monthly Bonus',
                          style: TextStyle(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.black87,
                          ),
                        ),
                        Text(
                          month,
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: eligibleForBonus ? const Color(0xFFE6FFE6) : const Color(0xFFFFE6E6),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    eligibleForBonus ? '✓ Eligible' : '✗ Not Eligible',
                    style: TextStyle(
                      fontSize: 11.sp,
                      fontWeight: FontWeight.w600,
                      color: eligibleForBonus ? const Color(0xFF2E7D32) : const Color(0xFFC62828),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),

            // Criteria Met Progress
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Criteria Met',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  '$criteriasMet/$totalCriteria',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.r),
              child: LinearProgressIndicator(
                value: (progressPercent as double?),
                minHeight: 6.h,
                backgroundColor: Colors.grey[200],
                valueColor: AlwaysStoppedAnimation<Color>(
                  eligibleForBonus ? Colors.green : Colors.orange,
                ),
              ),
            ),
            SizedBox(height: 12.h),

            // Bonus Amount
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF9E6),
                borderRadius: BorderRadius.circular(10.r),
                border: Border.all(
                  color: Colors.amber.shade200,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Total Bonus Amount',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    '₹${bonusAmount.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w700,
                      color: bonusAmount > 0 ? Colors.amber.shade700 : Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // Criteria List Header
            Text(
              'Criteria Requirements',
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 12.h),

            // Criteria Items
            ...criteria.asMap().entries.map((entry) {
              final index = entry.key;
              final criterion = entry.value;
              final name = criterion['name'] as String? ?? 'N/A';
              final required = criterion['required'] as num? ?? 0;
              final current = criterion['current'] as num? ?? 0;
              final met = criterion['met'] as bool? ?? false;
              final note = criterion['note'] as String?;

              return Padding(
                padding: EdgeInsets.only(bottom: index == criteria.length - 1 ? 0 : 12.h),
                child: Container(
                  padding: EdgeInsets.all(12.w),
                  decoration: BoxDecoration(
                    color: met ? Colors.green.shade50 : Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(10.r),
                    border: Border.all(
                      color: met ? Colors.green.shade200 : Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 28.w,
                        height: 28.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: met ? Colors.green : Colors.grey.shade300,
                        ),
                        child: Icon(
                          met ? Icons.check : Icons.close,
                          size: 14.w,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: TextStyle(
                                fontSize: 12.sp,
                                fontWeight: FontWeight.w600,
                                color: Colors.black87,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Progress: $current/$required',
                                  style: TextStyle(
                                    fontSize: 11.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                if (note != null)
                                  Flexible(
                                    child: Text(
                                      note,
                                      style: TextStyle(
                                        fontSize: 10.sp,
                                        color: Colors.blue.shade600,
                                        fontStyle: FontStyle.italic,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      );
    });
  }
}
