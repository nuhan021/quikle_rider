// import 'package:flutter/material.dart';
// import 'package:flutter_screenutil/flutter_screenutil.dart';
// import 'package:quikle_rider/features/wallet/models/bonus_tracking_models.dart';

// class DailyBonusTracker extends StatelessWidget {
//   final int deliveriesToday;
//   final int targetDeliveries;
//   final String nextBonus;
//   final int remainingDeliveries;
//   final String streakMessage;
//   final String motivationalMessage;
//   final List<BonusMilestone> bonusesEarned;
//   final List<BonusTierProgress> tierProgress;

//   const DailyBonusTracker({
//     Key? key,
//     required this.deliveriesToday,
//     required this.targetDeliveries,
//     required this.nextBonus,
//     required this.remainingDeliveries,
//     required this.streakMessage,
//     required this.motivationalMessage,
//     required this.bonusesEarned,
//     required this.tierProgress,
//   }) : super(key: key);

//   @override
//   Widget build(BuildContext context) {
//     final double progress =
//         targetDeliveries == 0 ? 0 : (deliveriesToday / targetDeliveries).clamp(0, 1);

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
//                   color: Colors.blue.shade50,
//                   borderRadius: BorderRadius.circular(10.r),
//                 ),
//                 child: Icon(
//                   Icons.local_shipping_rounded,
//                   color: Colors.blue.shade600,
//                   size: 20.w,
//                 ),
//               ),
//               SizedBox(width: 10.w),
//               Text(
//                 'Daily Bonus Tracker',
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
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               Text(
//                 'Deliveries Today',
//                 style: TextStyle(
//                   fontSize: 12.sp,
//                   color: Colors.black54,
//                   fontWeight: FontWeight.w500,
//                 ),
//               ),
//               Text(
//                 '$deliveriesToday/$targetDeliveries',
//                 style: TextStyle(
//                   fontSize: 16.sp,
//                   fontWeight: FontWeight.w700,
//                   color: Colors.black87,
//                 ),
//               ),
//             ],
//           ),
//           SizedBox(height: 10.h),
//           ClipRRect(
//             borderRadius: BorderRadius.circular(8.r),
//             child: LinearProgressIndicator(
//               value: progress,
//               minHeight: 8.h,
//               backgroundColor: Colors.grey.shade200,
//               valueColor: AlwaysStoppedAnimation<Color>(Colors.blue.shade600),
//             ),
//           ),
//           SizedBox(height: 12.h),
//           Container(
//             padding: EdgeInsets.all(10.w),
//             decoration: BoxDecoration(
//               color: Colors.green.shade50,
//               borderRadius: BorderRadius.circular(10.r),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text(
//                       'Next Bonus',
//                       style: TextStyle(
//                         fontSize: 11.sp,
//                         color: Colors.black54,
//                       ),
//                     ),
//                     Text(
//                       nextBonus,
//                       style: TextStyle(
//                         fontSize: 18.sp,
//                         fontWeight: FontWeight.w700,
//                         color: Colors.green.shade700,
//                       ),
//                     ),
//                   ],
//                 ),
//                 Text(
//                   '$remainingDeliveries more deliveries',
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
//           Container(
//             width: double.infinity,
//             padding: EdgeInsets.all(12.w),
//             decoration: BoxDecoration(
//               color: Colors.indigo.shade50,
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             child: Row(
//               children: [
//                 Container(
//                   padding: EdgeInsets.all(8.w),
//                   decoration: BoxDecoration(
//                     color: Colors.indigo.shade100,
//                     borderRadius: BorderRadius.circular(10.r),
//                   ),
//                   child: Icon(
//                     Icons.local_fire_department_rounded,
//                     color: Colors.indigo.shade700,
//                     size: 20.w,
//                   ),
//                 ),
//                 SizedBox(width: 12.w),
//                 Expanded(
//                   child: Text(
//                     streakMessage,
//                     style: TextStyle(
//                       fontSize: 12.sp,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.indigo.shade800,
//                     ),
//                   ),
//                 ),
//               ],
//             ),
//           ),
//           SizedBox(height: 10.h),
//           Text(
//             motivationalMessage,
//             style: TextStyle(
//               fontSize: 12.sp,
//               fontWeight: FontWeight.w700,
//               color: Colors.green.shade700,
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
//                   "Today's Bonuses",
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.black87,
//                   ),
//                 ),
//                 SizedBox(height: 10.h),
//                 ...bonusesEarned.asMap().entries.map(
//                   (entry) => Padding(
//                     padding: EdgeInsets.only(
//                       bottom: entry.key == bonusesEarned.length - 1 ? 0 : 8.h,
//                     ),
//                     child: Row(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Icon(
//                           entry.value.isCompleted
//                               ? Icons.check_circle_rounded
//                               : Icons.radio_button_unchecked,
//                           color: entry.value.isCompleted
//                               ? Colors.green.shade600
//                               : Colors.grey.shade400,
//                           size: 18.w,
//                         ),
//                         SizedBox(width: 10.w),
//                         Expanded(
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 entry.value.title,
//                                 style: TextStyle(
//                                   fontSize: 12.sp,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.black87,
//                                 ),
//                               ),
//                               SizedBox(height: 2.h),
//                               Text(
//                                 entry.value.description,
//                                 style: TextStyle(
//                                   fontSize: 11.sp,
//                                   color: Colors.black54,
//                                 ),
//                               ),
//                             ],
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
//               color: Colors.blueGrey.shade50,
//               borderRadius: BorderRadius.circular(12.r),
//             ),
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   'Bonus Tiers Progress',
//                   style: TextStyle(
//                     fontSize: 12.sp,
//                     fontWeight: FontWeight.w700,
//                     color: Colors.blueGrey.shade800,
//                   ),
//                 ),
//                 SizedBox(height: 10.h),
//                 ...tierProgress.asMap().entries.map(
//                   (entry) {
//                     final tier = entry.value;
//                     final double tierProgressValue = tier.progress.clamp(0, 1);
//                     return Padding(
//                       padding: EdgeInsets.only(
//                         bottom: entry.key == tierProgress.length - 1 ? 0 : 12.h,
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               Expanded(
//                                 child: Text(
//                                   tier.label,
//                                   style: TextStyle(
//                                     fontSize: 12.sp,
//                                     fontWeight: FontWeight.w600,
//                                     color: Colors.blueGrey.shade900,
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 12.w),
//                               Text(
//                                 tier.progressLabel,
//                                 style: TextStyle(
//                                   fontSize: 11.sp,
//                                   fontWeight: FontWeight.w600,
//                                   color: Colors.blueGrey.shade600,
//                                 ),
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 6.h),
//                           ClipRRect(
//                             borderRadius: BorderRadius.circular(6.r),
//                             child: LinearProgressIndicator(
//                               value: tierProgressValue,
//                               minHeight: 6.h,
//                               backgroundColor: Colors.blueGrey.shade100,
//                               valueColor: AlwaysStoppedAnimation<Color>(
//                                 tierProgressValue >= 1
//                                     ? Colors.green.shade600
//                                     : Colors.blueGrey.shade700,
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                     );
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
