import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/utils/constants/icon_path.dart';
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
      const MapScreen(),
      const WalletScreen(),
      const ProfileScreen(),
    ];

    return Scaffold(
      body: Obx(() => screens[controller.selectedIndex.value]),
      bottomNavigationBar: Obx(
        () => Stack(
          clipBehavior: Clip.none, // Allows the line to "peek" above
          children: [
            Container(
              height: 120.h,
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
                    children: [
                      _buildNavItem(
                        context,
                        controller: controller,
                        index: 0,
                        icon: IconPath.home,
                        label: 'Home',
                      ),
                      _buildNavItem(
                        context,
                        controller: controller,
                        index: 1,
                        icon: IconPath.allOrders,
                        label: 'All Orders',
                      ),
                      _buildNavItem(
                        context,
                        controller: controller,
                        index: 2,
                        icon: IconPath.map,
                        label: 'Map',
                      ),
                      _buildNavItem(
                        context,
                        controller: controller,
                        index: 3,
                        icon: IconPath.wallet,
                        label: 'Wallet',
                      ),
                      _buildNavItem(
                        context,
                        controller: controller,
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
            Positioned(
              top: -2.h, // Use a small negative value to position it above
              left: 0,
              right: 0,
              child: ClipPath(
                clipper: CurvedLineClipper(radius: 20.r),
                child: Container(height: 2.h, color: const Color(0xFFFFB800)),
              ),
            ),
          ],
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
    bool isProfile = false,
  }) {
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
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16.sp,
                fontWeight: FontWeight.w400,
                color: isSelected ? const Color(0xFFFFB800) : Colors.grey[400],
              ),
            ),
            if (isSelected)
              Container(
                margin: EdgeInsets.only(top: 6.h),
                width: 45.w,
                height: 2.h,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB800),
                  borderRadius: BorderRadius.circular(100),
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
        return Icons.wallet;
      case 4:
        return Icons.person;
      default:
        return Icons.help_outline;
    }
  }
}

// Custom Clipper to create the curved line shape
class CurvedLineClipper extends CustomClipper<Path> {
  final double radius;

  CurvedLineClipper({required this.radius});

  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(radius, 0); // Start the line after the curve begins
    path.arcToPoint(
      Offset(size.width - radius, 0),
      radius: Radius.circular(radius),
      clockwise: false,
    );
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.lineTo(0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}
