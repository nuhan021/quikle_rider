import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// This is the CustomClipper class that creates the curved shape.
class _BottomCurveClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();

    // Start from the top-left corner
    path.lineTo(0, 0);
    // Draw a straight line to the top-right corner
    path.lineTo(size.width, 0);
    // Draw a line down to the bottom-right corner
    path.lineTo(size.width, size.height);

    // Create a pronounced, downward curve at the bottom using a quadratic bezier curve.
    // The control point is set well below the height of the container to create a clear dip.
    path.quadraticBezierTo(
      size.width / 2,
      size.height + 10, // Adjust this value to control the depth of the curve
      0,
      size.height,
    );

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

  const CustomTabBar({
    super.key,
    required this.title,
    required this.isOnline,
    required this.onToggle,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 3.h);

  @override
  Widget build(BuildContext context) {
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
            // Custom Toggle Switch
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
                      onTap: onToggle, // Use the provided callback
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
            const Spacer(),
            // A placeholder for the notification icon
            Icon(Icons.notifications_outlined, color: Colors.black, size: 24.sp),
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
