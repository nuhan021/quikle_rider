// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';

class ReferralProgramPage extends StatelessWidget {
  ReferralProgramPage({super.key});

  final List<_ReferralStat> _stats = const [
    _ReferralStat(value: '5', label: 'Active'),
    _ReferralStat(value: '32', label: 'Pending'),
    _ReferralStat(value: '₹2000', label: 'Out of 5'),
  ];

  final List<Map<String, String>> _referralData = const [
    {'name': 'Rajesh Kumar', 'status': 'Active', 'amount': '₹500'},
    {'name': 'Priya Sharma', 'status': 'Active', 'amount': '₹500'},
    {'name': 'Amit Patel', 'status': 'Pending', 'amount': '₹500'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const UnifiedProfileAppBar(title: 'Referral Program'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _highlightCard(context),
            SizedBox(height: 16.h),
            _codeCard(context),
            SizedBox(height: 16.h),
            _statsRow(),
            SizedBox(height: 16.h),
            _referralListCard(),
          ],
        ),
      ),
    );
  }

  Widget _highlightCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earn ₹500 per successful referral!',
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryblack,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Bonus: ₹2,000 for 5 referrals/month',
            style: getTextStyle(
              fontSize: 14,
              color: AppColors.primaryblack.withOpacity(0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeCard(BuildContext context) {
    const referralCode = 'VIKRAM2024';
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Your Referral Code',
            style: getTextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                referralCode,
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primarygreen,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 20),
                onPressed: () async {
                  await Clipboard.setData(
                    const ClipboardData(text: referralCode),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Referral code copied')),
                  );
                },
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: 140.w,
            height: 140.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primaryyellow),
            ),
            alignment: Alignment.center,
            child: Icon(
              Icons.qr_code_rounded,
              size: 90.sp,
              color: Colors.black87,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _shareButton(
                  label: 'WhatsApp',
                  color: AppColors.primarygreen,
                  icon: Iconsax.message_2,
                  onTap: () {},
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _shareButton(
                  label: 'SMS',
                  color: Colors.black,
                  icon: Iconsax.message_2,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _shareButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        side: BorderSide.none,
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 0,
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18.sp),
      label: Text(
        label,
        style: getTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ).copyWith(color: Colors.white),
      ),
    );
  }

  Widget _statsRow() {
    return Row(
      children: _stats
          .map(
            (stat) => Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      stat.value,
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      stat.label,
                      style: getTextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _referralListCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Referral List',
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _referralData.length,
            separatorBuilder: (_, __) => SizedBox(height: 12.h),
            itemBuilder: (_, index) => _referralTile(_referralData[index]),
          ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _shareButton(
                  label: 'WhatsApp',
                  color: AppColors.primarygreen,
                  icon: Iconsax.message,
                  onTap: () {},
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _shareButton(
                  label: 'SMS',
                  color: Colors.black,
                  icon: Icons.sms_outlined,
                  onTap: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _referralTile(Map<String, String> data) {
    final status = data['status'] ?? '';
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data['name'] ?? '',
                  style: getTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    status,
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ).copyWith(color: AppColors.background),
                  ),
                ),
              ],
            ),
          ),
          Text(
            data['amount'] ?? '',
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.primarygreen;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.secondarygrey;
    }
  }
}

class _ReferralStat {
  final String value;
  final String label;

  const _ReferralStat({required this.value, required this.label});
}
