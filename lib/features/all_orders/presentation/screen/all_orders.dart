import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/custom_tab_bar/custom_tab_bar.dart'; // Import the custom tab bar
import 'package:quikle_rider/features/all_orders/presentation/screen/all_order_single.dart';
import 'all_orders_combined.dart';

class AllOrders extends StatefulWidget {
  const AllOrders({super.key});

  @override
  State<AllOrders> createState() => _AllOrdersState();
}

class _AllOrdersState extends State<AllOrders>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isOnline = true; // Add state for the toggle switch

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  void _handleToggle() {
    setState(() {
      _isOnline = !_isOnline; // Toggle the state
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTabBar(
        currentIndex: 1,
        title: 'Orders',
        isOnline: _isOnline,
        onToggle: _handleToggle,
      ),
      body: Column(
        children: [
          // This section is for the TabBar
          Container(
            margin: EdgeInsets.symmetric(horizontal: 16.w),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(25.r),
            ),
            child: TabBar(
              controller: _tabController,
              indicator: BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.circular(25.r),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelColor: Colors.white,
              unselectedLabelColor: Colors.grey[600],
              labelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.w500,
              ),
              tabs: const [
                Tab(text: 'Combined'),
                Tab(text: 'Single'),
              ],
            ),
          ),
          // This is the TabBarView which will take the rest of the space
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [AllOrdersCombined(), AllOrdersSingle()],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
}
