import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/features/profile/presentation/screen/add_paymentmethod.dart';
import 'package:quikle_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:quikle_rider/features/wallet/widgets/balance_card.dart';
import 'package:quikle_rider/features/wallet/widgets/bonus_progress_card.dart';
import 'package:quikle_rider/features/wallet/widgets/delevery_card.dart';
import 'package:quikle_rider/features/wallet/widgets/monthly_earnings_forecast_card.dart';
import 'package:quikle_rider/features/wallet/widgets/rating_card.dart';
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
                    Tab(text: 'All'),
                    Tab(text: 'Week'),
                    Tab(text: 'Month'),
                    Tab(text: 'Year'),
                  ],
                  onTap: (index) {
                    switch (index) {
                      case 0:
                        controller.fetchAllStats();
                        controller.fetchBonusProgress();
                        break;
                      case 1:
                        controller.fetchWeeklyStats();
                        break;
                      case 2:
                        controller.fetchMonthlyStats();
                        break;
                      case 3:
                        controller.fetchAnnualStats();
                        break;
                    }
                  },
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
                        currentBalanceText:
                            "${controller.formatCurrency(controller.currentBalance.value)}",
                        onViewDetails: null,
                        currentAmount: controller.forecastCurrentValue,
                        targetAmount: controller.forecastTargetValue,
                      ),
                      SizedBox(height: 12.h),
                      Obx(
                        ()=> BalanceCard(
                          balance: "₹${controller.currentBalance.value.toString()}",
                          lastUpdated: controller.balanceSubtitle,
                          onWithdraw: () async {
              
                            Get.to(AddPaymentMethodPage());
                          },
                        ),
                      ),
                      SizedBox(height: 12.h),
                      // Display stats based on selected tab
                      GetBuilder<WalletController>(
                        builder: (ctrl) {
                          if (ctrl.tabController.index == 0) {
                            return _buildAllStatsSection(ctrl);
                          } else if (ctrl.tabController.index == 1) {
                            return _buildWeeklyStatsSection(ctrl);
                          } else if (ctrl.tabController.index == 2) {
                            return _buildMonthlyStatsSection(ctrl);
                          } else if (ctrl.tabController.index == 3) {
                            return _buildAnnualStatsSection(ctrl);
                          }
                          return const SizedBox.shrink();
                        },
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'Customer Ratings',
                        style: headingStyle2(color: Colors.black),
                      ),
                      Obx(() {
                        if (controller.isRatingLoading.value) {
                          return Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: const LinearProgressIndicator(minHeight: 3),
                          );
                        } else {
                          // Use rating from allStats if available, otherwise use riderRating
                          final allStats = controller.allStats.value ?? {};
                          final rating = (allStats['customer_rating'] ?? 0.0) as num;
                          final ratingValue = rating.toDouble();
                          final finalRating = ratingValue > 0 ? ratingValue : (controller.riderRating.value ?? 0.0);
                          final reviewCount = controller.riderReviewCount.value ?? 0;
                          
                          if (finalRating == 0 && reviewCount == 0 && controller.ratingError.value != null) {
                            return Padding(
                              padding: EdgeInsets.only(bottom: 8.h),
                              child: Text(
                                'No ratings yet',
                                style: TextStyle(
                                  color: Colors.grey[600],
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            );
                          }
                          
                          return RatingCard(
                            rating: finalRating,
                            totalRatings: reviewCount > 0 ? (reviewCount == 1 ? '1 Rating' : '$reviewCount Ratings') : '0 Ratings',
                            reviewCount: reviewCount,
                          );
                        }
                      }),
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
    ));
    
    }
  }

  /// Build All Stats Section
  Widget _buildAllStatsSection(WalletController ctrl) {
    return Obx(() {
      if (ctrl.isAllStatsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (ctrl.allStatsError.value != null && ctrl.allStatsError.value!.isNotEmpty) {
        return Center(
          child: Text(
            ctrl.allStatsError.value!,
            style: const TextStyle(color: Colors.red),
          ),
        );
      }

      final stats = ctrl.allStats.value ?? {};
      return Column(
        children: [
          // Total Deliveries
          _StatCard(
            title: 'Total Deliveries',
            value: '${stats['total_deliveries'] ?? 0}',
            icon: Icons.shopping_bag_outlined,
            backgroundColor: const Color(0xFFF0F4FF),
          ),
          SizedBox(height: 12.h),
          
          // Earnings Row
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Today',
                  value: '₹${stats['earnings_today'] ?? 0}',
                  icon: Icons.today,
                  backgroundColor: const Color(0xFFFFF4E6),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  title: 'This Week',
                  value: '₹${stats['earnings_this_week'] ?? 0}',
                  icon: Icons.calendar_today,
                  backgroundColor: const Color(0xFFE6F7FF),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // Monthly Earnings & Balance
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'This Month',
                  value: '₹${stats['earnings_this_month'] ?? 0}',
                  icon: Icons.date_range,
                  backgroundColor: const Color(0xFFE6FFE6),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  title: 'Balance',
                  value: '₹${stats['current_balance'] ?? 0}',
                  icon: Icons.account_balance_wallet,
                  backgroundColor: const Color(0xFFFFE6E6),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // Rating & Acceptance Rate
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Rating',
                  value: '${(stats['customer_rating'] ?? 0).toStringAsFixed(1)}⭐',
                  icon: Icons.star,
                  backgroundColor: const Color(0xFFFFF9E6),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  title: 'Acceptance',
                  value: '${stats['acceptance_rate'] ?? 0}%',
                  icon: Icons.done_all,
                  backgroundColor: const Color(0xFFF0E6FF),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // On-Time Rate & Online Status
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'On-Time',
                  value: '${stats['on_time_rate'] ?? 0}%',
                  icon: Icons.schedule,
                  backgroundColor: const Color(0xFFE6F9FF),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  title: 'Status',
                  value: (stats['is_online'] ?? false) ? 'Online' : 'Offline',
                  icon: (stats['is_online'] ?? false) ? Icons.cloud_done : Icons.cloud_off,
                  backgroundColor: (stats['is_online'] ?? false) ? const Color(0xFFE6FFE6) : const Color(0xFFFFE6E6),
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          
          // Bonus Progress Section
          BonusProgressCard(controller: ctrl),
        ],
      );
    });
  }

  /// Build Weekly Stats Section
  Widget _buildWeeklyStatsSection(WalletController ctrl) {
    return Obx(() {
      if (ctrl.isWeeklyStatsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (ctrl.weeklyStatsError.value != null && ctrl.weeklyStatsError.value!.isNotEmpty) {
        return Center(
          child: Text(
            ctrl.weeklyStatsError.value!,
            style: const TextStyle(color: Colors.red),
          ),
        );
      }

      final stats = ctrl.weeklyStats.value ?? {};
      return Column(
        children: [
          // Week Number
          _StatCard(
            title: 'Week Number',
            value: 'Week ${stats['week_number'] ?? 0}',
            icon: Icons.calendar_month,
            backgroundColor: const Color(0xFFF0F4FF),
          ),
          SizedBox(height: 12.h),
          
          // Days & Hours Worked
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Days Worked',
                  value: '${stats['days_worked'] ?? 0}',
                  icon: Icons.work,
                  backgroundColor: const Color(0xFFFFF4E6),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  title: 'Hours Worked',
                  value: '${stats['hours_worked'] ?? 0}h',
                  icon: Icons.timer,
                  backgroundColor: const Color(0xFFE6F7FF),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // Deliveries & Delivery Pay
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Deliveries',
                  value: '${stats['deliveries'] ?? 0}',
                  icon: Icons.local_shipping,
                  backgroundColor: const Color(0xFFE6FFE6),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  title: 'Delivery Pay',
                  value: '₹${stats['delivery_pay'] ?? 0}',
                  icon: Icons.payment,
                  backgroundColor: const Color(0xFFFFE6E6),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // Bonus Status
          _StatCard(
            title: 'Weekly Bonus Status',
            value: '${stats['weekly_bonus_status'] ?? 'N/A'}',
            icon: Icons.card_giftcard,
            backgroundColor: const Color(0xFFFFF9E6),
          ),
          SizedBox(height: 12.h),
          
          // Current Balance (from All Stats)
          _StatCard(
            title: 'Current Balance',
            value: '₹${ctrl.allStats.value?['current_balance'] ?? 0}',
            icon: Icons.account_balance_wallet,
            backgroundColor: const Color(0xFFE6FFE6),
          ),
        ],
      );
    });
  }

  /// Build Monthly Stats Section
  Widget _buildMonthlyStatsSection(WalletController ctrl) {
    return Obx(() {
      if (ctrl.isMonthlyStatsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (ctrl.monthlyStatsError.value != null && ctrl.monthlyStatsError.value!.isNotEmpty) {
        return Center(
          child: Text(
            ctrl.monthlyStatsError.value!,
            style: const TextStyle(color: Colors.red),
          ),
        );
      }

      final stats = ctrl.monthlyStats.value ?? {};
      return Column(
        children: [
          // Delivery Pay & Weekly Bonuses
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Delivery Pay',
                  value: '₹${stats['delivery_pay'] ?? 0}',
                  icon: Icons.payment,
                  backgroundColor: const Color(0xFFF0F4FF),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  title: 'Weekly Bonuses',
                  value: '₹${stats['weekly_bonuses'] ?? 0}',
                  icon: Icons.card_giftcard,
                  backgroundColor: const Color(0xFFFFF4E6),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // Excellence Bonus & Guarantee Topup
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Excellence Bonus',
                  value: '₹${stats['excellence_bonus'] ?? 0}',
                  icon: Icons.emoji_events,
                  backgroundColor: const Color(0xFFE6F7FF),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  title: 'Guarantee Topup',
                  value: '₹${stats['guarantee_topup'] ?? 0}',
                  icon: Icons.verified_user,
                  backgroundColor: const Color(0xFFE6FFE6),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // Subtotal & Final Earnings
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Subtotal Earned',
                  value: '₹${stats['subtotal_earned'] ?? 0}',
                  icon: Icons.calculate,
                  backgroundColor: const Color(0xFFFFE6E6),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  title: 'Final Earnings',
                  value: '₹${stats['final_earnings'] ?? 0}',
                  icon: Icons.trending_up,
                  backgroundColor: const Color(0xFFFFF9E6),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // Current Balance (from All Stats)
          _StatCard(
            title: 'Current Balance',
            value: '₹${ctrl.allStats.value?['current_balance'] ?? 0}',
            icon: Icons.account_balance_wallet,
            backgroundColor: const Color(0xFFE6FFE6),
          ),
        ],
      );
    });
  }

  /// Build Annual Stats Section
  Widget _buildAnnualStatsSection(WalletController ctrl) {
    return Obx(() {
      if (ctrl.isAnnualStatsLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      
      if (ctrl.annualStatsError.value != null && ctrl.annualStatsError.value!.isNotEmpty) {
        return Center(
          child: Text(
            ctrl.annualStatsError.value!,
            style: const TextStyle(color: Colors.red),
          ),
        );
      }

      final stats = ctrl.annualStats.value ?? {};
      return Column(
        children: [
          // Total Deliveries & Total Earnings
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Total Deliveries',
                  value: '${stats['total_deliveries'] ?? 0}',
                  icon: Icons.shopping_bag_outlined,
                  backgroundColor: const Color(0xFFF0F4FF),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  title: 'Total Earnings',
                  value: '₹${stats['total_earnings'] ?? 0}',
                  icon: Icons.trending_up,
                  backgroundColor: const Color(0xFFFFF4E6),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // Average Monthly & Best Month
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  title: 'Average Monthly',
                  value: '₹${stats['average_monthly'] ?? 0}',
                  icon: Icons.bar_chart,
                  backgroundColor: const Color(0xFFE6F7FF),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _StatCard(
                  title: 'Best Month',
                  value: '${(stats['best_month'] as Map?)?['month'] ?? 'N/A'}',
                  icon: Icons.star,
                  backgroundColor: const Color(0xFFFFF9E6),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          
          // Current Balance (from All Stats)
          _StatCard(
            title: 'Current Balance',
            value: '₹${ctrl.allStats.value?['current_balance'] ?? 0}',
            icon: Icons.account_balance_wallet,
            backgroundColor: const Color(0xFFE6FFE6),
          ),
        ],
      );
    });
  }



/// Simple stat card widget
class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color? backgroundColor;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color:  Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0x14000000),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[600],
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Icon(icon, size: 16.w, color: Colors.grey[400]),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
