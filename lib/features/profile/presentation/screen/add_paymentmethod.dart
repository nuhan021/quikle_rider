import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/core/utils/constants/colors.dart';

class AddPaymentMethodPage extends StatefulWidget {
  const AddPaymentMethodPage({super.key});

  @override
  State<AddPaymentMethodPage> createState() => _AddPaymentMethodPageState();
}

class _AddPaymentMethodPageState extends State<AddPaymentMethodPage> {
  final TextEditingController _nameController =
      TextEditingController(text: 'Vikram Rajput');
  final TextEditingController _accountController =
      TextEditingController(text: 'XXXXXXXXXX3456');
  final TextEditingController _ifscController =
      TextEditingController(text: 'HDFC0001234');
  final TextEditingController _upiController =
      TextEditingController(text: 'ananya@paytm');
  bool _autoWithdrawal = false;

  final List<_WithdrawalEntry> _history = const [
    _WithdrawalEntry(amount: '₹2,500', date: '25 Oct 2024', status: 'Completed'),
    _WithdrawalEntry(amount: '₹1,500', date: '18 Oct 2024', status: 'Completed'),
    _WithdrawalEntry(amount: '₹3,000', date: '11 Oct 2024', status: 'Completed'),
    _WithdrawalEntry(amount: '₹800', date: '4 Oct 2024', status: 'Processing'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F7F7),
      appBar: const UnifiedProfileAppBar(title: 'Add Payment Method'),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _balanceCard(),
            SizedBox(height: 20.h),
            _bankDetailsCard(),
            SizedBox(height: 20.h),
            _withdrawalSettingsCard(),
            SizedBox(height: 20.h),
            _withdrawalHistoryCard(),
          ],
        ),
      ),
    );
  }

  Widget _balanceCard() {
    return Container(
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
            '₹3,250',
            style: getTextStyle(fontSize: 32, fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 4.h),
          Text(
            'Minimum withdrawal: ₹500',
            style: getTextStyle(fontSize: 13, color: Colors.grey[600]),
          ),
        ],
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
            controller: _nameController,
            helper: 'Must match KYC documents',
          ),
          SizedBox(height: 16.h),
          _textField(
            label: 'Bank Account Number',
            controller: _accountController,
            suffix: IconButton(
              icon: const Icon(Icons.visibility_outlined, size: 18),
              onPressed: () {},
            ),
          ),
          SizedBox(height: 16.h),
          _textField(
            label: 'IFSC Code',
            controller: _ifscController,
          ),
          SizedBox(height: 16.h),
          _textField(
            label: 'UPI ID (Optional)',
            controller: _upiController,
            helper: 'For instant withdrawals',
          ),
          SizedBox(height: 20.h),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
              child: const Text(
                'Save Changes',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _withdrawalSettingsCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Withdrawal Settings',
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: AppColors.primary),
            ),
            child: Row(
              children: [
                const Icon(Icons.schedule_outlined, color: Colors.orange),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Processing Time',
                        style: getTextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '24-48 hours',
                        style: getTextStyle(fontSize: 12, color: Colors.grey[700]),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: const Icon(Icons.calendar_today_outlined),
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Auto-withdrawal',
                      style: getTextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      _autoWithdrawal ? 'Enabled' : 'Manual',
                      style: getTextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _autoWithdrawal,
                onChanged: (value) =>
                    setState(() => _autoWithdrawal = value),
                activeColor: AppColors.primarygreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _withdrawalHistoryCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Withdrawal History',
            style: getTextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 16.h),
          ..._history.map((entry) => _historyTile(entry)).toList(),
        ],
      ),
    );
  }

  Widget _historyTile(_WithdrawalEntry entry) {
    final color = entry.status == 'Completed'
        ? AppColors.primarygreen
        : AppColors.primaryyellow;
    return Padding(
      padding: EdgeInsets.only(bottom: 14.h),
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                entry.amount,
                style: getTextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                entry.date,
                style: getTextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
          const Spacer(),
          _pillBadge(label: entry.status, color: color),
        ],
      ),
    );
  }

  Widget _pillBadge({required String label, required Color color}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(
        label,
        style: getTextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ).copyWith(color: color),
      ),
    );
  }

  Widget _textField({
    required String label,
    required TextEditingController controller,
    String? helper,
    Widget? suffix,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: getTextStyle(fontSize: 13, color: Colors.grey[700]),
        ),
        SizedBox(height: 6.h),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            suffixIcon: suffix,
            filled: true,
            fillColor: Colors.grey[100],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
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

  const _WithdrawalEntry({
    required this.amount,
    required this.date,
    required this.status,
  });
}
