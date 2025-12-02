// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import 'package:quikle_rider/features/refferel/screens/quiz_selection_page.dart';

class TrainingCenterPage extends StatelessWidget {
  TrainingCenterPage({super.key});

  final List<_TrainingItem> _videos = const [
    _TrainingItem(title: 'Getting Started', subtitle: '5:30'),
    _TrainingItem(title: 'Accepting Orders', subtitle: '5:30'),
    _TrainingItem(title: 'Customer Service Tips', subtitle: '5:30'),
    _TrainingItem(title: 'Safety Guidelines', subtitle: '5:30'),
  ];

  final List<_TrainingItem> _guides = const [
    _TrainingItem(title: 'Partner Handbook'),
    _TrainingItem(title: 'Safety Protocols'),
    _TrainingItem(title: 'Food Handling Guide'),
    _TrainingItem(title: 'Medicine Delivery Rules'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const UnifiedProfileAppBar(title: 'Training Center'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _sectionCard(
              title: 'Video Tutorials',
              child: Column(
                children: _videos
                    .map((item) => _videoTile(item))
                    .toList(growable: false),
              ),
            ),
            SizedBox(height: 16.h),
            _sectionCard(
              title: 'PDF Guides',
              child: Column(
                children: _guides
                    .map((item) => _guideTile(item))
                    .toList(growable: false),
              ),
            ),
            SizedBox(height: 16.h),
            _quizCard(),
          ],
        ),
      ),
    );
  }

  Widget _sectionCard({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          child,
        ],
      ),
    );
  }

  Widget _listTileBase({
    required IconData icon,
    required Color iconColor,
    required Color background,
    required String title,
    String? subtitle,
    Widget? trailing,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            alignment: Alignment.center,
            width: 40.w,
            height: 40.w,
            decoration: BoxDecoration(
              color: background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: iconColor, size: 18.sp),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: getTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (subtitle != null) ...[
                  SizedBox(height: 4.h),
                  Text(
                    subtitle,
                    style: getTextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _videoTile(_TrainingItem item) => _listTileBase(
    icon: Iconsax.play,
    iconColor: AppColors.primaryblack,
    background: AppColors.primaryyellow,
    title: item.title,
    subtitle: item.subtitle,
  );

  Widget _guideTile(_TrainingItem item) {
    return _listTileBase(
      icon: Icons.download,
      iconColor: AppColors.primaryyellow,
      background: AppColors.blackColor,
      title: item.title,
    );
  }

  Widget _quizCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Certification Quiz',
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
            decoration: BoxDecoration(
              color: Colors.grey[200],
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              'Complete to unlock Gold tier',
              textAlign: TextAlign.center,
              style: getTextStyle(fontSize: 13, color: Colors.grey[700]),
            ),
          ),
          SizedBox(height: 12.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () => Get.to(() => const QuizSelectionPage()),
              child: Text(
                'Start Quiz',
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ).copyWith(color: AppColors.primaryyellow),
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _scoreTile(label: 'Your Score', value: '85%'),
              _scoreTile(label: 'Pass Mark', value: '80%'),
            ],
          ),
          SizedBox(height: 16.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                side: BorderSide.none,
                backgroundColor: AppColors.greenbutton2,

                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              onPressed: () {},
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.verified, color: Colors.white, size: 18.sp),
                  SizedBox(width: 8.w),
                  Text(
                    'Cirtifite Partner',
                    style: getTextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ).copyWith(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scoreTile({required String label, required String value}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: getTextStyle(fontSize: 12, color: Colors.grey[600])),
        SizedBox(height: 4.h),
        Text(
          value,
          style: getTextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}

class _TrainingItem {
  final String title;
  final String? subtitle;

  const _TrainingItem({required this.title, this.subtitle});
}
