// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ProfileCompletionCard extends StatefulWidget {
  final double completionPercent;
  final List<String> missingItems;
  final String motivationMessage;
  final VoidCallback? onCompleteNow;

  const ProfileCompletionCard({
    super.key,
    required this.completionPercent,
    required this.missingItems,
    required this.motivationMessage,
    this.onCompleteNow,
  });

  @override
  State<ProfileCompletionCard> createState() => _ProfileCompletionCardState();
}

class _ProfileCompletionCardState extends State<ProfileCompletionCard>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late AnimationController _progCtrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    )..forward();
    _progCtrl = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _progCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _ctrl,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut)),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.white, Color(0xFFF0FDF4)],
            ),
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF10B981).withOpacity(0.08),
                blurRadius: 20.r,
                offset: const Offset(0, 6),
                spreadRadius: -2,
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              SizedBox(height: 12.h),
              _buildProgress(),
              SizedBox(height: 16.h),
              _buildMissingItems(),
              SizedBox(height: 14.h),
              _buildMotivation(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedBuilder(
      animation: _progCtrl,
      builder: (_, __) => Row(
        children: [
          Expanded(
            child: Text(
              'Profile Completion: ${(widget.completionPercent * _progCtrl.value).round()}%',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 15.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF111827),
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: const Color(0xFF10B981).withOpacity(0.15),
              borderRadius: BorderRadius.circular(8.r),
              border: Border.all(
                color: const Color(0xFF10B981).withOpacity(0.4),
              ),
            ),
            child: Text(
              _getStatusText(),
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF059669),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText() => widget.completionPercent >= 80
      ? 'Almost Done'
      : widget.completionPercent >= 50
      ? 'In Progress'
      : 'Get Started';

  Widget _buildProgress() {
    return AnimatedBuilder(
      animation: _progCtrl,
      builder: (_, __) {
        final prog = (widget.completionPercent / 100) * _progCtrl.value;
        return Column(
          children: [
            Stack(
              children: [
                Container(
                  height: 10.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                FractionallySizedBox(
                  widthFactor: prog.clamp(0.0, 1.0),
                  child: Container(
                    height: 10.h,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF10B981), Color(0xFF059669)],
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${widget.missingItems.length} items left',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF6B7280),
                  ),
                ),
                Text(
                  '${(100 - widget.completionPercent).round()}% to complete',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF059669),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildMissingItems() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Missing items:',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF111827),
          ),
        ),
        SizedBox(height: 10.h),
        ...widget.missingItems.asMap().entries.map(
          (e) => Padding(
            padding: EdgeInsets.only(
              bottom: e.key == widget.missingItems.length - 1 ? 0 : 8.h,
            ),
            child: Row(
              children: [
                Container(
                  width: 16.w,
                  height: 16.w,
                  margin: EdgeInsets.only(top: 1.h),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF9CA3AF),
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Color(0xFF9CA3AF),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    e.value,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF4B5563),
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMotivation() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFECFDF5),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFF10B981).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.stars_rounded, color: const Color(0xFF059669), size: 20.w),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              widget.motivationMessage,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF047857),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
