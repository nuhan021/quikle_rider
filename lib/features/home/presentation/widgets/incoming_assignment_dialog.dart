import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:quikle_rider/features/home/models/home_dashboard_models.dart';
import 'package:quikle_rider/features/home/presentation/widgets/assignment_card.dart';

class IncomingAssignmentDialog extends StatelessWidget {
  final Assignment assignment;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const IncomingAssignmentDialog({
    super.key,
    required this.assignment,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      backgroundColor: Colors.transparent,
      child: Center(
        child: AssignmentCard(
          deleverystatus: assignment.deleverystatus,
          orderId: assignment.id,
          customerName: assignment.customerName,
          arrivalTime: assignment.formattedArrival,
          address: assignment.address,
          distance: assignment.formattedDistance,
          total: assignment.formattedTotal,
          breakdown: assignment.formattedBreakdown,
          isUrgent: assignment.isUrgent,
          isCombined: assignment.isCombined,
          status: assignment.status,
          onAccept: onAccept,
          onReject: onReject,
        ),
      ),
    );
  }
}
