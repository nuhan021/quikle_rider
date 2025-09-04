import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/core/utils/constants/icon_path.dart';
import 'package:quikle_rider/features/all_orders/presentation/screen/all_orders.dart';
import 'package:quikle_rider/features/categories/categories.dart';
import 'package:quikle_rider/features/home/presentation/screen/homepage.dart';
import 'package:quikle_rider/features/map/map.dart';
import 'package:quikle_rider/features/profile/profile.dart';

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({super.key});

  @override
  State<BottomNavBar> createState() => _BottomNavBarState();
}

class _BottomNavBarState extends State<BottomNavBar> {
  int currentIndex = 0;

  final List<Widget> screens = [
    const HomePage(),
    const AllOrders(),
    const MapPage(),
    const Categories(),
    const ProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: currentIndex, children: screens),
      bottomNavigationBar: Container(
        height: 105.h,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildNavItem(index: 0, icon: IconPath.home, label: 'Home'),
                _buildNavItem(
                  index: 1,
                  icon: IconPath.allOrders,
                  label: 'All Orders',
                ),
                _buildNavItem(index: 2, icon: IconPath.map, label: 'Map'),
                _buildNavItem(
                  index: 3,
                  icon: IconPath.categories,
                  label: 'Categories',
                ),
                _buildNavItem(
                  index: 4,
                  icon: IconPath.profile,
                  label: 'Aanya',
                  isProfile: true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required int index,
    required String icon,
    required String label,
    bool isProfile = false,
  }) {
    final isSelected = currentIndex == index;

    return GestureDetector(
      onTap: () {
        setState(() {
          currentIndex = index;
        });
      },
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 4.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon
            Container(
              width: 24.w,
              height: 32.h,
              child: isProfile && isSelected
                  ? Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFFFFB800),
                          width: 2,
                        ),
                      ),
                      child: CircleAvatar(
                        radius: 10.r,
                        backgroundColor: Colors.grey[300],
                        child: Icon(
                          Icons.person,
                          size: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                    )
                  : isProfile
                  ? CircleAvatar(
                      radius: 12.r,
                      backgroundColor: Colors.grey[300],
                      child: Icon(
                        Icons.person,
                        size: 14.sp,
                        color: Colors.grey[600],
                      ),
                    )
                  : Image.asset(
                      icon,
                      width: 24.w,
                      height: 24.h,
                      color: isSelected
                          ? const Color(0xFFFFB800)
                          : Colors.grey[400],
                      errorBuilder: (context, error, stackTrace) {
                        // Fallback to icons if images don't exist
                        return Icon(
                          _getIconData(index),
                          size: 24.sp,
                          color: isSelected
                              ? const Color(0xFFFFB800)
                              : Colors.grey[400],
                        );
                      },
                    ),
            ),

            SizedBox(height: 4.h),

            // Label
            Text(
              label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFFFFB800) : Colors.grey[400],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(int index) {
    switch (index) {
      case 0:
        return Icons.home;
      case 1:
        return Icons.receipt_long;
      case 2:
        return Icons.map;
      case 3:
        return Icons.category;
      case 4:
        return Icons.person;
      default:
        return Icons.help_outline;
    }
  }
}
