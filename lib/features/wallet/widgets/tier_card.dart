import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TierCard extends StatelessWidget {
  final String tier;
  final Color? customColor;
  final IconData? customIcon;

  const TierCard({
    Key? key,
    required this.tier,
    this.customColor,
    this.customIcon,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tierData = _getTierData();

    return Card(
      elevation: 3,
      shadowColor: tierData['color'].withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.w),
      ),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.white,
              tierData['color'].withOpacity(0.1),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12.w),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: tierData['color'].withOpacity(0.15),
                borderRadius: BorderRadius.circular(10.w),
              ),
              child: Icon(
                customIcon ?? tierData['icon'],
                color: tierData['color'],
                size: 32.w,
              ),
            ),
            SizedBox(width: 12.w),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Current Tier',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.black54,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Row(
                  children: [
                    Icon(
                      tierData['smallIcon'],
                      color: tierData['color'],
                      size: 18.w,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      tier,
                      style: TextStyle(
                        fontSize: 22.sp,
                        fontWeight: FontWeight.bold,
                        color: tierData['color'],
                      ),
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

  Map<String, dynamic> _getTierData() {
    final tierLower = tier.toLowerCase();
    
    if (customColor != null) {
      return {
        'color': customColor!,
        'icon': customIcon ?? Icons.workspace_premium,
        'smallIcon': Icons.star,
      };
    }

    switch (tierLower) {
      case 'bronze':
        return {
          'color': Color(0xFFCD7F32),
          'icon': Icons.military_tech,
          'smallIcon': Icons.shield,
        };
      case 'silver':
        return {
          'color': Color(0xFFC0C0C0),
          'icon': Icons.workspace_premium,
          'smallIcon': Icons.diamond,
        };
      case 'gold':
        return {
          'color': Color(0xFFFFD700),
          'icon': Icons.emoji_events,
          'smallIcon': Icons.auto_awesome,
        };
      case 'platinum':
        return {
          'color': Color(0xFFE5E4E2),
          'icon': Icons.workspace_premium_outlined,
          'smallIcon': Icons.star,
        };
      case 'diamond':
        return {
          'color': Color(0xFFB9F2FF),
          'icon': Icons.diamond_outlined,
          'smallIcon': Icons.auto_awesome,
        };
      default:
        return {
          'color': Colors.grey,
          'icon': Icons.card_membership,
          'smallIcon': Icons.star,
        };
    }
  }
}