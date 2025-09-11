import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/features/all_orders/presentation/screen/all_orders.dart';
import 'package:quikle_rider/features/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:quikle_rider/features/home/presentation/screen/homepage.dart';
import 'package:quikle_rider/features/map/presentation/screen/map.dart';
import 'package:quikle_rider/features/profile/presentation/screen/profile.dart';
import 'package:quikle_rider/features/wallet/presentation/screen/wallet.dart';

class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final BottomNavbarController controller = Get.put(BottomNavbarController());
    final List<Widget> screens = [
      const HomeScreen(),
      const AllOrders(),
          const AllOrders(),
           const AllOrders(),
                const AllOrders(),
    ];

    return Scaffold(
      body: Obx(() => screens[controller.selectedIndex.value]),
      bottomNavigationBar: _buildBottomNavigationBar(context, controller),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context, BottomNavbarController controller) {
    return Container(
      height: 130.h,
      decoration: BoxDecoration(
        color: const Color(0xFF1A1A1A),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20.r),
          topRight: Radius.circular(20.r),
        ),
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
          padding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 8.h,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: List.generate(
              controller.navItems.length,
              (index) {
                final item = controller.navItems[index];
                return _buildNavItem(
                  context,
                  controller: controller,
                  index: index,
                  icon: item.icon,
                  label: item.label,
                  fallbackIcon: item.fallbackIcon,
                  isProfile: item.isProfile,
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    BuildContext context, {
    required BottomNavbarController controller,
    required int index,
    required String icon,
    required String label,
    required IconData fallbackIcon,
    bool isProfile = false,
  }) {
    return Obx(() {
      final isSelected = controller.selectedIndex.value == index;

      return GestureDetector(
        onTap: () => controller.changeIndex(index),
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 4.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24.w,
                height: 32.h,
                alignment: Alignment.center,
                child: isProfile
                    ? Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? const Color(0xFFFFB800)
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        child: CircleAvatar(
                          radius: 12.r,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            size: 14.sp,
                            color: Colors.grey[600],
                          ),
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
                          return Icon(
                            fallbackIcon,
                            size: 24.sp,
                            color: isSelected
                                ? const Color(0xFFFFB800)
                                : Colors.grey[400],
                          );
                        },
                      ),
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w400,
                  color: isSelected ? const Color(0xFFFFB800) : Colors.grey[400],
                ),
              ),
              // Always render the indicator, but make it transparent if not selected
              Container(
                margin: EdgeInsets.only(top: 6.h),
                width: 45.w,
                height: 2.h,
                decoration: BoxDecoration(
                  color: isSelected
                      ? const Color(0xFFFFB800)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(100.r),
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}