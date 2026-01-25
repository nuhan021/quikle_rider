// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import 'package:quikle_rider/custom_tab_bar/notifications.dart';

class CustomTabBar extends StatefulWidget implements PreferredSizeWidget {
  final String title;
  final bool isOnline;
  final VoidCallback onToggle;
  final int currentIndex;
  final Widget? leading;

  const CustomTabBar({
    super.key,
    required this.title,
    required this.isOnline,
    required this.onToggle,
    required this.currentIndex,

    this.leading,
  });

  @override
  Size get preferredSize => Size.fromHeight(kToolbarHeight + 3.h);

  @override
  State<CustomTabBar> createState() => _CustomTabBarState();
}

class _CustomTabBarState extends State<CustomTabBar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _onTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
    widget.onToggle();
  }

  void _onTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final bool showToggle = widget.currentIndex == 0;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        boxShadow: [
          BoxShadow(
            color: const Color(0x0A616161),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
            spreadRadius: 0,
          ),
        ],
        border: Border(
          bottom: BorderSide(
            color: AppColors.gradientColor, // unified bottom border color
            width: 2.w,
          ),
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20.r)),
        child: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          automaticallyImplyLeading: false,
          leading: widget.leading,
          title: Row(
            children: [
              SizedBox(width: 8.w),
              Text(
                widget.title,
                style: TextStyle(
                  fontFamily: 'Obviously',
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w900,
                  color: Colors.black,
                ),
              ),
              const Spacer(),
              if (showToggle) _buildResponsiveToggle(),
              if (showToggle) const Spacer(),
              _buildNotificationButton(),
              SizedBox(width: 16.w),
            ],
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(3.h),
            child: Container(
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(
                  bottom: Radius.circular(20), // same smooth rounded bottom
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResponsiveToggle() {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: 60.w,
              height: 30.h,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.r),
                color: widget.isOnline
                    ? const Color(0xFFFFB800)
                    : Colors.grey[300],
                boxShadow: _isPressed
                    ? [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    left: widget.isOnline ? 32.w : 2.w,
                    top: 2.h,
                    child: Container(
                      width: 26.w,
                      height: 26.h,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.15),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                          border: Border.all(
                            color: widget.isOnline
                                ? const Color(0xFFFFB800).withValues(alpha: 0.3)
                                : Colors.grey.withValues(alpha: 0.3),
                            width: _isPressed ? 2 : 0,
                          ),
                        ),
                        child: Center(
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: _isPressed ? 8.w : 6.w,
                            height: _isPressed ? 8.h : 6.h,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: widget.isOnline
                                  ? const Color(0xFFFFB800)
                                  : Colors.grey[400],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationButton() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const NotificationsPage()),
        );
      },
      child: Container(
        padding: EdgeInsets.all(4.w),
        decoration: const BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.transparent,
        ),
        child: Image.asset(
          'assets/images/notification.png',
          color: Colors.black,
          width: 24.sp,
          height: 24.sp,
        ),
      ),
    );
  }
}
