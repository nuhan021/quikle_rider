import 'package:flutter/material.dart';

class OrderCancelPage extends StatelessWidget {
  const OrderCancelPage({super.key});

  @override
  // sooooo goood git
  Widget build(BuildContext context) {
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
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Cancel Icon
              Container(
                width: 80,
                height: 80,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  'assets/images/cancel.png',
                  width: 40,
                  height: 40,
                ),
              ),
              const SizedBox(height: 32),
              // Title Text
              const Text(
                'Order Declined',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}