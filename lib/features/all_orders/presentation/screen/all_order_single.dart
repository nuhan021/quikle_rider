import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllOrdersSingle extends StatefulWidget {
  const AllOrdersSingle({super.key});

  @override
  State<AllOrdersSingle> createState() => _AllOrdersSingleState();
}

class _AllOrdersSingleState extends State<AllOrdersSingle> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 16.h),

              // Single Orders List
              _buildSingleOrderCard(
                orderId: '#5680',
                customerName: 'John Smith',
                restaurant: 'Pizza Palace',
                address: '123 Main Street, Downtown',
                estimatedTime: '25 min',
                distance: '1.5 miles',
                amount: '\$18.50',
                status: 'In Progress',
                statusColor: Colors.orange,
              ),

              SizedBox(height: 16.h),

              _buildSingleOrderCard(
                orderId: '#5681',
                customerName: 'Sarah Johnson',
                restaurant: 'Burger Barn',
                address: '456 Oak Avenue, Uptown',
                estimatedTime: '15 min',
                distance: '0.8 miles',
                amount: '\$24.75',
                status: 'Ready for Pickup',
                statusColor: Colors.green,
              ),

              SizedBox(height: 16.h),

              _buildSingleOrderCard(
                orderId: '#5682',
                customerName: 'Mike Wilson',
                restaurant: 'Taco Time',
                address: '789 Pine Street, Midtown',
                estimatedTime: '30 min',
                distance: '2.1 miles',
                amount: '\$15.25',
                status: 'Preparing',
                statusColor: Colors.blue,
              ),

              SizedBox(height: 16.h),

              _buildSingleOrderCard(
                orderId: '#5683',
                customerName: 'Emily Davis',
                restaurant: 'Healthy Bites',
                address: '321 Elm Street, Westside',
                estimatedTime: '20 min',
                distance: '1.2 miles',
                amount: '\$32.00',
                status: 'Delivered',
                statusColor: Colors.grey,
              ),

              SizedBox(height: 80.h), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSingleOrderCard({
    required String orderId,
    required String customerName,
    required String restaurant,
    required String address,
    required String estimatedTime,
    required String distance,
    required String amount,
    required String status,
    required Color statusColor,
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
          // Header Row
          Row(
            children: [
              Text(
                'Order $orderId',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
            ],
          ),

          SizedBox(height: 12.h),

          // Restaurant Info
          Row(
            children: [
              Container(
                width: 40.w,
                height: 40.h,
                decoration: BoxDecoration(
                  color: Colors.orange[100],
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.restaurant,
                  size: 20.sp,
                  color: Colors.orange[700],
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      restaurant,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Pickup in $estimatedTime',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                distance,
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
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
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      customerName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // Contact buttons
              Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Icon(
                      Icons.message_outlined,
                      size: 14.sp,
                      color: Colors.grey[600],
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(6.r),
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

          SizedBox(height: 16.h),

          // Divider
          Container(height: 1.h, color: Colors.grey[200]),

          SizedBox(height: 12.h),

          // Amount and Actions
          Row(
            children: [
              Text(
                'Order Total:',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),
              const Spacer(),
              Text(
                amount,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
            ],
          ),

          if (status != 'Delivered') ...[
            SizedBox(height: 12.h),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      _showActionDialog('Cancel Order', orderId);
                    },
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.red[300]!),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                    ),
                    child: Text(
                      'Cancel',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.red,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      _navigateToOrderDetails(orderId);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r),
                      ),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      elevation: 0,
                    ),
                    child: Text(
                      status == 'Ready for Pickup' ? 'Pick Up' : 'View Details',
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: const Color(0xFFFFB800),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  void _showActionDialog(String action, String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(action),
          content: Text(
            'Are you sure you want to $action.toLowerCase() $orderId?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Implement action logic here
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('$action completed for $orderId'),
                    backgroundColor: const Color(0xFFFFB800),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToOrderDetails(String orderId) {
    // Navigate to order details page
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to details for $orderId'),
        backgroundColor: const Color(0xFFFFB800),
      ),
    );
  }
}
