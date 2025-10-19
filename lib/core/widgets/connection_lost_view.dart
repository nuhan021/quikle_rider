import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class ConnectionLostView extends StatefulWidget {
  const ConnectionLostView({
    super.key,
    this.title = 'Connection lost',
    this.subtitle = 'You are offline. Please check your connection.',
    this.icon = Icons.wifi_off,
  });

  final String title;
  final String subtitle;
  final IconData icon;

  @override
  State<ConnectionLostView> createState() => _ConnectionLostViewState();
}

class _ConnectionLostViewState extends State<ConnectionLostView>
    with TickerProviderStateMixin {
  late AnimationController _deliveryController;
  late AnimationController _fadeController;
  late Animation<double> _deliveryAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _deliveryController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _deliveryAnimation = CurvedAnimation(
      parent: _deliveryController,
      curve: Curves.easeInOut,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );

    _deliveryController.repeat(reverse: true);
    _fadeController.forward();
  }

  @override
  void dispose() {
    _deliveryController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
                AnimatedBuilder(
                animation: _deliveryAnimation,
                builder: (context, child) {
                  return Opacity(
                    opacity:
                        0.3 +
                        0.7 * (1 - (_deliveryAnimation.value - 0.5).abs() * 2),
                    child: Icon(
                      widget.icon,
                      size: 48.sp,
                      color: Colors.grey[500],
                    ),
                  );
                },
              ),
              SizedBox(height: 24.h),
              Text(
                widget.title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Obviously',
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.black,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                widget.subtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14.sp,
                  color: Colors.grey[600],
                ),
              ),
                   SizedBox(height: 24.h),
              AnimatedBuilder(
                animation: _deliveryAnimation,
                child: SizedBox(
                  height: 190.h,
                  child: Lottie.asset(
                    'assets/icons/error.json',
                    repeat: true,
                    fit: BoxFit.contain,
                  ),
                ),
                builder: (context, child) {
                  return Transform.translate(
                    offset: Offset(
                      100.w * (1 - _deliveryAnimation.value * 2).abs() - 50.w,
                      0,
                    ),
                    child: Transform.rotate(
                      angle: 0.1 * (_deliveryAnimation.value - 0.5),
                      child: child,
                    ),
                  );
                },
              ),
         
            
            ],
          ),
        ),
      ),
    );
  }
}
