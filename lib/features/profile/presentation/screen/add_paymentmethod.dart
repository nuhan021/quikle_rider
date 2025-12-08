// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';
import 'package:quikle_rider/features/profile/presentation/controller/withdraw_controller.dart';
import 'package:quikle_rider/features/wallet/controllers/wallet_controller.dart';

class AddPaymentMethodPage extends StatefulWidget {
  const AddPaymentMethodPage({super.key});

  @override
  State<AddPaymentMethodPage> createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
  late final WithdrawController _withdrawController;
  final WalletController controller = Get.find<WalletController>();

  @override
  void initState() {
    super.initState();
    _withdrawController = Get.put(WithdrawController());
    controller.fetchWithdrawalHistory();
  }

  @override
  void dispose() {
    Get.delete<WithdrawController>();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: const UnifiedProfileAppBar(title: 'Add Payment Method',isback: true,),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _balanceCard(),
            SizedBox(height: 20.h),
            _bankDetailsCard(),
            SizedBox(height: 20.h),

            // _withdrawalSettingsCard(),
            SizedBox(height: 20.h),
            _withdrawalHistoryCard(),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard() {
    return Obx(
      () => Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Current Balance',
                    style: getTextStyle(fontSize: 16, color: Colors.grey[700]),
                  ),
                ),
                _pillBadge(label: 'Available', color: AppColors.primarygreen),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              controller.currentBalance.value.toString(),
              style: getTextStyle(fontSize: 32, fontWeight: FontWeight.w700),
            ),
            SizedBox(height: 4.h),
            Text(
              'Minimum withdrawal: ₹500',
              style: getTextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bankDetailsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Bank Account Details',
                style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              _pillBadge(label: 'Verified', color: AppColors.primarygreen),
            ],
          ),
          SizedBox(height: 20.h),
          _textField(
            label: 'Account Holder Name',
            controller: _withdrawController.holderNameController,
            helper: 'Must match KYC documents',
          ),
          SizedBox(height: 16.h),
          _textField(
            label: 'Bank Account Number',
            controller: _withdrawController.accountNumberController,
            suffix: IconButton(
              icon: const Icon(Icons.visibility_outlined, size: 18),
              onPressed: () {},
            ),
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 16.h),
          _textField(
            label: 'IFSC Code',
            controller: _withdrawController.ifscController,
            textCapitalization: TextCapitalization.characters,
          ),
          SizedBox(height: 16.h),

          Obx(() {
            final isSubmitting = _withdrawController.isSubmitting.value;
            return SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isSubmitting ? null : _submitBankDetails,
                style: ElevatedButton.styleFrom(
                  side: BorderSide.none,
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 14.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                ),
                child: isSubmitting
                    ? SizedBox(
                        height: 20.h,
                        width: 20.h,
                        child: const CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Save Changes',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
              ),
            );
          }),
          SizedBox(height: 20.h),
          _beneficiaryListSection(),
        ],
      ),
    );
  }

  Widget _beneficiaryListSection() {
    return Obx(() {
      final isLoading = _withdrawController.isFetchingBeneficiaries.value;
      final beneficiaries = _withdrawController.beneficiaries;
      final selectedId = _withdrawController.selectedBeneficiaryId.value;
      final hasSelection = selectedId != null;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Saved Beneficiaries',
                style: getTextStyle(fontSize: 15, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              IconButton(
                onPressed: isLoading
                    ? null
                    : _withdrawController.fetchBeneficiaries,
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh list',
              ),
            ],
          ),
          if (isLoading)
            const Center(child: CircularProgressIndicator())
          else if (beneficiaries.isEmpty)
            Padding(
              padding: EdgeInsets.only(top: 8.h),
              child: Text(
                'No beneficiaries found. Add one above to start withdrawing.',
                style: getTextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            )
          else ...[
            ...beneficiaries.map((item) {
              final id = item['id'] as int?;
              final holder = item['bank_holder_name']?.toString() ?? '';
              final account = item['bank_account_number']?.toString() ?? 'N/A';
              final ifsc = item['bank_ifsc']?.toString() ?? 'N/A';
              final isVerified = item['is_bank_verified'] == true;

              return Container(
                margin: EdgeInsets.only(bottom: 10.h),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color: selectedId == id
                        ? AppColors.primarygreen
                        : Colors.grey[200]!,
                  ),
                ),
                child: ListTile(
                  onTap: id == null
                      ? null
                      : () => _withdrawController.selectedBeneficiaryId.value =
                            id,
                  leading: Radio<int>(
                    value: id ?? -1,
                    groupValue: selectedId,
                    onChanged: (value) =>
                        _withdrawController.selectedBeneficiaryId.value = value,
                    activeColor: AppColors.primarygreen,
                  ),
                  title: Text(
                    holder,
                    style: getTextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Acc: $account',
                        style: getTextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                      Text(
                        'IFSC: $ifsc',
                        style: getTextStyle(
                          fontSize: 12,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                  trailing: _pillBadge(
                    label: isVerified ? 'Verified' : 'Pending',
                    color: isVerified
                        ? AppColors.primarygreen
                        : AppColors.primaryyellow,
                  ),
                ),
              );
            }),
            if (hasSelection) ...[
              SizedBox(height: 10.h),
              _textField(
                label: 'Withdrawal Amount',
                controller: _withdrawController.withdrawalAmountController,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
              ),
              SizedBox(height: 12.h),
              SizedBox(
                width: double.infinity,
                child: Obx(() {
                  final isRequesting =
                      _withdrawController.isRequestingWithdrawal.value;
                  return ElevatedButton(
                    onPressed: isRequesting ? null : _submitWithdrawalRequest,
                    style: ElevatedButton.styleFrom(
                      side: BorderSide.none,
                      backgroundColor: Colors.black,
                      foregroundColor: Colors.white,
                      padding: EdgeInsets.symmetric(vertical: 14.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: isRequesting
                        ? SizedBox(
                            height: 20.h,
                            width: 20.h,
                            child: const CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Withdraw',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  );
                }),
              ),
            ],
          ],
          Obx(() {
            final success = _withdrawController.successMessage.value;
            final error = _withdrawController.lastError.value;
            final lastData = _withdrawController.lastWithdrawalData.value;
            if (success == null && error == null && lastData == null) {
              return const SizedBox.shrink();
            }
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (success != null || error != null)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 12.h),
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color:
                          (error != null ? Colors.red[50] : Colors.green[50]) ??
                          Colors.green[50],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: error != null
                            ? Colors.redAccent.withOpacity(0.4)
                            : AppColors.primarygreen.withOpacity(0.4),
                      ),
                    ),
                    child: Text(
                      error ?? success ?? '',
                      style: getTextStyle(
                        fontSize: 13,
                        color: error != null
                            ? Colors.redAccent
                            : Colors.green[800],
                      ),
                    ),
                  ),
                if (lastData != null)
                  Container(
                    width: double.infinity,
                    margin: EdgeInsets.only(top: 10.h),
                    padding: EdgeInsets.all(14.w),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Latest Withdrawal',
                          style: getTextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'ID: ${lastData['id'] ?? ''}',
                          style: getTextStyle(fontSize: 12),
                        ),
                        Text(
                          'Amount: ${lastData['amount'] ?? ''}',
                          style: getTextStyle(fontSize: 12),
                        ),
                        Text(
                          'Status: ${lastData['status'] ?? ''}',
                          style: getTextStyle(fontSize: 12),
                        ),
                        Text(
                          'Created: ${lastData['created_at'] ?? ''}',
                          style: getTextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                  ),
              ],
            );
          }),
        ],
      );
    });
  }

  Widget _withdrawalHistoryCard() {
    return Obx(() {
      final history = controller.withdrawalHistory;
      final isLoading = controller.isWithdrawalHistoryLoading.value;
      final error = controller.withdrawalHistoryError.value;
      final count = controller.withdrawalHistoryCount.value;

      return Container(
        width: double.infinity,
        padding: EdgeInsets.all(20.w),
        decoration: _cardDecoration(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(
                  'Withdrawal History',
                  style: getTextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.sync),
                  tooltip: 'Refresh history',
                  onPressed: isLoading
                      ? null
                      : () => controller.fetchWithdrawalHistory(),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (error != null && error.isNotEmpty)
              Text(
                error,
                style: getTextStyle(fontSize: 12, color: Colors.redAccent),
              )
            else if (history.isEmpty)
              Text(
                'No withdrawal history available.',
                style: getTextStyle(fontSize: 12, color: Colors.grey[600]),
              )
            else ...[
              if (count != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Text(
                    'Total: $count',
                    style:
                        getTextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ),
              ...history.map((item) {
                return _historyTile(
                  _WithdrawalEntry(
                    amount: item['amount']?.toString() ?? '',
                    date: item['created_at']?.toString() ?? '',
                    status: item['status']?.toString() ?? '',
                    transactionId: item['id']?.toString() ?? '',
                  ),
                );
              }).toList(),
            ],
          ],
        ),
      );
    });
  }

  Widget _historyTile(_WithdrawalEntry entry) {
    final statusColor = _statusColor(entry.status);
    final statusIcon = _statusIcon(entry.status);
    final parsedDate = DateTime.tryParse(entry.date);

    return Container(
      margin: EdgeInsets.only(bottom: 12.h), // Margin outside the card
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.08),
            spreadRadius: 2,
            blurRadius: 10,
            offset: const Offset(0, 2), // changes position of shadow
          ),
        ],
        border: Border.all(color: Colors.grey[100]!), // Very subtle border
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start, // Align to top
          children: [
            // 1. Leading Icon Container
            Container(
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1), // Light pastel background
                shape: BoxShape.circle,
              ),
              child: Icon(statusIcon, color: statusColor, size: 24.r),
            ),

            SizedBox(width: 16.w), // Spacing between icon and text
            // 2. Middle Section (Amount & Details)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Amount
                  Text(
                    "₹${entry.amount}",
                    style: getTextStyle(
                      fontSize: 18, // Slightly larger
                      fontWeight: FontWeight.bold, // Bolder
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 6.h),

                  // Date
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 12.r,
                        color: Colors.grey[500],
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        parsedDate != null
                            ? DateFormat('dd MMM, yyyy').format(parsedDate)
                            : entry.date,
                        style: getTextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),

                  // Transaction ID (Conditional)
                  if (entry.transactionId.isNotEmpty) ...[
                    SizedBox(height: 6.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        'ID: ${entry.transactionId}',
                        style: getTextStyle(
                          fontSize: 11, // Smaller, monospace-ish feel
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // 3. Status Badge (Right aligned)
            Padding(
              padding: EdgeInsets.only(left: 8.w),
              child: _pillBadge(label: entry.status, color: statusColor),
            ),
          ],
        ),
      ),
    );
  }

  Color _statusColor(String status) {
    final value = status.toLowerCase();
    if (value.contains('fail')) return Colors.redAccent;
    if (value.contains('pend')) return Colors.amber;
    if (value.contains('success') || value.contains('complete')) {
      return AppColors.primarygreen;
    }
    return Colors.grey;
  }

  IconData _statusIcon(String status) {
    final value = status.toLowerCase();
    if (value.contains('fail')) return Icons.error_rounded;
    if (value.contains('pend')) return Icons.pending_actions_rounded;
    return Icons.check_circle_rounded;
  }

  Widget _pillBadge({required String label, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: getTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ).copyWith(color: AppColors.background),
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? helper,
    Widget? suffix,
    TextInputType? keyboardType,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: getTextStyle(fontSize: 13, color: Colors.grey[700])),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          decoration: InputDecoration(
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.grey[100],

            // Border when not focused (no border)
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12.r),
            ),

            // Border when focused (shows border)
            focusedBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.black, width: 2),
              borderRadius: BorderRadius.circular(12.r),
            ),

            // Border when there's an error
            errorBorder: OutlineInputBorder(
              borderSide: BorderSide.none,
              borderRadius: BorderRadius.circular(12.r),
            ),

            // Border when focused with error
            focusedErrorBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.red, width: 2),
              borderRadius: BorderRadius.circular(12.r),
            ),

            contentPadding: EdgeInsets.symmetric(
              horizontal: 14.w,
              vertical: 14.h,
            ),
          ),
        ),
        if (helper != null) ...[
          SizedBox(height: 6.h),
          Text(
            helper,
            style: getTextStyle(fontSize: 11, color: Colors.grey[500]),
          ),
        ],
      ],
    );
  }

  void _submitBankDetails() {
    FocusScope.of(context).unfocus();
    _withdrawController.submitBankDetails();
  }

  void _submitWithdrawalRequest() {
    FocusScope.of(context).unfocus();
    _withdrawController.requestWithdrawal();
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      border: Border.all(color: Colors.grey[200]!),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.04),
          blurRadius: 10,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }
}

class _WithdrawalEntry {
  final String amount;
  final String date;
  final String status;
  final String transactionId;

  const _WithdrawalEntry({
    required this.amount,
    required this.date,
    required this.status,
    this.transactionId = '',
  });
}
