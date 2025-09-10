import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/custom_tab_bar/custom_tab_bar.dart';// Adjust the import path

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'All';
  bool _isOnline = true; // State for toggle switch

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _toggleOnlineStatus() {
    setState(() {
      _isOnline = !_isOnline;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Initialize ScreenUtil if not already done in your app
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomTabBar(
        title: 'Wallet',
        isOnline: _isOnline,
        onToggle: _toggleOnlineStatus,
        currentIndex: 3, // Assuming WalletScreen is the second tab
      ),
      body: Column(
        children: [
          // Time Period Selector
          Container(
            padding: EdgeInsets.symmetric(horizontal: 20.w),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(25.r),
              ),
              child: Row(
                children: ['All', 'Week', 'Month', 'Year'].map((period) {
                  bool isSelected = selectedPeriod == period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          selectedPeriod = period;
                        });
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 8.h),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.yellow[600]
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Text(
                          period,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black54,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.normal,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          SizedBox(height: 25.h),

          // Current Balance Card
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            padding: EdgeInsets.all(25.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                Text(
                  'Current Balance',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  '\$459',
                  style: TextStyle(
                    fontSize: 36.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 5.h),
                Text(
                  'Last updated: Today, 9:15 AM',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[500]),
                ),
                SizedBox(height: 20.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black87,
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Withdraw',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 25.h),

          // Stats Row
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(child: _buildStatCard('Total Deliveries', '42')),
                SizedBox(width: 15.w),
                Expanded(child: _buildStatCard('Avg. Delivery Time', '18 min')),
              ],
            ),
          ),
          SizedBox(height: 15.h),
          Container(
            margin: EdgeInsets.symmetric(horizontal: 20.w),
            child: Row(
              children: [
                Expanded(child: _buildStatCard('Customer Rating', '4.8')),
                SizedBox(width: 15.w),
                Expanded(child: _buildStatCard('Completion Rate', '98%')),
              ],
            ),
          ),
          SizedBox(height: 25.h),

          // Past Deliveries Section
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Past Deliveries',
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 15.h),
                  Expanded(
                    child: ListView(
                      children: [
                        _buildDeliveryItem(
                          '#5679',
                          'Delivered',
                          '\$12.50',
                          'Aanya Desai',
                          '20 Jul, 3:45 PM',
                          '1.5 miles',
                          '+\$3.00 tip',
                          Colors.green,
                        ),
                        _buildDeliveryItem(
                          '#5678',
                          'Cancelled',
                          '\$9.50',
                          'Aanya Desai',
                          '20 Jul, 3:45 PM',
                          null,
                          'Customer Cancelled',
                          Colors.red,
                        ),
                        _buildDeliveryItem(
                          '#5677',
                          'Delivered',
                          '\$10.50',
                          'Aanya Desai',
                          '20 Jul, 3:45 PM',
                          '1.5 miles',
                          '+\$2.00 tip',
                          Colors.green,
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

  Widget _buildStatCard(String title, String value) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            value,
            style: TextStyle(
              fontSize: 20.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryItem(
    String orderId,
    String status,
    String amount,
    String customerName,
    String datetime,
    String? distance,
    String subtitle,
    Color statusColor,
  ) {
    return Container(
      margin: EdgeInsets.only(bottom: 15.h),
      padding: EdgeInsets.all(15.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'Order $orderId',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 2.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      status,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: statusColor,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                customerName,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.black87,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: status == 'Delivered'
                      ? Colors.green[600]
                      : Colors.red[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Delivered on $datetime',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
              GestureDetector(
                onTap: () {},
                child: Text(
                  'View Details',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          if (distance != null)
            Padding(
              padding: EdgeInsets.only(top: 5.h),
              child: Row(
                children: [
                  Icon(Icons.location_on, size: 12.sp, color: Colors.grey[500]),
                  SizedBox(width: 2.w),
                  Text(
                    distance,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
