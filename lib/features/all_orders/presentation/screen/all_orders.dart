import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/custom_tab_bar/custom_tab_bar.dart';
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
  int _selectedIndex = 0; // State to track the selected tab

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // Add a listener to update the state when the tab view changes
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedIndex = _tabController.index;
        });
      }
    });
  }

  void _handleToggle() {
    setState(() {
      _isOnline = !_isOnline; // Toggle the state
    });
  }

  void _onTabTapped(int index) {
    _tabController.animateTo(index);
    setState(() {
      _selectedIndex = index;
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
      body: Padding(
        padding: EdgeInsets.only(top: 16.h, left: 16.w, right: 16.w),
        child: Column(
          children: [
            // This section creates the two custom "tabs"
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Combined Tab Box
                GestureDetector(
                  onTap: () => _onTabTapped(0),
                  child: Container(
                    width: 170.w,
                    height: 36.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedIndex == 0 ? Colors.black : Colors.white,
                      border: Border.all(color: Colors.black, width: 1.w),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Combined',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: _selectedIndex == 0
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w), // Space between the boxes
                // Single Tab Box
                GestureDetector(
                  onTap: () => _onTabTapped(1),
                  child: Container(
                    width: 170.w,
                    height: 36.h,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: _selectedIndex == 1 ? Colors.black : Colors.white,
                      border: Border.all(color: Colors.black, width: 1.w),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      'Single',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: _selectedIndex == 1
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // Add a little space before the TabBarView
            SizedBox(height: 16.h),
            // This is the TabBarView which will take the rest of the space
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: const [AllOrdersCombined(), AllOrdersSingle()],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _tabController.removeListener(() {}); // Remove the listener
    _tabController.dispose();
    super.dispose();
  }
}
