import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/utils/constants/enums.dart';
import 'package:quikle_rider/features/authentication/controllers/auth_controller.dart';
import 'package:quikle_rider/features/authentication/presentation/screens/create_account.dart';

class LoginScreen extends GetView<AuthController> {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 60.h),
                Column(
                  children: [
                    RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Welcome to ",
                            style: getTextStyle(
                              font: CustomFonts.obviously,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Colors.black,
                            ),
                          ),
                          TextSpan(
                            text: "Quikle",
                            style: getTextStyle(
                              font: CustomFonts.obviously,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: const Color(0xFFFFB800),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      "The premier platform for riders",
                      style: getTextStyle(
                        font: CustomFonts.inter,
                        fontSize: 16,
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                Image.asset(
                  'assets/images/loginriderimage.png',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: 300.h,
                ),
                SizedBox(height: 40.h),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Phone Number",
                      style: getTextStyle(
                        font: CustomFonts.inter,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    Obx(
                      () => SizedBox(
                        height: 52.h,
                        child: TextFormField(
                          controller: controller.phoneController,
                          focusNode: controller.phoneFocusNode,
                          keyboardType: TextInputType.number,
                          

                          style: getTextStyle(font: CustomFonts.inter),
                          decoration: InputDecoration(
                            hintText: "Enter Your Phone Number",
                            hintStyle: getTextStyle(
                              font: CustomFonts.inter,
                              fontSize: 16,
                              color: Colors.grey[500],
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: BorderSide(
                                color: controller.isPhoneFocused.value
                                    ? Colors.black
                                    : const Color(0xFF7C7C7C),
                                width: 1.0,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: const Color(0xFF7C7C7C),
                                width: 1.0,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12.r),
                              borderSide: const BorderSide(
                                color: Colors.black,
                                width: 1.0,
                              ),
                            ),
                            contentPadding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24.h),
                    SizedBox(
                      width: 352.w,
                      child: ElevatedButton(
                        onPressed: controller.navigateToOtp,
                        style: ElevatedButton.styleFrom(
                          side: BorderSide.none,
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Log In",
                          style: getTextStyle(
                            font: CustomFonts.manrope,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFC200),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 50.h),
                    Center(
                      child: Text(
                        "Don't have an account?",
                        style: getTextStyle(
                          font: CustomFonts.inter,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF7C7C7C),
                        ),
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: 352.w,
                      height: 48.h,
                      child: OutlinedButton(
                        onPressed: () => Get.to(() => const CreateAccount()),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Colors.black),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          "Create An Account",
                          style: getTextStyle(
                            font: CustomFonts.manrope,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 20.h),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
