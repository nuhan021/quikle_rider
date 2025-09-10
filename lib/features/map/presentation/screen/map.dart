import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/custom_tab_bar/custom_tab_bar.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  bool _isOnline = true; // State for toggle switch

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
        title: 'Map',
        isOnline: _isOnline,
        onToggle: _toggleOnlineStatus,
        currentIndex: 2, // Assuming MapScreen is the first tab
      ),
      body: Column(
        children: [
          // Map Area
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              child: Stack(
                children: [
                  // Map background (placeholder)
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      image: const DecorationImage(
                        image: AssetImage('assets/map_placeholder.png'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  // Route line and markers
                  Positioned(
                    top: 50.h,
                    right: 20.w,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.yellow[700],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 80.h,
                    left: 20.w,
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.yellow[700],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.location_on,
                        color: Colors.white,
                        size: 20.sp,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Delivery Information
          Container(
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.1),
                  spreadRadius: 1,
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Delivery Address',
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12.w,
                        vertical: 6.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange[50],
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                      child: Text(
                        '09:45 min',
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 25.r,
                      backgroundImage: const AssetImage(
                        'assets/driver_avatar.png',
                      ),
                      backgroundColor: Colors.grey[300],
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Aanya Desai',
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          Text(
                            '123 Main St, Bangkok',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.chat_bubble_outline, size: 20.sp),
                        ),
                        SizedBox(width: 10.w),
                        Container(
                          padding: EdgeInsets.all(10.w),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey[300]!),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Icon(Icons.phone_outlined, size: 20.sp),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15.h),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Colors.grey[600],
                      size: 16.sp,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      '789 River Rd, Apartment 3B, Riverside Mohakhali',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 20.h),
                Text(
                  'Items to Deliver',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
                SizedBox(height: 10.h),
                Text(
                  'Sushi Express',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey[700],
                  ),
                ),
                SizedBox(height: 15.h),
                Container(
                  padding: EdgeInsets.all(15.w),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              image: const DecorationImage(
                                image: AssetImage('assets/dragon_roll.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Dragon Roll Set X 1',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  '8 pieces, extra wasabi',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 10.h),
                      Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.h,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(8.r),
                              image: const DecorationImage(
                                image: AssetImage('assets/miso_soup.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Miso Soup X 1',
                                  style: TextStyle(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black87,
                                  ),
                                ),
                                Text(
                                  'Regular size',
                                  style: TextStyle(
                                    fontSize: 12.sp,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {},
                        icon: Icon(
                          Icons.phone,
                          color: Colors.black87,
                          size: 20.sp,
                        ),
                        label: Text(
                          'Call Customer',
                          style: TextStyle(
                            color: Colors.black87,
                            fontSize: 14.sp,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          side: BorderSide(color: Colors.grey[300]!),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 15.w),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black87,
                          padding: EdgeInsets.symmetric(vertical: 12.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          'Mark as Delivered',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                            fontSize: 14.sp,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
