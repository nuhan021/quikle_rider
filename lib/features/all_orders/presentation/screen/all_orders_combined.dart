import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AllOrdersCombined extends StatefulWidget {
  const AllOrdersCombined({super.key});

  @override
  State<AllOrdersCombined> createState() => _AllOrdersCombinedState();
}

class _AllOrdersCombinedState extends State<AllOrdersCombined> {
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

              // Delivery Progress Section
              Text(
                'Delivery Progress',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 8.h),

              Row(
                children: [
                  Text(
                    '2 of 3 steps',
                    style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                  ),
                ],
              ),

              SizedBox(height: 12.h),

              // Progress Steps
              Row(
                children: [
                  _buildProgressStep('Picked Up', true, true),
                  _buildProgressLine(true),
                  _buildProgressStep('In Progress', true, false),
                  _buildProgressLine(false),
                  _buildProgressStep('Delivered', false, false),
                ],
              ),

              SizedBox(height: 24.h),

              // Pickup Points Section
              Text(
                'Pickup Points',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 12.h),

              _buildPickupPoint(),

              SizedBox(height: 24.h),

              // Delivery Information
              Text(
                'Delivery Information',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 12.h),

              _buildDeliveryInfo(),

              SizedBox(height: 24.h),

              // Delivery Address
              Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 8.h),

              Row(
                children: [
                  Icon(
                    Icons.location_on_outlined,
                    size: 16.sp,
                    color: Colors.black,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      '789 River Rd, Apartment 3B, Riverside Mohakhali',
                      style: TextStyle(fontSize: 14.sp, color: Colors.black),
                    ),
                  ),
                ],
              ),

              SizedBox(height: 24.h),

              // Items to Deliver
              Text(
                'Items to Deliver',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 4.h),

              Text(
                'Sushi Express',
                style: TextStyle(fontSize: 14.sp, color: Colors.grey[600]),
              ),

              SizedBox(height: 12.h),

              // Food Items
              _buildFoodItem(
                'Dragon Roll Set X 1',
                '7 pieces, extra wasabi',
                'assets/images/sushi1.png', // Add this image
              ),

              SizedBox(height: 12.h),

              _buildFoodItem(
                'Miso Soup X 1',
                'Regular size',
                'assets/images/sushi2.png', // Add this image
              ),

              SizedBox(height: 80.h), // Bottom padding for nav bar
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressStep(String label, bool isCompleted, bool isActive) {
    return Column(
      children: [
        Container(
          width: 24.w,
          height: 24.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isCompleted
                ? const Color(0xFFFFB800)
                : isActive
                ? const Color(0xFFFFB800)
                : Colors.grey[300],
            border: Border.all(
              color: isCompleted || isActive
                  ? const Color(0xFFFFB800)
                  : Colors.grey[300]!,
              width: 2,
            ),
          ),
          child: isCompleted
              ? Icon(Icons.check, size: 14.sp, color: Colors.white)
              : null,
        ),
        SizedBox(height: 4.h),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            color: isCompleted || isActive ? Colors.black : Colors.grey[600],
            fontWeight: isCompleted || isActive
                ? FontWeight.w500
                : FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildProgressLine(bool isCompleted) {
    return Expanded(
      child: Container(
        height: 2.h,
        margin: EdgeInsets.symmetric(horizontal: 8.w, vertical: 11.h),
        color: isCompleted ? const Color(0xFFFFB800) : Colors.grey[300],
      ),
    );
  }

  Widget _buildPickupPoint() {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(8.r),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 8.w,
            height: 8.h,
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.orange,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sushi Express',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '456 Central Ave, Bangkok',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
                ),
                Text(
                  'Estimated arrival in 5 min',
                  style: TextStyle(fontSize: 11.sp, color: Colors.grey[500]),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'Pending',
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.orange[700],
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDeliveryInfo() {
    return Row(
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: Colors.grey[300],
          child: Icon(Icons.person, size: 20.sp, color: Colors.grey[600]),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Aanya Desai',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              Text(
                '123 Main St, Bangkok',
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
        Row(
          children: [
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.message_outlined,
                size: 16.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(width: 8.w),
            Container(
              width: 32.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                Icons.call_outlined,
                size: 16.sp,
                color: Colors.grey[600],
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
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8.r),
            color: Colors.grey[200],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(8.r),
            child: Image.asset(
              imagePath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  color: Colors.orange[100],
                  child: Icon(
                    Icons.restaurant,
                    size: 24.sp,
                    color: Colors.orange,
                  ),
                );
              },
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                description,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
