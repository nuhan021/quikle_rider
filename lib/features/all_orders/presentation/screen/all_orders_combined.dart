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
      backgroundColor: const Color(0xFFF5F5F5),
      body: SingleChildScrollView(
        child: Container(
          width: 360.w,
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Delivery Progress and Pickup Points Section
              Container(
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
                    // Delivery Progress
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                        Text(
                          '2 of 3 steps',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: const Color(0xFF919191),
                            fontFamily: 'Inter',
                            height: 1.50,
                          ),
                        ),
                      ],
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
                        _buildProgressStep('Picked Up', true, true),
                        _buildProgressStep('In Progress', true, false),
                        _buildProgressStep('Delivered', false, false),
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
                          width: 158.w,
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
                    // Pickup Points
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
                      'Thai Spice Restaurant',
                      '123 Main St, Bangkok',
                      'Pickup completed at 15:10 PM',
                      'Completed',
                      const Color(0x264CAF50),
                      const Color(0xFF4CAF50),
                    ),
                    SizedBox(height: 12.h),
                    Container(
                      width: double.infinity,
                      height: 1.h,
                      color: const Color(0x3FB7B7B7),
                    ),
                    SizedBox(height: 12.h),
                    _buildPickupPoint(
                      'Sushi Express',
                      '456 Central Ave, Bangkok',
                      'Estimated arrival in 5 min',
                      'Pending',
                      const Color(0x26FF6F00),
                      const Color(0xFFFF6F00),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 24.h),

              // Delivery Information, Delivery Address, and Items to Deliver
              Container(
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
                    // Delivery Information
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
                    _buildDeliveryInfo(),
                    SizedBox(height: 24.h),

                    // Delivery Address
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
                            '789 River Rd, Apartment 3B, Riverside Mohakhali',
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

                    // Items to Deliver
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
                      'Thai Spice Restaurant',
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
                    _buildFoodItem(
                      'Pad Thai Chicken X 1',
                      'Medium spicy, no peanuts',
                      'assets/images/foodimage.png',
                    ),
                    SizedBox(height: 10.h),
                    _buildFoodItem(
                      'Spring Rolls X 2',
                      'Vegetarian',
                      'assets/images/foodimage02.png',
                    ),
                    SizedBox(height: 10.h),
                    Text(
                      'Sushi Express',
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
                    _buildFoodItem(
                      'Dragon Roll Set X 1',
                      '8 pieces, extra wasabi',
                      'assets/images/foodimage03.png',
                    ),
                    SizedBox(height: 10.h),
                    _buildFoodItem(
                      'Miso Soup X 1',
                      'Regular size',
                      'assets/images/foodimage03.png',
                    ),
                  ],
                ),
              ),
              SizedBox(height: 80.h), // Bottom padding for nav bar
            ],
          ),
        ),
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

  Widget _buildDeliveryInfo() {
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
                  'assets/images/avatar.png',
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
                    'Aanya Desai',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF333333),
                      fontFamily: 'Inter',
                      height: 1.20,
                    ),
                  ),
                  Text(
                    '123 Main St, Bangkok',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF7C7C7C),
                      fontFamily: 'Inter',
                      height: 1.50,
                    ),
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
                  child: Icon(
                    Icons.restaurant,
                    size: 24,
                    color: Colors.orange,
                  ),
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
}
