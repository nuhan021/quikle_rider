import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/services/network/internet_services.dart';
import 'package:quikle_rider/core/widgets/connection_lost.dart';
import 'package:quikle_rider/custom_tab_bar/notifications.dart';
import 'package:quikle_rider/features/all_orders/controllers/all_order_controller.dart';
import 'package:quikle_rider/features/all_orders/presentation/screen/all_order_single.dart';
import 'package:quikle_rider/features/home/controllers/homepage_controller.dart';
import 'all_orders_combined.dart';

class AllOrders extends StatefulWidget {
  const AllOrders({super.key});

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders>
    with SingleTickerProviderStateMixin {
  final AllOrdersController controller = Get.put(AllOrdersController());
  final HomepageController homepageController = Get.find();
  

  @override
  void initState() {
    super.initState();
    final tabController = TabController(length: 2, vsync: this);
    controller.attachTabController(tabController);
    controller.tabController?.addListener(() {
      final currentTabController = controller.tabController;
      if (currentTabController == null) return;
      if (!currentTabController.indexIsChanging) {
        controller.selectedIndex.value = currentTabController.index;
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Obx(
      () => SafeArea(
        child: Scaffold(
          backgroundColor: const Color(0xFFF5F5F5),
          appBar: UnifiedProfileAppBar(
            isback: false,
            showActionButton: true,
            title: "All Oders",
            action: "Notification",
            onActionPressed: () {
              Get.to(NotificationsPage());

            },
          ),
          body: homepageController.hasConnection.value
              ? Padding(
                  padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
                  child: Column(
                    children: [
                      Container(
                        height: 36.h,
                        child: TabBar(
                          dividerColor: Colors.transparent,
                          indicatorSize: TabBarIndicatorSize.tab,
                          controller: controller.tabController,
                          indicator: BoxDecoration(
                            borderRadius: BorderRadius.circular(6.r),
                            color: Colors.black,
                          ),
                          labelColor: Colors.white,
                          unselectedLabelColor: Colors.black,
                          labelStyle: getTextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          unselectedLabelStyle: getTextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                          tabs: const [
                            Tab(text: 'Combined'),
                            Tab(text: 'Single'),
                          ],
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Expanded(
                        child: TabBarView(
                          controller: controller.tabController,
                          children: const [
                            AllOrdersCombined(),
                            AllOrdersSingle(),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              : const ConnectionLost(),
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.tabController?.dispose();
    super.dispose();
  }
}
