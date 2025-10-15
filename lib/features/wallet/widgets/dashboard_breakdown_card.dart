// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A clean, minimal white card design for rider delivery dashboard
class WalletDashboardCard extends StatelessWidget {
  const WalletDashboardCard({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_DashboardItem>[
      _DashboardItem(
        label: 'Base Salary',
        amount: '₹5,000',
        icon: Icons.account_balance_wallet_rounded,
        color: const Color(0xFF605BFF),
      ),
      _DashboardItem(
        label: 'Fuel Allowance',
        amount: '₹2,000',
        icon: Icons.local_gas_station_rounded,
        color: const Color(0xFF00C6AE),
      ),
      _DashboardItem(
        label: 'Delivery Earnings',
        amount: '₹12,500',
        subtitle: '500 deliveries × ₹25 avg',
        icon: Icons.delivery_dining_rounded,
        color: const Color(0xFFFF8A5B),
      ),
      _DashboardItem(
        label: 'Daily Bonuses',
        amount: '₹2,400',
        icon: Icons.bolt_rounded,
        color: const Color(0xFFFFBF5F),
      ),
      _DashboardItem(
        label: 'Weekly Bonuses',
        amount: '₹1,600',
        icon: Icons.emoji_events_rounded,
        color: const Color(0xFFAE6FFF),
      ),
      _DashboardItem(
        label: 'Total Monthly',
        amount: '₹23,500',
        icon: Icons.trending_up_rounded,
        color: const Color(0xFF16C784),
        isTotal: true,
      ),
    ];

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
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
          Text(
            'Earnings Dashboard',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Column(
            children: [
              for (var i = 0; i < items.length; i += 2)
                Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: IntrinsicHeight(
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Expanded(child: _DashboardTile(item: items[i])),
                        SizedBox(width: 12.w),
                        if (i + 1 < items.length)
                          Expanded(child: _DashboardTile(item: items[i + 1]))
                        else
                          const Expanded(child: SizedBox()),
                      ],
                    ),
                  ),
                ),
            ],
          )
        ],
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  const _DashboardTile({required this.item});

  final _DashboardItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      // margin: EdgeInsets.only(bottom: 12.h), // Removed for IntrinsicHeight
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        // border: item.isTotal
        //     ? Border.all(color: item.color.withOpacity(0.3), width: 1.5)
        //     : null,
      ),
      child: Row(
        children: [
          Container(
            height: 40.w,
            width: 40.w,
            decoration: BoxDecoration(
              color: item.color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(item.icon, color: item.color, size: 22.w),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center, // Center content vertically
              children: [
                Text(
                  item.label,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.black54,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  item.amount,
                  style: TextStyle(
                    fontSize: item.isTotal ? 18.sp : 16.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                if (item.subtitle != null)
                  Padding(
                    padding: EdgeInsets.only(top: 2.h),
                    child: Text(
                      item.subtitle!,
                      style: TextStyle(fontSize: 10.sp, color: Colors.black45),
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

class _DashboardItem {
  const _DashboardItem({
    required this.label,
    required this.amount,
    required this.icon,
    required this.color,
    this.subtitle,
    this.isTotal = false,
  });

  final String label;
  final String amount;
  final String? subtitle;
  final IconData icon;
  final Color color;
  final bool isTotal;
}
