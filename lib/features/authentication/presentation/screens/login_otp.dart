import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/utils/constants/enums.dart';
import 'package:quikle_rider/features/authentication/controllers/auth_controller.dart';

class LoginOtp extends GetView<AuthController> {
  const LoginOtp({super.key});

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller.currentOtp.value.isEmpty &&
          !controller.otpFocusNodes.first.hasFocus) {
        controller.otpFocusNodes.first.requestFocus();
      }
    });

    final phoneNumber = controller.phoneNumberForOtp;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Image.asset(
                  'assets/images/loginriderimage.png',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: 330.h,
                ),
                SizedBox(height: 40.h),
                Text(
                  "Enter Code",
                  style: getTextStyle(
                    font: CustomFonts.obviously,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 12.h),
                Column(
                  children: [
                    Text(
                      "We've sent a 6-digit code to",
                      textAlign: TextAlign.center,
                      style: getTextStyle(
                        font: CustomFonts.inter,
                        fontSize: 14,
                        color: Colors.grey[600]!,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      phoneNumber,
                      textAlign: TextAlign.center,
                      style: getTextStyle(
                        font: CustomFonts.inter,
                        fontSize: 16,
                        color: const Color(0xFFFFB800),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return SizedBox(
                      // height: 52.h,
                      width: 48.w,
                      // height: 56.h,
                      child: TextFormField(
                        
                        controller: controller.otpControllers[index],
                        focusNode: controller.otpFocusNodes[index],
                        textAlign: TextAlign.center,
                        keyboardType: TextInputType.number,
                        maxLength: 1,
                        style: getTextStyle(
                          font: CustomFonts.inter,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        decoration: InputDecoration(
                          counterText: "",
                          contentPadding: EdgeInsets.symmetric(vertical: 16.h),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Color(0xFF7C7C7C),
                              width: 1.0,
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Color(0xFF7C7C7C),
                              width: 1.0,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.r),
                            borderSide: const BorderSide(
                              color: Colors.black,
                              width: 2.0,
                            ),
                          ),
                        ),
                        onChanged: (value) =>
                            controller.onOtpChanged(index, value, context),
                      ),
                    );
                  }),
                ),
                SizedBox(height: 40.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(

                    onPressed: () => controller.verifyOtp(context),
                    style: ElevatedButton.styleFrom(
                      side: BorderSide.none,
                      backgroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Verify Code",
                      style: getTextStyle(
                        font: CustomFonts.manrope,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFFFFB800),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                GestureDetector(
                  onTap: controller.resendCode,
                  child: Obx(
                    () => RichText(
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Resend code in ",
                            style: getTextStyle(
                              font: CustomFonts.inter,
                              fontSize: 14,
                              color: Colors.grey[600]!,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          TextSpan(
                            text: controller.canResend.value
                                ? "Resend now"
                                : "${controller.resendTimer.value}s",
                            style: getTextStyle(
                              font: CustomFonts.inter,
                              fontSize: 14,
                              color: controller.canResend.value
                                  ? const Color(0xFFFFB800)
                                  : Colors.grey[600]!,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
