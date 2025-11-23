import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/features/wallet/models/wallet_summary.dart';
import 'package:quikle_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:quikle_rider/features/wallet/widgets/balance_card.dart';
import 'package:quikle_rider/features/wallet/widgets/bonus_tracking.dart';
import 'package:quikle_rider/features/wallet/widgets/dashboard_breakdown_card.dart';
import 'package:quikle_rider/features/wallet/widgets/delevery_card.dart';
import 'package:quikle_rider/features/wallet/widgets/monthly_earnings_forecast_card.dart';
import 'package:quikle_rider/features/wallet/widgets/rating_card.dart';
import 'package:quikle_rider/features/wallet/widgets/start_tile.dart';
import 'package:quikle_rider/features/wallet/widgets/tier_card.dart';
import 'package:quikle_rider/features/wallet/widgets/wallet_shimmer_list.dart';

class WalletScreen extends GetView<WalletController> {
  const WalletScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cardBox = BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      boxShadow: [
        BoxShadow(
          color: const Color(0x14000000),
          blurRadius: 10,
          offset: const Offset(0, 2),
        ),
      ],
    );

    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: UnifiedProfileAppBar(isback: false, title: "Wallet"),

        body: Column(
          children: [
            // Segmented period selector
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              child: Container(
                height: 36.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFF0F0F0),
                  borderRadius: BorderRadius.circular(22.r),
                ),
                child: TabBar(
                  dividerColor: Colors.transparent,

                  indicatorSize: TabBarIndicatorSize.tab,
                  controller: controller.tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFFFFD32A),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  indicatorPadding: EdgeInsets.all(4.r),
                  labelColor: Colors.black,
                  unselectedLabelColor: const Color(0x99000000),
                  labelStyle: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: getTextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  tabs: const [
                    Tab(text: 'Week'),
                    Tab(text: 'Month'),
                    Tab(text: 'Year'),
                  ],
                ),
              ),
            ),

            // Scroll content
            Expanded(
              child: Obx(() {
                final isLoading = controller.isWalletLoading.value;
                final errorMessage = controller.walletError.value;

                if (isLoading && controller.walletSummary.value == null) {
                  return const WalletShimmerList();
                }

                return RefreshIndicator(
                  onRefresh: () => controller.refreshCurrentPeriod(),
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    children: [
                      if (isLoading)
                        Padding(
                          padding: EdgeInsets.only(top: 8.h, bottom: 12.h),
                          child: const LinearProgressIndicator(minHeight: 4),
                        ),
                      if (errorMessage != null && controller.walletSummary.value != null)
                        Padding(
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Container(
                            padding: EdgeInsets.all(12.w),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3F0),
                              borderRadius: BorderRadius.circular(12.r),
                              border: Border.all(
                                color: const Color(0xFFFFC9BF),
                              ),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Icon(
                                  Icons.error_outline,
                                  color: Color(0xFFB3261E),
                                ),
                                SizedBox(width: 8.w),
                                Expanded(
                                  child: Text(
                                    errorMessage,
                                    style: TextStyle(
                                      color: const Color(0xFFB3261E),
                                      fontSize: 13.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () =>
                                      controller.refreshCurrentPeriod(),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        ),
                      MonthlyEarningsForecastCard(
                        title: 'Monthly Earnings Forecast',
                        projectedAmount: controller.forecastProjectedAmountText,
                        basisNote: controller.forecastBasisNoteText,
                        goals: const [
                          'Complete 5 more deliveries this week',
                          'Maintain 4.5+ rating',
                        ],
                        onViewDetails: null,
                        currentAmount: controller.forecastCurrentValue,
                        targetAmount: controller.forecastTargetValue,
                      ),
                      SizedBox(height: 12.h),
                      BalanceCard(
                        balance: controller.finalEarningsText,
                        lastUpdated: controller.balanceSubtitle,
                        onWithdraw: () async {},
                      ),
                      SizedBox(height: 12.h),
                      const WalletDashboardCard(),
                      SizedBox(height: 12.h),
                      BonusTracking(
                        performance: controller.performanceData,
                        leaderboard: controller.leaderboardData,
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              title: 'Total Deliveries',
                              value: controller.totalDeliveriesText,
                              box: cardBox,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: StatTile(
                              title: 'Delivery Pay',
                              value: controller.deliveryPayText,
                              box: cardBox,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              title: 'Weekly Bonuses',
                              value: controller.weeklyBonusText,
                              box: cardBox,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: StatTile(
                              title: 'Excellence Bonus',
                              value: controller.excellenceBonusText,
                              box: cardBox,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              title: 'Subtotal',
                              value: controller.subtotalText,
                              box: cardBox,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: StatTile(
                              title: 'Top Up',
                              value: controller.topUpText,
                              box: cardBox,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              title: 'Final Earnings',
                              value: controller.finalEarningsStatText,
                              box: cardBox,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: StatTile(
                              title: 'Forecast Progress',
                              value: controller.forecastProgressText,
                              box: cardBox,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              title: 'Bonus Deliveries',
                              value: controller.bonusDeliveriesText,
                              box: cardBox,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: StatTile(
                              title: 'Acceptance Rate %',
                              value: controller.bonusAcceptanceText,
                              box: cardBox,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              title: 'On-Time Delivery %',
                              value: controller.bonusOnTimeText,
                              box: cardBox,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: StatTile(
                              title: 'Avg. Delivery Time',
                              value: controller.avgDeliveryTime.value,
                              box: cardBox,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: StatTile(
                              title: 'Customer Rating',
                              value: controller.customerRating.value,
                              box: cardBox,
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: StatTile(
                              title: 'Completion Rate',
                              value: controller.completionRate.value,
                              box: cardBox,
                            ),
                          ),
                        ],
                      ),
                      if (controller.weeklyStatuses.isNotEmpty) ...[
                        SizedBox(height: 16.h),
                        _WeeklyStatuses(
                          statuses: controller.weeklyStatuses,
                          box: cardBox,
                        ),
                      ],
                      SizedBox(height: 16.h),
                      Text(
                        'Customer Ratings',
                        style: headingStyle2(color: Colors.black),
                      ),
                      RatingCard(
                        rating: 4.5,
                        totalRatings: '5.2K Ratings',
                        reviewCount: 18,
                      ),
                      TierCard(benefits: '₹16,000-18,500/month'),
                      Padding(
                        padding: EdgeInsets.only(
                          left: 4.w,
                          bottom: 8.h,
                          top: 8.h,
                        ),
                        child: Text(
                          'Past Deliveries',
                          style: headingStyle2(color: Colors.black),
                        ),
                      ),
                      ListView.builder(
                        itemCount: controller.deliveries.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final d = controller.deliveries[index];
                          return DeliveryCard(
                            box: cardBox,
                            orderId: d.id,
                            status: d.status,
                            amount: d.amount,
                            customerName: d.customer,
                            dateTime: d.dateTime,
                            distance: d.distance,
                            rightSubline: d.rightSubline,
                            bottomNote: d.bottomNote,
                          );
                        },
                      ),
                      SizedBox(height: 24.h),
                    ],
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyStatuses extends StatelessWidget {
  const _WeeklyStatuses({required this.statuses, required this.box});

  final List<WeeklyStatus> statuses;
  final BoxDecoration box;

  @override
  Widget build(BuildContext context) {
    if (statuses.isEmpty) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: box,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Weekly Bonus Status',
            style: headingStyle2(color: Colors.black),
          ),
          SizedBox(height: 12.h),
          ...statuses.map(
            (status) => Padding(
              padding: EdgeInsets.symmetric(vertical: 6.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE8A3),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      'Week ${status.week}',
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF8C6B00),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          status.status,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          'Bonus: ${_formatBonus(status.bonus)}',
                          style: TextStyle(
                            fontSize: 12.sp,
                            color: Colors.black54,
                          ),
                        ),
                      ],
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

  String _formatBonus(double bonus) {
    final hasFraction = bonus % 1 != 0;
    final formatted = hasFraction
        ? bonus.toStringAsFixed(2)
        : bonus.toStringAsFixed(0);
    return '₹$formatted';
  }
}
