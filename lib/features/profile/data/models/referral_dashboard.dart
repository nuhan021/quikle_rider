import 'package:flutter/foundation.dart';

class ReferralDashboard {
  const ReferralDashboard({
    required this.referralCode,
    required this.qrData,
    required this.activeCount,
    required this.pendingCount,
    required this.referrals,
  });

  final String referralCode;
  final String qrData;
  final int activeCount;
  final int pendingCount;
  final List<Map<String, dynamic>> referrals;

  factory ReferralDashboard.fromJson(Map<String, dynamic> json) {
    final rawReferrals = json['referrals'];
    final referrals = rawReferrals is List
        ? rawReferrals.whereType<Map<String, dynamic>>().toList()
        : <Map<String, dynamic>>[];

    return ReferralDashboard(
      referralCode: json['referral_code']?.toString() ?? '',
      qrData: json['qr_data']?.toString() ?? '',
      activeCount: (json['active_count'] as num?)?.toInt() ?? 0,
      pendingCount: (json['pending_count'] as num?)?.toInt() ?? 0,
      referrals: referrals,
    );
  }
}
