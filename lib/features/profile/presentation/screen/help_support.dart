// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/features/profile/data/models/help_support_request.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:quikle_rider/features/profile/presentation/widgets/profile_list_shimmer_card.dart';

class HelpSupportPage extends StatelessWidget {
  const HelpSupportPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Reuse the bound instance to avoid creating duplicates.
    final controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController(), permanent: true);
    controller.ensureSupportHistoryLoaded();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: const UnifiedProfileAppBar(title: "Help & Support"),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            _buildReportIssueSection(controller),
            const SizedBox(height: 20),
            const Padding(
              padding: EdgeInsets.only(left: 20.0),
              child: Text(
                'Recent Support History',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(
                top: 10.0,
                left: 20.0,
                bottom: 20,
                right: 20,
              ),
              child: Divider(height: 1.h, thickness: 0.5),
            ),
            _buildSupportHistorySection(controller),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // Reusable card builder, kept for consistent design.
  Widget _card({required Widget child}) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _buildReportIssueSection(ProfileController controller) {
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Report an Issue',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 20),

          // Subject Dropdown
          const Text(
            'Subject',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Obx(() {
            final selectedIssue = controller.selectedHelpIssueType.value;
            return Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey[300]!),
                borderRadius: BorderRadius.circular(8),
              ),
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  dropdownColor: Colors.white,
                  value: selectedIssue,
                  isExpanded: true,
                  icon: Icon(
                    Icons.keyboard_arrow_down,
                    color: Colors.grey[600],
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    color: selectedIssue == controller.helpIssueTypes.first
                        ? Colors.grey[600]
                        : Colors.black,
                  ),
                  onChanged: (String? newValue) {
                    if (newValue == null) return;
                    controller.updateHelpIssueType(newValue);
                  },
                  items: controller.helpIssueTypes
                      .map(
                        (v) =>
                            DropdownMenuItem<String>(value: v, child: Text(v)),
                      )
                      .toList(),
                ),
              ),
            );
          }),

          const SizedBox(height: 20),

          // Description
          const Text(
            'Description',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller.helpDescriptionController,
            maxLines: 4,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            decoration: InputDecoration(
              hintText: 'Please describe your issue in detail...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.orange),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Attachment (Optional)
          const Text(
            'Attachment (Optional)',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: controller.pickHelpAttachment,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 40),
              decoration: BoxDecoration(
                border: Border.all(
                  color: Colors.grey[300]!,
                  style: BorderStyle.solid,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.cloud_upload_outlined,
                    size: 40,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Upload a screenshot or photo',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                ],
              ),
            ),
          ),

          Obx(() {
            final attachmentName = controller.helpAttachmentName.value;
            if (attachmentName == null) {
              return const SizedBox.shrink();
            }
            return Column(
              children: [
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.attachment, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          attachmentName,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[700],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        onPressed: controller.removeHelpAttachment,
                        icon: const Icon(Icons.close, size: 18),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }),

          const SizedBox(height: 30),

          // Submit
          Obx(() {
            final isSubmitting = controller.isSubmittingHelpSupport.value;
            final isVerified = controller.isVerified.value == true;
            final isDisabled = isSubmitting || !isVerified;
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isDisabled
                    ? null
                    : () => controller.submitHelpSupportForm(),
                style: ElevatedButton.styleFrom(
                  side: BorderSide.none,
                  backgroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 0,
                ),
                child: isSubmitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.white,
                          ),
                        ),
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (!isVerified) ...[
                            const Icon(
                              Icons.lock_outline,
                              size: 18,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 8),
                          ],
                          const Text(
                            'Submit Issue',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
              ),
            );
          }),
        ],
      ),
    );
  }
  Widget _buildSupportHistorySection(ProfileController controller) {
    return Obx(() {
      final isLoading = controller.isSupportHistoryLoading.value;
      final error = controller.supportHistoryError.value;
      final history = controller.supportHistory;

      if (isLoading) {
        return Column(
          children: List.generate(
            3,
            (index) => const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: ProfileListShimmerCard(
                margin: EdgeInsets.symmetric(horizontal: 20),
                lineWidths: <double>[180, 120, 220, 200],
                showStatusBadge: true,
              ),
            ),
          ),
        );
      }

      if (error != null && error.isNotEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _card(
            child: Text(
              error,
              style: const TextStyle(color: Colors.red, fontSize: 14),
            ),
          ),
        );
      }

      if (history.isEmpty) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _card(
            child: Text(
              'No support requests yet.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ),
        );
      }

      return Column(
        children: history
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: SizedBox(
                  width: double.infinity,
                  child: _card(child: _buildSupportHistoryItem(item)),
                ),
              ),
            )
            .toList(),
      );
    });
  }

  Widget _buildSupportHistoryItem(HelpSupportRequest item) {
    final createdAt = _formatDate(item.createdAt);
    final status = item.resolvedAt == null ? 'Pending' : 'Resolved';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.subject,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          createdAt,
          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Text(
          item.description,
          style: TextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color:
                  status == 'Resolved' ? Colors.green.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              status,
              style: TextStyle(
                color: status == 'Resolved' ? Colors.green[800] : Colors.orange[800],
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(String raw) {
    final parsed = DateTime.tryParse(raw);
    if (parsed == null) return raw;
    return 'Submitted on ${parsed.day.toString().padLeft(2, '0')} '
        '${_monthName(parsed.month)} ${parsed.year}';
  }

  String _monthName(int month) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    return months[(month - 1).clamp(0, months.length - 1)];
  }
}
