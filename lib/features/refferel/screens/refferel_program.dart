// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import 'package:quikle_rider/features/profile/presentation/controller/referral_controller.dart';
import 'package:quikle_rider/features/refferel/widgets/reffer_shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

class ReferralProgramPage extends StatefulWidget {
  const ReferralProgramPage({super.key});

  @override
  State<ReferralProgramPage> createState() => _ReferralProgramPageState();
}

class _ReferralProgramPageState extends State<ReferralProgramPage> {
  late final ReferralController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ReferralController>()
        ? Get.find<ReferralController>()
        : Get.put(ReferralController());
    _loadReferralData();
  }

  Future<void> _loadReferralData() async {
    await Future.wait([
      _controller.fetchReferralDashboard(),
      _controller.fetchReferralQrImage(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const UnifiedProfileAppBar(
        title: 'Referral Program',
        isback: true,
      ),
      body: Obx(() {
        final dashboard = _controller.referralDashboard.value;
        final isLoading = _controller.isReferralDashboardLoading.value;
        final error = _controller.referralDashboardError.value;

        if (isLoading && dashboard == null) {
          return const ReferralShimmer();
        }

        if (error != null && error.isNotEmpty && dashboard == null) {
          return _ErrorState(message: error, onRetry: _loadReferralData);
        }

        return RefreshIndicator(
          onRefresh: _loadReferralData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                _highlightCard(),
                SizedBox(height: 16.h),
                _codeCard(
                  context,
                  referralCode: dashboard?.referralCode ?? '-- -- --',
                  qrImage: _controller.referralQrImage.value,
                  isQrLoading: _controller.isReferralQrLoading.value,
                  qrError: _controller.referralQrError.value,
                ),
                SizedBox(height: 16.h),
                _statsRow(
                  active: dashboard?.activeCount ?? 0,
                  pending: dashboard?.pendingCount ?? 0,
                  total: dashboard?.referrals.length ?? 0,
                ),
                SizedBox(height: 16.h),
                _referralListCard(dashboard?.referrals ?? const []),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _highlightCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Earn ₹500 per successful referral!',
            style: getTextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.primaryblack,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'Bonus: ₹2,000 for 5 referrals/month',
            style: getTextStyle(
              fontSize: 14,
              color: AppColors.primaryblack.withValues(alpha: 0.85),
            ),
          ),
        ],
      ),
    );
  }

  Widget _codeCard(
    BuildContext context, {
    required String referralCode,
    required Uint8List? qrImage,
    required bool isQrLoading,
    required String? qrError,
  }) {
    final canCopy =
        referralCode.trim().isNotEmpty && referralCode != '-- -- --';

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            'Your Referral Code',
            style: getTextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                referralCode,
                style: getTextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primarygreen,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.copy_rounded, size: 20),
                onPressed: canCopy
                    ? () async {
                        await Clipboard.setData(
                          ClipboardData(text: referralCode),
                        );
                        
                      }
                    : null,
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Container(
            width: 140.w,
            height: 140.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: AppColors.primaryyellow),
            ),
            alignment: Alignment.center,
            child: _buildQrContent(
              qrImage: qrImage,
              isLoading: isQrLoading,
              error: qrError,
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _shareButton(
                  label: 'WhatsApp',
                  color: AppColors.primarygreen,
                  icon: Iconsax.message_2,
                  onTap: () => _shareToWhatsApp(referralCode),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _shareButton(
                  label: 'SMS',
                  color: Colors.black,
                  icon: Iconsax.message_2,
                  onTap: () => _shareToSms(referralCode),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQrContent({
    required Uint8List? qrImage,
    required bool isLoading,
    required String? error,
  }) {
    if (isLoading) {
      return Center(
        child: LoadingAnimationWidget.inkDrop(
          color: AppColors.gradientColor,
          size: 30.w,
        ),
      );
    }

    if (qrImage != null) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Image.memory(qrImage, fit: BoxFit.cover),
      );
    }

    if (error != null && error.isNotEmpty) {
      return Padding(
        padding: EdgeInsets.all(12.w),
        child: Text(
          error,
          style: getTextStyle(fontSize: 12, color: Colors.red[700]),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Icon(Icons.qr_code_rounded, size: 90.sp, color: Colors.black87);
  }

  Widget _shareButton({
    required String label,
    required Color color,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        side: BorderSide.none,
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: EdgeInsets.symmetric(vertical: 12.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        elevation: 0,
      ),
      onPressed: onTap,
      icon: Icon(icon, size: 18.sp),
      label: Text(
        label,
        style: getTextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ).copyWith(color: Colors.white),
      ),
    );
  }

  Widget _statsRow({
    required int active,
    required int pending,
    required int total,
  }) {
    final stats = <_ReferralStat>[
      _ReferralStat(value: active.toString(), label: 'Active'),
      _ReferralStat(value: pending.toString(), label: 'Pending'),
      _ReferralStat(value: total.toString(), label: 'Total'),
    ];

    return Row(
      children: stats
          .map(
            (stat) => Expanded(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 6.w),
                padding: EdgeInsets.symmetric(vertical: 16.h),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: Colors.grey[200]!),
                ),
                child: Column(
                  children: [
                    Text(
                      stat.value,
                      style: getTextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Text(
                      stat.label,
                      style: getTextStyle(
                        fontSize: 13,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _referralListCard(List<Map<String, dynamic>> referrals) {
       final dashboard = _controller.referralDashboard.value;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Referral List',
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          if (referrals.isEmpty)
            Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Text(
                'No referrals yet.',
                style: getTextStyle(fontSize: 14, color: Colors.grey[600]),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: referrals.length,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (_, index) => _referralTile(referrals[index]),
            ),
          SizedBox(height: 20.h),
          Row(
            children: [
              Expanded(
                child: _shareButton(
                  label: 'WhatsApp',
                  color: AppColors.primarygreen,
                  icon: Iconsax.message,
                  onTap: () => _shareToWhatsApp(dashboard?.referralCode ?? ''),
                ),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: _shareButton(
                  label: 'SMS',
                  color: Colors.black,
                  icon: Icons.sms_outlined,
                  onTap: () => _shareToSms(dashboard?.referralCode ?? ''),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _referralTile(Map<String, dynamic> data) {
    final name =
        (data['name'] ??
                data['full_name'] ??
                data['referral_name'] ??
                'Referral')
            .toString();
    final status = (data['status'] ?? data['state'] ?? 'Pending').toString();
    final amountValue = data['amount'] ?? data['reward'] ?? data['bonus'];
    final amount = amountValue == null ? '' : amountValue.toString();
    final color = _statusColor(status);
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: getTextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 6.h),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 6.h,
                  ),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    status,
                    style: getTextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ).copyWith(color: AppColors.background),
                  ),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return AppColors.primarygreen;
      case 'pending':
        return AppColors.warning;
      default:
        return AppColors.secondarygrey;
    }
  }

  Future<void> _shareToWhatsApp(String referralCode) async {
    final code = referralCode.trim();
    if (code.isEmpty || code == '-- -- --') {
      Get.snackbar(
        'Referral code missing',
        'Please wait for your code to load.',
        backgroundColor: Colors.orangeAccent.withValues(alpha: 0.2),
        colorText: Colors.black,
      );
      return;
    }
    final text = Uri.encodeComponent(
      'Join Quikle using my referral code: $code',
    );
    final uri = Uri.parse('https://wa.me/?text=$text');
    final canLaunch = await canLaunchUrl(uri);
    if (canLaunch) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      Get.snackbar(
        'WhatsApp not available',
        'Could not open WhatsApp on this device.',
        backgroundColor: Colors.red.withValues(alpha: 0.15),
        colorText: Colors.red[900],
      );
    }
  }

  Future<void> _shareToSms(String referralCode) async {
    final code = referralCode.trim();
    if (code.isEmpty || code == '-- -- --') {
      Get.snackbar(
        'Referral code missing',
        'Please wait for your code to load.',
        backgroundColor: Colors.orangeAccent.withValues(alpha: 0.2),
        colorText: Colors.black,
      );
      return;
    }
    final body = Uri.encodeComponent(
      'Join Quikle using my referral code: $code',
    );
    // sms: scheme supports optional recipient; we leave blank to let user choose.
    final uri = Uri.parse('sms:?body=$body');
    final canLaunch = await canLaunchUrl(uri);
    if (canLaunch) {
      await launchUrl(uri);
    } else {
      Get.snackbar(
        'SMS not available',
        'Could not open messaging app on this device.',
        backgroundColor: Colors.red.withValues(alpha: 0.15),
        colorText: Colors.red[900],
      );
    }
  }
}

class _ReferralStat {
  final String value;
  final String label;

  const _ReferralStat({required this.value, required this.label});
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.info_outline, size: 48, color: Colors.redAccent),
            const SizedBox(height: 12),
            Text(
              'Unable to load referral details',
              style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: getTextStyle(fontSize: 14, color: Colors.grey[700]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}
