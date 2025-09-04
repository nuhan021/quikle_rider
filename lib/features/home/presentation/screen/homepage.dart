import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isOnline = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Text(
          'Home',
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        actions: [
          // Online/Offline Toggle
          Container(
            margin: EdgeInsets.only(right: 16.w),
            child: Row(
              children: [
                Switch(
                  value: isOnline,
                  onChanged: (value) {
                    setState(() {
                      isOnline = value;
                    });
                  },
                  activeColor: const Color(0xFFFFB800),
                  inactiveThumbColor: Colors.grey,
                  inactiveTrackColor: Colors.grey[300],
                ),
                SizedBox(width: 8.w),
                Icon(
                  Icons.notifications_outlined,
                  color: Colors.black,
                  size: 24.sp,
                ),
              ],
            ),
          ),
        ],
      ),
      body: isOnline ? _buildOnlineView() : _buildOfflineView(),
    );
  }

  Widget _buildOfflineView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Go Online To Get\nRequests',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Obviously',
              fontSize: 20.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOnlineView() {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 16.h),

            // Stats Row
            Row(
              children: [
                _buildStatCard('Today', '5', 'Deliveries'),
                SizedBox(width: 12.w),
                _buildStatCard('This Week', '32', 'Deliveries'),
                SizedBox(width: 12.w),
                _buildStatCard('Rating', '4.8', 'Out of 5'),
              ],
            ),

            SizedBox(height: 24.h),

            // Upcoming Assignments
            Text(
              'Upcoming Assignments',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),

            SizedBox(height: 16.h),

            // Assignment Cards
            _buildAssignmentCard(
              orderId: '#5678',
              customerName: 'Aanya Desai',
              arrivalTime: 'Arrives by 4:00 PM',
              address: '456 Oak Ave, Downtown',
              distance: '21 mile',
              total: '\$241.00',
              isUrgent: true,
              isCombined: true,
            ),

            SizedBox(height: 16.h),

            _buildAssignmentCard(
              orderId: '#5679',
              customerName: 'Aanya Desai',
              arrivalTime: 'Arrives by 4:00 PM',
              address: '456 Oak Ave, Downtown',
              distance: '21 mile',
              total: '\$241.00',
              isUrgent: false,
              isCombined: false,
            ),

            SizedBox(height: 80.h), // Bottom padding for nav bar
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, String subtitle) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: Colors.grey[50],
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: Column(
          children: [
            Text(
              title,
              style: TextStyle(
                fontSize: 12.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey[600],
                fontWeight: FontWeight.w400,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAssignmentCard({
    required String orderId,
    required String customerName,
    required String arrivalTime,
    required String address,
    required String distance,
    required String total,
    required bool isUrgent,
    required bool isCombined,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'Order $orderId',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              if (isUrgent)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.red[50],
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                  child: Text(
                    'Urgent',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              SizedBox(width: 8.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(4.r),
                ),
                child: Text(
                  isCombined ? 'Combined' : 'Single',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Customer Info
          Row(
            children: [
              CircleAvatar(
                radius: 16.r,
                backgroundColor: Colors.grey[300],
                child: Icon(Icons.person, size: 18.sp, color: Colors.grey[600]),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                  ),
                  Text(
                    arrivalTime,
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),
              const Spacer(),
              // Customer icons
              Row(
                children: [
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Icon(
                      Icons.message_outlined,
                      size: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    width: 24.w,
                    height: 24.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(4.r),
                    ),
                    child: Icon(
                      Icons.call_outlined,
                      size: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Address
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16.sp,
                color: Colors.grey[600],
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  address,
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
              ),
              Text(
                distance,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Total and Actions
          Row(
            children: [
              Text(
                'Total:',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Text(
                total,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          SizedBox(height: 16.h),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {},
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.red[300]!),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                  ),
                  child: Text(
                    'Reject',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.red,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    elevation: 0,
                  ),
                  child: Text(
                    'Accept',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: const Color(0xFFFFB800),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
