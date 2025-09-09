import 'package:flutter/material.dart';
import '../../../../core/common/styles/global_text_style.dart';

class ProfileField extends StatelessWidget {
  final String label;
  final String value;
  final bool showDivider;

  const ProfileField({
    super.key,
    required this.label,
    required this.value,
    this.showDivider = true, // default true
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: getTextStyle2(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: getTextStyle2(fontSize: 14, color: Colors.black54)),
          if (showDivider) const Divider(height: 20),
        ],
      ),
    );
  }
}