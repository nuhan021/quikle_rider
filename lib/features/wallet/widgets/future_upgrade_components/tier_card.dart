// // ignore_for_file: deprecated_member_use

// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';

// class TierCard extends StatelessWidget {
//   final String benefits;
//   final double? acceptance;

//   const TierCard({Key? key, required this.benefits, this.acceptance})
//     : super(key: key);

//   String get _tier {
//     if (benefits.contains('24,000') || benefits.contains('29,000')) {
//       return 'Gold';
//     } else if (benefits.contains('19,500') || benefits.contains('21,000')) {
//       return 'Silver';
//     } else {
//       return 'Bronze';
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final tierData = _getTierData();

//     return Card(
//       elevation: 3,
//       shadowColor: tierData['color'].withOpacity(0.3),
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.w)),
//       child: Container(
//         padding: EdgeInsets.all(16.w),
//         decoration: BoxDecoration(
//           gradient: LinearGradient(
//             colors: [Colors.white, tierData['color'].withOpacity(0.08)],
//             begin: Alignment.topLeft,
//             end: Alignment.bottomRight,
//           ),
//           borderRadius: BorderRadius.circular(12.w),
//         ),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(10.w),
//                   decoration: BoxDecoration(
//                     color: tierData['color'].withOpacity(0.15),
//                     borderRadius: BorderRadius.circular(10.w),
//                   ),
//                   child: Icon(
//                     tierData['icon'],
//                     color: tierData['color'],
//                     size: 28.w,
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       'Current Tier',
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         color: Colors.black54,
//                         fontWeight: FontWeight.w500,
//                       ),
//                     ),
//                     SizedBox(height: 2.h),
//                     Row(
//                       children: [
//                         Icon(
//                           tierData['smallIcon'],
//                           color: tierData['color'],
//                           size: 16.w,
//                         ),
//                         SizedBox(width: 4.w),
//                         Text(
//                           _tier,
//                           style: TextStyle(
//                             fontSize: 20.sp,
//                             fontWeight: FontWeight.bold,
//                             color: tierData['color'],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//               ],
//             ),
//             SizedBox(height: 16.h),
//             Divider(color: Colors.white.withOpacity(0.28), thickness: 1),

//             SizedBox(height: 12.h),
//             Row(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Icon(
//                   Icons.card_giftcard_rounded,
//                   color: tierData['color'],
//                   size: 18.w,
//                 ),
//                 SizedBox(width: 8.w),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Benefits',
//                         style: TextStyle(
//                           fontSize: 12.sp,
//                           color: Colors.black54,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       SizedBox(height: 4.h),
//                       Text(
//                         benefits,
//                         style: TextStyle(
//                           fontSize: 14.sp,
//                           color: tierData['color'],
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ],
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Map<String, dynamic> _getTierData() {
//     switch (_tier.toLowerCase()) {
//       case 'bronze':
//         return {
//           'color': Color(0xFFCD7F32),
//           'icon': Icons.military_tech,
//           'smallIcon': Icons.shield,
//         };
//       case 'silver':
//         return {
//           'color': Color(0xFFC0C0C0),
//           'icon': Icons.workspace_premium,
//           'smallIcon': Icons.diamond,
//         };
//       case 'gold':
//         return {
//           'color': Color(0xFFFFD700),
//           'icon': Icons.emoji_events,
//           'smallIcon': Icons.auto_awesome,
//         };
//       default:
//         return {
//           'color': Colors.grey,
//           'icon': Icons.card_membership,
//           'smallIcon': Icons.star,
//         };
//     }
//   }
// }
