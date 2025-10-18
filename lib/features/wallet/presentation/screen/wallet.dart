import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:quikle_rider/features/wallet/widgets/balance_card.dart';
import 'package:quikle_rider/features/wallet/widgets/bonus_tracking.dart';
import 'package:quikle_rider/features/wallet/widgets/dashboard_breakdown_card.dart';
import 'package:quikle_rider/features/wallet/widgets/delevery_card.dart';
import 'package:quikle_rider/features/wallet/widgets/monthly_earnings_forecast_card.dart';
import 'package:quikle_rider/features/wallet/widgets/rating_card.dart';
import 'package:quikle_rider/features/wallet/widgets/start_tile.dart';
import 'package:quikle_rider/features/wallet/widgets/tier_card.dart';

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
        appBar: UnifiedProfileAppBar(title: "Wallet"),

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
                    Tab(text: 'All'),
                    Tab(text: 'Week'),
                    Tab(text: 'Month'),
                    Tab(text: 'Year'),
                  ],
                ),
              ),
            ),

            // Scroll content
            Expanded(
              child: Obx(
                () => ListView(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  children: [
                    const MonthlyEarningsForecastCard(
                      title: 'Monthly Earnings Forecast',
                      projectedAmount: 'On track for: ₹24,000',
                      basisNote: '(Based on current pace)',
                      goals: [
                        'Complete 5 more deliveries this week',
                        'Maintain 4.5+ rating',
                      ],
                      onViewDetails: null,
                    ),
                    SizedBox(height: 12.h),
                    // Current Balance Card
                    BalanceCard(
                      balance: controller.currentBalance.value,
                      lastUpdated: controller.avgDeliveryTime.value,
                      onWithdraw: () async {},
                    ),
                    SizedBox(height: 12.h),
                    const WalletDashboardCard(),
                    SizedBox(height: 12.h),
                    BonusTracking(),
                    SizedBox(height: 12.h),

                    // Stats grid (2 x 2)
                    Row(
                      children: [
                        Expanded(
                          child: StatTile(
                            title: 'Total Deliveries',
                            value: controller.totalDeliveries.value,
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
                            title: 'Orders Accepted',
                            value: controller.totalDeliveries.value,
                            box: cardBox,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: StatTile(
                            title: 'Orders Rejected',
                            value: controller.totalDeliveries.value,
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
                    SizedBox(height: 16.h),
                    Row(
                      children: [
                        Expanded(
                          child: StatTile(
                            title: 'Acceptance Rate %',
                            value: "${controller.totalDeliveries.value}%",
                            box: cardBox,
                          ),
                        ),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: StatTile(
                            title: 'On-Time Delivery %',
                            value: "${controller.avgDeliveryTime.value}%",
                            box: cardBox,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    Expanded(
                      child: StatTile(
                        title: 'Total Orders',
                        value: controller.totalDeliveries.value,
                        box: cardBox,
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Text(
                      'Customer Ratings',
                      style: headingStyle2(color: Colors.black),
                    ),
                    // Custom Rating Icons Card
                    RatingCard(
                      rating: 4.5,
                      totalRatings: '5.2K Ratings',
                      reviewCount: 18,
                    ),
                    // Bronze Tier
                    //current Tier Card
                    TierCard(benefits: '₹16,000-18,500/month'),
                    // Past Deliveries header
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
                      shrinkWrap: true, // important for nested list
                      physics:
                          const NeverScrollableScrollPhysics(), // use parent ListView's scroll
                      itemBuilder: (context, index) {
                        final d = controller.deliveries[index];
                        return DeliveryCard(
                          box: cardBox, // pass decoration via `box`
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
