// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MonthlyEarningsForecastCard extends StatefulWidget {
  final String title;
  final String projectedAmount;
  final String basisNote;
  final List<String> goals;
  final String currentBalanceText;
  final VoidCallback? onViewDetails;
  final double currentAmount;
  final double targetAmount;

  const MonthlyEarningsForecastCard({
    super.key,
    required this.title,
    required this.projectedAmount,
    required this.basisNote,
    required this.goals,
    this.currentBalanceText = '₹0',
    this.onViewDetails,
    this.currentAmount = 0,
    this.targetAmount = 0,
  });

  @override
  State<MonthlyEarningsForecastCard> createState() =>
      _MonthlyEarningsForecastCardState();
}

class _MonthlyEarningsForecastCardState
    extends State<MonthlyEarningsForecastCard>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late AnimationController _progCtrl;
  late AnimationController _pulse;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();
    _progCtrl = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _pulse = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    Future.delayed(const Duration(milliseconds: 300), _progCtrl.forward);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _progCtrl.dispose();
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.1),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)),
        child: Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFFFFBF0)],
            ),
            borderRadius: BorderRadius.circular(20.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB87700).withValues(alpha: 0.12),
                blurRadius: 24.r,
                offset: const Offset(0, 8),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 16.h),
              _buildProgress(),
        

             
    
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.title,
            style: TextStyle(
              fontFamily: 'Obviously',
              fontSize: 18.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF111827),
              letterSpacing: -0.3,
            ),
          ),
        ),
        AnimatedBuilder(
          animation: _pulse,
          builder: (_, __) => Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: Color.lerp(
                const Color(0xFFB87700).withValues(alpha: 0.1),
                const Color(0xFFB87700).withValues(alpha: 0.2),
                _pulse.value,
              ),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: Color.lerp(
                  const Color(0xFFB87700).withValues(alpha: 0.3),
                  const Color(0xFFB87700).withValues(alpha: 0.6),
                  _pulse.value,
                )!,
              ),
            ),
            child: Text(
              'On Track',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFFB87700),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildProgress() {
    return AnimatedBuilder(
      animation: _progCtrl,
      builder: (_, __) {
        final prog =
            widget.currentAmount / widget.targetAmount * _progCtrl.value;
        final curr = (widget.currentAmount * _progCtrl.value).toInt();
        final pct = (prog * 100).toInt();

        return Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                const Color(0xFFFFE799),
                Color.lerp(
                  const Color(0xFFFFF5D6),
                  const Color(0xFFFFE799),
                  _pulse.value * 0.1,
                )!,
              ],
            ),
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: const Color(0xFFFFD966).withValues(alpha: 0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹$curr',
                    style: TextStyle(
                      fontFamily: 'Obviously',
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w900,
                      color: const Color(0xFFB87700),
                      height: 1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Text(
                      '/ ₹${widget.targetAmount.toInt()}',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFB87700).withValues(alpha: 0.6),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Stack(
                children: [
                  Container(
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.5),
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  FractionallySizedBox(
                    widthFactor: prog,
                    child: Container(
                      height: 8.h,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFFB87700), Color(0xFFD97706)],
                        ),
                        borderRadius: BorderRadius.circular(10.r),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFB87700).withValues(alpha: 0.4),
                            blurRadius: 8.r,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                children: [
                  Text(
                    '$pct% Complete',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFFB87700),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '₹${(widget.targetAmount - widget.currentAmount).toInt()} to go',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF92400E),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Text(
                widget.basisNote,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 11.sp,
                  color: const Color(0xFF92400E).withValues(alpha: 0.8),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
    }