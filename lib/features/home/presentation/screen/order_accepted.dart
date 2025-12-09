// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/features/bottom_nav_bar/controller/bottom_nav_bar_controller.dart';
import 'package:quikle_rider/features/bottom_nav_bar/screen/bottom_nav_bar.dart';

class OrderAcceptedPage extends StatelessWidget {
  const OrderAcceptedPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Run logic after the first build frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = Get.find<BottomNavbarController>();
      controller.changeIndex(1); // Set index to 1 (All Orders)
      print('OrderAcceptedPage: Set selectedIndex to 1 (All Orders)');

      // Navigate after 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        Get.offAll(() => const BottomNavBar());
        print(
          'OrderAcceptedPage: Navigated to BottomNavBar with All Orders tab',
        );
      });
    });

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: Container(
          width: 360,
          height: 264,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  color: Color(0xFF4CAF50),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/success.png',
                  width: 40,
                  height: 40,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.check_circle,
                    size: 40,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Order Accepted',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Successfully',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w400,
                  color: Colors.black54,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
