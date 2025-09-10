import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/custom_tab_bar/notifications.dart';

class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, 0);
    path.lineTo(size.width, 0);
    path.lineTo(size.width, size.height);
    path.quadraticBezierTo(size.width / 2, size.height + 10, 0, size.height);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) {
    return false;
  }
}

class CustomTabBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final bool isOnline;
  final VoidCallback onToggle;
  final int currentIndex;

  const CustomTabBar({
    super.key,
    required this.title,
    required this.isOnline,
    required this.onToggle,
    required this.currentIndex,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 3.h);

  @override
  Widget build(BuildContext context) {
    final bool showToggle = currentIndex == 0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            SizedBox(width: 8.w),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Obviously',
                fontSize: 18.sp,
                fontWeight: FontWeight.w900,
                color: Colors.black,
              ),
            ),
            const Spacer(),
            if (showToggle)
              Container(
                width: 60.w,
                height: 30.h,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15.r),
                  color: isOnline ? const Color(0xFFFFB800) : Colors.grey[300],
                ),
                child: Stack(
                  children: [
                    AnimatedPositioned(
                      duration: const Duration(milliseconds: 200),
                      left: isOnline ? 32.w : 2.w,
                      top: 2.h,
                      child: GestureDetector(
                        onTap: onToggle,
                        child: Container(
                          width: 26.w,
                          height: 26.h,
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 3,
                                offset: Offset(0, 1),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            if (showToggle) const Spacer(),
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const NotificationsPage(),
                  ), // Navigate to the NotificationsScreen
                );
              },
              child: Image.asset(
                'assets/images/notification.png',
                color: Colors.black,
                width: 24.sp,
                height: 24.sp,
              ),
            ),
            SizedBox(width: 16.w),
          ],
        ),
        bottom: PreferredSize(
          preferredSize: Size.fromHeight(3.h),
          child: ClipPath(
            clipper: _BottomCurveClipper(),
            child: Container(
              height: 3.h,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [Color(0xFFFFB800), Color(0xFFFF8C00)],
                  begin: Alignment.centerLeft,
                  end: Alignment.centerRight,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

