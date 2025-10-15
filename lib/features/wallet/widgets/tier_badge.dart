import 'package:flutter/material.dart';

class TierBadge extends StatelessWidget {
  final String tier;

  const TierBadge({Key? key, required this.tier}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final tierData = _getTierData();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: tierData['color'],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: tierData['color'].withOpacity(0.3),
            blurRadius: 6,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(tierData['icon'], color: Colors.white, size: 16),
          SizedBox(width: 4),
          Text(
            tier,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Map<String, dynamic> _getTierData() {
    switch (tier.toLowerCase()) {
      case 'bronze':
        return {'color': Color(0xFFCD7F32), 'icon': Icons.military_tech};
      case 'silver':
        return {'color': Color(0xFFC0C0C0), 'icon': Icons.workspace_premium};
      case 'gold':
        return {'color': Color(0xFFFFD700), 'icon': Icons.emoji_events};
      default:
        return {'color': Colors.grey, 'icon': Icons.card_membership};
    }
  }
}
