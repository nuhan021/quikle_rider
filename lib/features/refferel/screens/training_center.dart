// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import 'package:quikle_rider/core/widgets/shimmer/shimmer_loading.dart';
import 'package:quikle_rider/features/profile/data/models/training_resource.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:quikle_rider/features/refferel/screens/quiz_selection_page.dart';

class TrainingCenterPage extends StatefulWidget {
  const TrainingCenterPage({super.key});

  @override
  State<TrainingCenterPage> createState() => _TrainingCenterPageState();
}

class _TrainingCenterPageState extends State<TrainingCenterPage> {
  late final ProfileController _profileController;

  @override
  void initState() {
    super.initState();
    _profileController = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    Future.microtask(_loadTrainingResources);
  }

  void _loadTrainingResources() {
    _profileController.ensureTrainingResourcesLoaded();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const UnifiedProfileAppBar(title: 'Training Center',isback: true,),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            _sectionCard(
              title: 'Video Tutorials',
              child: Obx(() => _buildVideoList(
                isLoading: _profileController.isTrainingVideosLoading.value,
                error: _profileController.trainingVideosError.value,
                items: _profileController.trainingVideos,
              )),
            ),
            SizedBox(height: 16.h),
            _sectionCard(
              title: 'PDF Guides',
              child: Obx(() => _buildPdfList(
                isLoading: _profileController.isTrainingPdfsLoading.value,
                error: _profileController.trainingPdfsError.value,
                items: _profileController.trainingPdfs,
              )),
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

  Widget _emptyMessage(String message) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h),
      child: Text(
        message,
        style: getTextStyle(fontSize: 13, color: Colors.grey[600]),
      ),
    );
  }

  Widget _shimmerList() {
    return Column(
      children: List.generate(
        3,
        (_) => Padding(
          padding: EdgeInsets.only(bottom: 12.h),
          child: ShimmerLoading(
            child: Container(
              width: double.infinity,
              height: 68.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ),
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

  Widget _buildVideoList({
    required bool isLoading,
    required String? error,
    required List<TrainingResource> items,
  }) {
    if (isLoading) {
      return _shimmerList();
    }
    if (error != null && error.isNotEmpty) {
      return _emptyMessage(error);
    }
    if (items.isEmpty) {
      return _emptyMessage('No training videos available right now.');
    }
    return Column(
      children: items
          .map(
            (item) => _listTileBase(
              icon: Iconsax.play,
              iconColor: AppColors.primaryblack,
              background: AppColors.primaryyellow,
              title: item.title,
              subtitle: item.duration,
            ),
          )
          .toList(growable: false),
    );
  }

  Widget _buildPdfList({
    required bool isLoading,
    required String? error,
    required List<TrainingResource> items,
  }) {
    if (isLoading) {
      return _shimmerList();
    }
    if (error != null && error.isNotEmpty) {
      return _emptyMessage(error);
    }
    if (items.isEmpty) {
      return _emptyMessage('No PDF guides available right now.');
    }
    return Column(
      children: items
          .map(
            (item) => _listTileBase(
              icon: Icons.download,
              iconColor: AppColors.primaryyellow,
              background: AppColors.blackColor,
              title: item.title,
              subtitle: item.description,
            ),
          )
          .toList(growable: false),
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
