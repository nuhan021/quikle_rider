import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/custom_tab_bar/custom_tab_bar.dart';
import 'package:quikle_rider/features/wallet/controllers/wallet_controller.dart';
import 'package:quikle_rider/features/wallet/widgets/delevery_card.dart';
import 'package:quikle_rider/features/wallet/widgets/start_tile.dart';

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
        backgroundColor: Colors.white ,
        appBar: UnifiedProfileAppBar(title: "Wallet",),
      
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
                 
                  indicatorSize: TabBarIndicatorSize.tab  ,
                  controller: controller.tabController,
                  indicator: BoxDecoration(
                    color: const Color(0xFFFFD32A),
                    borderRadius: BorderRadius.circular(18.r),
                  ),
                  indicatorPadding: EdgeInsets.all(4.r),
                  labelColor: Colors.black,
                  unselectedLabelColor: const Color(0x99000000),
                  labelStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontFamily: 'Manrope',
                    fontSize: 13.sp,
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
                    // Current Balance Card
                    Container(
                      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                      decoration: cardBox,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            'Current Balance',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13.sp,
                              color: Colors.grey[600],
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          SizedBox(height: 8.h),
                          Text(
                            controller.currentBalance.value,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 36.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.black,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            'Last updated: Today, 9:15 AM',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.sp,
                              color: Colors.grey[500],
                            ),
                          ),
                          SizedBox(height: 12.h),
                          SizedBox(
                            width: 124.w,
                            height: 36.h,
                            child: ElevatedButton(
                              onPressed: () {},
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8.r),
                                ),
                                elevation: 0,
                                padding: EdgeInsets.zero,
                              ),
                              child: Text(
                                'Withdraw',
                                style: TextStyle(
                                  fontFamily: 'Manrope',
                                  color: Colors.white,
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
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
      
                    // Past Deliveries header
                    Padding(
                      padding: EdgeInsets.only(left: 4.w, bottom: 8.h, top: 8.h),
                      child: Text(
                        'Past Deliveries',
                        style: TextStyle(
                          fontFamily: 'Obviously',
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
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
