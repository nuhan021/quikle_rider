import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';

class PaymentPage extends StatelessWidget {
  const PaymentPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const UnifiedProfileAppBar(
        title: 'Payments',
        isback: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _dueSummaryCard(),
            SizedBox(height: 16.h),
            _paymentMethods(),
            SizedBox(height: 16.h),
            _billBreakdown(),
            SizedBox(height: 16.h),
            _recentTransactions(),
          ],
        ),
      ),
    );
  }

  Widget _dueSummaryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: AppColors.primaryyellow.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Icon(
                  Iconsax.card5,
                  size: 22.sp,
                  color: AppColors.primarygreen,
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Outstanding',
                    style: getTextStyle(
                      fontSize: 14,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  Text(
                    '₹1,240.00',
                    style: headingStyle2(color: AppColors.primaryblack),
                  ),
                ],
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.greencontainer,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'Due in 3 days',
                  style: getTextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primarygreen,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Divider(
            color: AppColors.bordercolor,
            height: 1.h,
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Cycle',
                    style: getTextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  Text(
                    'Mar 01 - Mar 07',
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryblack,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primarygreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding:
                      EdgeInsets.symmetric(horizontal: 18.w, vertical: 12.h),
                  elevation: 0,
                ),
                onPressed: () {},
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Iconsax.wallet_check, size: 18),
                    SizedBox(width: 8.w),
                    Text(
                      'Pay Now',
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _paymentMethods() {
    final methods = [
      _PaymentMethodData(
        title: 'UPI',
        subtitle: 'Pay via any UPI app',
        icon: Iconsax.card_pos,
        accent: AppColors.primarygreen,
        selected: true,
      ),
      _PaymentMethodData(
        title: 'Saved Card',
        subtitle: 'HDFC •••• 3294',
        icon: Iconsax.card,
        accent: AppColors.primaryyellow,
        selected: false,
      ),
      _PaymentMethodData(
        title: 'Add New Method',
        subtitle: 'Cards, Netbanking',
        icon: Iconsax.add,
        accent: AppColors.secondarygrey,
        selected: false,
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Methods',
          style: headingStyle3(color: AppColors.primaryblack),
        ),
        SizedBox(height: 10.h),
        ...methods.map(_methodTile).toList(),
      ],
    );
  }

  Widget _methodTile(_PaymentMethodData method) {
    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: method.selected
              ? AppColors.primarygreen.withOpacity(0.4)
              : AppColors.bordercolor,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: method.accent.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              method.icon,
              color: method.accent,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  method.title,
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryblack,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  method.subtitle,
                  style: getTextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            method.selected ? Iconsax.tick_square : Iconsax.arrow_right_3,
            color: method.selected
                ? AppColors.primarygreen
                : AppColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _billBreakdown() {
    final rows = [
      _BillRow(label: 'Weekly subscription', value: '₹800'),
      _BillRow(label: 'Equipment lease', value: '₹300'),
      _BillRow(label: 'Penalty / Others', value: '₹40'),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Bill Breakdown',
            style: headingStyle3(color: AppColors.primaryblack),
          ),
          SizedBox(height: 12.h),
          ...rows.map(
            (item) => Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      item.label,
                      style: getTextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ),
                  Text(
                    item.value,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.primaryblack,
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Divider(color: AppColors.bordercolor, height: 1.h),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Text(
                  'Total to pay',
                  style: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryblack,
                  ),
                ),
              ),
              Text(
                '₹1,140',
                style: headingStyle3(color: AppColors.primarygreen),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recentTransactions() {
    final txns = [
      _Txn(label: 'Subscription', date: 'Feb 25, 2024', amount: '-₹800'),
      _Txn(label: 'Incentive payout', date: 'Feb 23, 2024', amount: '+₹450'),
      _Txn(label: 'Penalty reversal', date: 'Feb 21, 2024', amount: '+₹50'),
    ];

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Activity',
                style: headingStyle3(color: AppColors.primaryblack),
              ),
              Text(
                'View all',
                style: getTextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primarygreen,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...txns.map(
            (txn) => Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                    decoration: BoxDecoration(
                      color: AppColors.containercolor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      txn.amount.startsWith('-')
                          ? Iconsax.export_1
                          : Iconsax.import_1,
                      color: txn.amount.startsWith('-')
                          ? AppColors.secondaryred
                          : AppColors.primarygreen,
                      size: 18.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          txn.label,
                          style: getTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primaryblack,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          txn.date,
                          style: getTextStyle(
                            fontSize: 12,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    txn.amount,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: txn.amount.startsWith('-')
                          ? AppColors.secondaryred
                          : AppColors.primarygreen,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentMethodData {
  const _PaymentMethodData({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accent,
    this.selected = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final Color accent;
  final bool selected;
}

class _BillRow {
  const _BillRow({required this.label, required this.value});
  final String label;
  final String value;
}

class _Txn {
  const _Txn({
    required this.label,
    required this.date,
    required this.amount,
  });

  final String label;
  final String date;
  final String amount;
}
