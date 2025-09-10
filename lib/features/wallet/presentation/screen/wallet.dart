// ...existing code...
// ignore_for_file: library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/custom_tab_bar/custom_tab_bar.dart';
import 'package:quikle_rider/features/wallet/widgets/delevery_card.dart';
import 'package:quikle_rider/features/wallet/widgets/start_tile.dart';

class WalletScreen extends StatefulWidget {
  const WalletScreen({super.key});

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'All';
  bool _isOnline = true;

  // changed: simple local model and sample data for past deliveries
  final List<_DeliveryItem> _deliveries = [
    _DeliveryItem(
      id: '1023',
      status: DeliveryStatus.delivered,
      amount: '\$12.50',
      customer: 'John Doe',
      dateTime: 'Sep 8, 2025 10:15 AM',
      distance: '2.1 miles',
      rightSubline: '+\$1.50 tip',
    ),
    _DeliveryItem(
      id: '1022',
      status: DeliveryStatus.cancelled,
      amount: '\$0.00',
      customer: 'Jane Smith',
      dateTime: 'Sep 7, 2025 4:20 PM',
      distance: '—',
      bottomNote: 'Customer cancelled',
    ),
    _DeliveryItem(
      id: '1021',
      status: DeliveryStatus.delivered,
      amount: '\$8.20',
      customer: 'Alice Johnson',
      dateTime: 'Sep 6, 2025 1:05 PM',
      distance: '1.3 miles',
    ),
  ];

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

  void _toggleOnlineStatus() => setState(() => _isOnline = !_isOnline);

  BoxDecoration get _cardBox => BoxDecoration(
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

  @override
  Widget build(BuildContext context) {
    ScreenUtil.init(context, designSize: const Size(375, 812));

    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: CustomTabBar(
        title: 'Wallet',
        isOnline: _isOnline,
        onToggle: _toggleOnlineStatus,
        currentIndex: 3,
      ),
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
              child: Row(
                children: ['All', 'Week', 'Month', 'Year'].map((period) {
                  final isSelected = selectedPeriod == period;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => selectedPeriod = period),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 160),
                        alignment: Alignment.center,
                        margin: EdgeInsets.all(4.r),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? const Color(0xFFFFD32A)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(18.r),
                        ),
                        child: Text(
                          period,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: isSelected
                                ? FontWeight.w600
                                : FontWeight.w500,
                            color: isSelected
                                ? Colors.black
                                : const Color(0x99000000),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // Scroll content
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              children: [
                // Current Balance Card
                Container(
                  padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 16.h),
                  decoration: _cardBox,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Current Balance',
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        '\$459',
                        style: TextStyle(
                          fontSize: 36.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Last updated: Today, 9:15 AM',
                        style: TextStyle(
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
                        value: '42',
                        box: _cardBox,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: StatTile(
                        title: 'Avg. Delivery Time',
                        value: '18 min',
                        box: _cardBox,
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
                        value: '4.8',
                        box: _cardBox,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: StatTile(
                        title: 'Completion Rate',
                        value: '98%',
                        box: _cardBox,
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
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.black,
                    ),
                  ),
                ),

                ListView.builder(
                  itemCount: _deliveries.length,
                  shrinkWrap: true, // important for nested list
                  physics:
                      const NeverScrollableScrollPhysics(), // use parent ListView's scroll
                  itemBuilder: (context, index) {
                    final d = _deliveries[index];
                    return DeliveryCard(
                      box: _cardBox, // pass decoration via `box`
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
        ],
      ),
    );
  }
}

// Simple local model for demo / sample data
class _DeliveryItem {
  final String id;
  final DeliveryStatus status;
  final String amount;
  final String customer;
  final String dateTime;
  final String? distance;
  final String? rightSubline;
  final String? bottomNote;

  const _DeliveryItem({
    required this.id,
    required this.status,
    required this.amount,
    required this.customer,
    required this.dateTime,
    this.distance,
    this.rightSubline,
    this.bottomNote,
  });
}
