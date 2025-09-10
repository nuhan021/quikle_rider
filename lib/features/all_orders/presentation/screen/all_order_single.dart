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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Container(
          width: 360.w,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Order Card
              _buildSingleOrderCard(
                orderId: '#5680',
                customerName: 'John Smith',
                restaurant: 'Pizza Palace',
                address: '123 Main Street, Downtown',
                estimatedTime: '25 min',
                distance: '1.5 miles',
                amount: '\$18.50',
                status: 'In Progress',
                statusColor: const Color(0xFFFF6F00),
                statusBgColor: const Color(0x26FF6F00),
                restaurantImage: 'assets/images/foodimage.png',
                customerImage: 'assets/images/avatar.png',
                items: [
                  {'name': 'Margherita Pizza X 1', 'details': 'Extra cheese'},
                  {'name': 'Garlic Bread X 2', 'details': 'With dipping sauce'},
                ],
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
    required Color statusBgColor,
    required String restaurantImage,
    required String customerImage,
    required List<Map<String, String>> items,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        shadows: const [
          BoxShadow(
            color: Color(0x0A606060),
            blurRadius: 8,
            offset: Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Order $orderId',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Obviously',
                  height: 1.40,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: ShapeDecoration(
                  color: statusBgColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4.r),
                  ),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                    fontFamily: 'Manrope',
                    height: 1.50,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          // Delivery Progress and Pickup Points
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Progress',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Obviously',
                  height: 1.40,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                height: 1.h,
                color: const Color(0x3FB7B7B7),
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildProgressStep(
                    'Picked Up',
                    status != 'Preparing' && status != 'Delivered',
                    true,
                  ),
                  _buildProgressStep(
                    'In Progress',
                    status == 'In Progress' ||
                        status == 'Ready for Pickup' ||
                        status == 'Delivered',
                    false,
                  ),
                  _buildProgressStep('Delivered', status == 'Delivered', false),
                ],
              ),
              SizedBox(height: 4.h),
              Stack(
                children: [
                  Container(
                    width: 328.w,
                    height: 6.h,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFF0F0F0),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                  Container(
                    width: status == 'Delivered'
                        ? 328.w
                        : status == 'In Progress' ||
                              status == 'Ready for Pickup'
                        ? 158.w
                        : 0,
                    height: 6.h,
                    decoration: ShapeDecoration(
                      color: const Color(0xFFFFC200),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.r),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'Pickup Points',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Obviously',
                  height: 1.40,
                ),
              ),
              SizedBox(height: 12.h),
              _buildPickupPoint(
                restaurant,
                address,
                status == 'Delivered'
                    ? 'Pickup completed'
                    : status == 'Ready for Pickup'
                    ? 'Ready for pickup'
                    : 'Estimated arrival in $estimatedTime',
                status == 'Delivered' || status == 'Ready for Pickup'
                    ? 'Completed'
                    : 'Pending',
                status == 'Delivered' || status == 'Ready for Pickup'
                    ? const Color(0x264CAF50)
                    : const Color(0x26FF6F00),
                status == 'Delivered' || status == 'Ready for Pickup'
                    ? const Color(0xFF4CAF50)
                    : const Color(0xFFFF6F00),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          // Delivery Information, Delivery Address, and Items to Deliver
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Delivery Information',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Obviously',
                  height: 1.40,
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                width: double.infinity,
                height: 1.h,
                color: const Color(0x3FB7B7B7),
              ),
              SizedBox(height: 12.h),
              _buildDeliveryInfo(customerName, address, customerImage),
              SizedBox(height: 24.h),
              Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Obviously',
                  height: 1.40,
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 18,
                    color: const Color(0xFF333333),
                  ),
                  SizedBox(width: 2.w),
                  Expanded(
                    child: Text(
                      address,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF333333),
                        fontFamily: 'Manrope',
                        height: 1.50,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24.h),
              Text(
                'Items to Deliver',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: const Color.fromARGB(255, 0, 0, 0),
                  fontFamily: 'Obviously',
                  height: 1.40,
                ),
              ),
              SizedBox(height: 10.h),
              Text(
                restaurant,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF333333),
                  fontFamily: 'Inter',
                  height: 1.20,
                ),
              ),
              SizedBox(height: 10.h),
              Container(
                width: double.infinity,
                height: 1.h,
                color: const Color(0x3FB7B7B7),
              ),
              SizedBox(height: 10.h),
              ...items.asMap().entries.map((entry) {
                Map<String, String> item = entry.value;
                return Padding(
                  padding: EdgeInsets.only(bottom: 10.h),
                  child: _buildFoodItem(
                    item['name']!,
                    item['details']!,
                    restaurantImage,
                  ),
                );
              }).toList(),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Total:',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF7C7C7C),
                      fontFamily: 'Inter',
                      height: 1.50,
                    ),
                  ),
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                      fontFamily: 'Inter',
                      height: 1.20,
                    ),
                  ),
                ],
              ),
              if (status != 'Delivered') ...[
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () {
                          _showActionDialog('Cancel Order', orderId);
                        },
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFEF5350)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                        ),
                        child: Text(
                          'Cancel',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFFEF5350),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Manrope',
                            height: 1.50,
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
                          backgroundColor: const Color(0xFF333333),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          elevation: 0,
                        ),
                        child: Text(
                          status == 'Ready for Pickup'
                              ? 'Pick Up'
                              : 'View Details',
                          style: TextStyle(
                            fontSize: 12,
                            color: const Color(0xFFFFC200),
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Manrope',
                            height: 1.50,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressStep(String label, bool isCompleted, bool isActive) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          children: [
            SizedBox(height: 1.h),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: isCompleted || isActive
                    ? const Color(0xFF333333)
                    : const Color(0xFF333333),
                fontWeight: isCompleted || isActive
                    ? FontWeight.w600
                    : FontWeight.w400,
                fontFamily: 'Inter',
                height: 1.50,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPickupPoint(
    String title,
    String address,
    String statusText,
    String status,
    Color statusBgColor,
    Color statusTextColor,
  ) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: const Color(0x3FB7B7B7)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                width: 8.w,
                height: 8.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: status == 'Completed'
                      ? const Color(0xFF4CAF50)
                      : const Color(0xFFFF6F00),
                ),
              ),
              SizedBox(width: 8.w),
              SizedBox(
                width: 168.w,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                        fontFamily: 'Inter',
                        height: 1.50,
                      ),
                    ),
                    Text(
                      address,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF484848),
                        fontFamily: 'Inter',
                        height: 1.20,
                      ),
                    ),
                    Text(
                      statusText,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF9B9B9B),
                        fontFamily: 'Inter',
                        height: 1.30,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: statusBgColor,
              borderRadius: BorderRadius.circular(4.r),
            ),
            child: Text(
              status,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: statusTextColor,
                fontFamily: 'Manrope',
                height: 1.50,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo(
    String customerName,
    String address,
    String customerImage,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              width: 48.w,
              height: 48.h,
              decoration: const ShapeDecoration(
                color: Color(0xFFC4C4C4),
                shape: OvalBorder(),
              ),
              child: ClipOval(
                child: Image.asset(
                  customerImage,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(
                      Icons.person,
                      size: 20,
                      color: const Color(0xFF7C7C7C),
                    );
                  },
                ),
              ),
            ),
            SizedBox(width: 12.w),
            SizedBox(
              width: 168.w,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    customerName,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                      fontFamily: 'Inter',
                      height: 1.20,
                    ),
                  ),
                  Text(
                    address,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF7C7C7C),
                      fontFamily: 'Inter',
                      height: 1.50,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
        Row(
          children: [
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Image.asset(
                'assets/images/message.png',
                width: 16,
                height: 16,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            SizedBox(width: 16.w),
            Container(
              width: 24.w,
              height: 24.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Image.asset(
                'assets/images/call.png',
                width: 16,
                height: 16,
                color: const Color.fromARGB(255, 0, 0, 0),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFoodItem(String name, String description, String imagePath) {
    return Row(
      children: [
        Container(
          width: 40.w,
          height: 40.h,
          decoration: ShapeDecoration(
            color: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(6.r),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.orange[100],
                  child: Icon(Icons.restaurant, size: 24, color: Colors.orange),
                );
              },
            ),
          ),
        ),
        SizedBox(width: 12.w),
        SizedBox(
          width: 168.w,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                  fontFamily: 'Inter',
                  height: 1.20,
                ),
              ),
              Text(
                description,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF7C7C7C),
                  fontFamily: 'Inter',
                  height: 1.30,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _showActionDialog(String action, String orderId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            action,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: const Color.fromARGB(255, 0, 0, 0),
              fontFamily: 'Obviously',
              height: 1.40,
            ),
          ),
          content: Text(
            'Are you sure you want to ${action.toLowerCase()} $orderId?',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              color: const Color(0xFF7C7C7C),
              fontFamily: 'Inter',
              height: 1.50,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF7C7C7C),
                  fontFamily: 'Manrope',
                  height: 1.50,
                ),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '$action completed for $orderId',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                        fontFamily: 'Manrope',
                        height: 1.50,
                      ),
                    ),
                    backgroundColor: const Color(0xFFFFC200),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFEF5350),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4.r),
                ),
              ),
              child: Text(
                'Confirm',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                  fontFamily: 'Manrope',
                  height: 1.50,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  void _navigateToOrderDetails(String orderId) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Navigating to details for $orderId',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.white,
            fontFamily: 'Manrope',
            height: 1.50,
          ),
        ),
        backgroundColor: const Color(0xFFFFC200),
      ),
    );
  }
}
