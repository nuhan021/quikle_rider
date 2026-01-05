// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:quikle_rider/features/wallet/models/bonus_tracking_models.dart';

// class MonthlyTopPerformerCard extends StatelessWidget {
//   final int? currentRank;
//   final int? totalDeliveries;
//   final int? totalParticipants;
//   final String prize;
//   final int? score;
//   final String payoutDate;
//   final List<ScoreBreakdown> scoreBreakdown;
//   final List<PrizeTier> prizeTiers;
//   final VoidCallback? onViewLeaderboard;

//   const MonthlyTopPerformerCard({
//     Key? key,
//     required this.currentRank,
//     required this.totalDeliveries,
//     required this.totalParticipants,
//     required this.prize,
//     required this.score,
//     required this.payoutDate,
//     required this.scoreBreakdown,
//     required this.prizeTiers,
//     this.onViewLeaderboard,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(16.w),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(16.r),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withOpacity(0.06),
//             blurRadius: 10.r,
//             offset: Offset(0, 4.h),
//           ),
//         ],
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: EdgeInsets.all(8.w),
//                 decoration: BoxDecoration(
//                   color: Colors.purple.shade50,
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//                 child: Icon(
//                   Icons.emoji_events_rounded,
//                   color: Colors.purple.shade600,
//                   size: 20.w,
//                 ),
//               ),
//               SizedBox(width: 10.w),
//               Text(
//                 'Monthly Top Performer',
//                 style: TextStyle(
//                   fontSize: 14.sp,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 16.h),
//           Row(
//             children: [
//               Expanded(
//                 child: _StatCard(
//                   label: 'Current Rank',
//                   value: currentRank != null && totalParticipants != null
//                       ? '#$currentRank of $totalParticipants'
//                       : '--',
//                   icon: Icons.military_tech_rounded,
//                   color: Colors.amber,
//                 ),
//               ),
//               SizedBox(width: 10.w),
//               Expanded(
//                 child: _StatCard(
//                   label: 'Total Deliveries',
//                   value: totalDeliveries?.toString() ?? '--',
//                   icon: Icons.inventory_2_rounded,
//                   color: Colors.blue,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10.h),
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(12.w),
//             decoration: BoxDecoration(
//               color: Colors.amber.shade50,
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Prize Money',
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         color: Colors.black54,
//                       ),
//                     ),
//                     Text(
//                       prize,
//                       style: TextStyle(
//                         fontSize: 20.sp,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.amber.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Icon(
//                   Icons.card_giftcard_rounded,
//                   color: Colors.amber.shade700,
//                   size: 28.w,
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 12.h),
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(12.w),
//             decoration: BoxDecoration(
//               color: Colors.purple.shade50,
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       score != null ? 'Score: $score points' : 'Score data unavailable',
//                       style: TextStyle(
//                         fontSize: 14.sp,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.purple.shade700,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 ...scoreBreakdown.asMap().entries.map(
//                   (entry) => Padding(
//                     padding: EdgeInsets.only(
//                       bottom: entry.key == scoreBreakdown.length - 1 ? 0 : 6.h,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Expanded(
//                           child: Text(
//                             '${entry.value.title} (${entry.value.formula})',
//                             style: TextStyle(
//                               fontSize: 12.sp,
//                               color: Colors.purple.shade700,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),
//                         ),
//                         SizedBox(width: 12.w),
//                         Text(
//                           entry.value.points,
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: Colors.black87,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 12.h),
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(12.w),
//             decoration: BoxDecoration(
//               color: Colors.grey.shade50,
//               borderRadius: BorderRadius.circular(12.r),
//               border: Border.all(color: Colors.grey.shade200),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Monthly Prize Structure',
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: 8.h),
//                 ...prizeTiers.asMap().entries.map(
//                   (entry) => Padding(
//                     padding: EdgeInsets.only(
//                       bottom: entry.key == prizeTiers.length - 1 ? 0 : 6.h,
//                     ),
//                     child: Row(
//                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                       children: [
//                         Text(
//                           entry.value.rankLabel,
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: Colors.black54,
//                             fontWeight: FontWeight.w600,
//                           ),
//                         ),
//                         Text(
//                           entry.value.reward,
//                           style: TextStyle(
//                             fontSize: 12.sp,
//                             color: Colors.black87,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//                 SizedBox(height: 10.h),
//                 Text(
//                   payoutDate,
//                   style: TextStyle(
//                     fontSize: 11.sp,
//                     color: Colors.black54,
//                     fontWeight: FontWeight.w600,
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 12.h),
//           SizedBox(
//             width: double.infinity,
//             child: OutlinedButton(
//               onPressed: onViewLeaderboard ?? () {},
//               style: OutlinedButton.styleFrom(
//                 side: BorderSide(color: Colors.purple.shade200),
//                 foregroundColor: Colors.purple.shade700,
//                 textStyle: TextStyle(
//                   fontSize: 13.sp,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),
//               child: const Text('View Full Leaderboard'),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

// class _StatCard extends StatelessWidget {
//   final String label;
//   final String value;
//   final IconData icon;
//   final Color color;

//   const _StatCard({
//     required this.label,
//     required this.value,
//     required this.icon,
//     required this.color,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       padding: EdgeInsets.all(12.w),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(12.r),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(icon, color: color, size: 18.w),
//           SizedBox(height: 8.h),
//           Text(
//             label,
//             style: TextStyle(
//               fontSize: 10.sp,
//               color: Colors.black54,
//             ),
//           ),
//           SizedBox(height: 2.h),
//           Text(
//             value,
//             style: TextStyle(
//               fontSize: 16.sp,
//               fontWeight: FontWeight.w700,
//               color: Colors.black87,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
