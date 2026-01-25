// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
// import 'package:quikle_rider/core/utils/constants/colors.dart';
// import 'package:quikle_rider/features/profile/presentation/screen/edit_profile.dart';
// import 'package:quikle_rider/features/profile/presentation/screen/rider_editprofile.dart';
// import 'package:quikle_rider/features/profile/presentation/widgets/common_button.dart';
// import 'package:quikle_rider/features/profile/presentation/widgets/profile_components/profile_field.dart';
// import '../../../../core/common/styles/global_text_style.dart';

// class RiderProfile extends StatelessWidget {
//   const RiderProfile({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: AppColors.background,
//       appBar: const UnifiedProfileAppBar(title: "My Profile"),
//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(16),
//         child: Column(
//           children: [
//             /// Profile Header
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.symmetric(vertical: 20),

              
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: .05),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 children: [
//                   CircleAvatar(
//                     radius: 45,
//                     backgroundImage: AssetImage("assets/images/profile.png"),
//                   ),
//                   SizedBox(height: 12),
//                   Text(
//                     "Vikram =",
//                     style: getTextStyle2(
//                       fontSize: 18,
//                       fontWeight: FontWeight.w600,
//                       color: Colors.black87,
//                     ),
//                   ),
//                   SizedBox(height: 4),
//                   Text(
//                     "vikramrajput@gmail.com",
//                     style: getTextStyle2(fontSize: 14, color: Colors.black54),
//                   ),
//                 ],
//               ),
//             ),
//             const SizedBox(height: 20),

//             /// Profile Info Card
//             Container(
//               width: double.infinity,
//               padding: const EdgeInsets.all(16),
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular(12),
//                 boxShadow: [
//                   BoxShadow(
//                     color: Colors.black.withValues(alpha: .05),
//                     blurRadius: 8,
//                     offset: const Offset(0, 3),
//                   ),
//                 ],
//               ),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   /// Title + Edit
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Text(
//                         "My Profile",
//                         style: getTextStyle2(
//                           fontSize: 16,
//                           fontWeight: FontWeight.w600,
//                         ),
//                       ),
//                       CustomButton(
//                         width: 50,
//                         height: 26,
//                         text: "Edit",
//                         style: getTextStyle2(
//                           fontSize: 12,
//                           fontWeight: FontWeight.w400,
//                           color: Colors.white,
//                         ),
//                         onPressed: () {
//                           Get.to(EditProfilePage());
//                         },
//                         backgroundColor: Colors.black,
//                         textColor: Colors.white,
//                         fontSize: 14,
//                         borderRadius: 6,
//                       ),
//                     ],
//                   ),
//                   const Divider(height: 24, thickness: 0.8),

//                   /// Profile Fields
//                   const ProfileField(label: "Name", value: "Vikram Rajput"),
//                   const ProfileField(
//                     label: "Email Address",
//                     value: "vikramrajput@gmail.com",
//                   ),
//                   const ProfileField(
//                     label: "Phone Number",
//                     value: "+1 (555) 123-4567",
//                   ),
//                   const ProfileField(
//                     label: "National Identity Number",
//                     value: "1234567981011",
//                     showDivider: false,
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
