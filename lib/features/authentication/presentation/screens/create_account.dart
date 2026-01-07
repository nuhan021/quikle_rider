import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/utils/constants/enums.dart';
import 'package:quikle_rider/features/authentication/controllers/auth_controller.dart';

class CreateAccount extends GetView<AuthController> {
  const CreateAccount({super.key});

  @override
  Widget build(BuildContext context) {
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
            child: Form(
              key: controller.formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),
                  Center(
                    child: Column(
                      children: [
                        SizedBox(
                          width: 64.w,
                          height: 64.h,
                          child: Image.asset(
                            'assets/images/logo.png',
                            fit: BoxFit.contain,
                          ),
                        ),
                        SizedBox(height: 16.h),
                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Join ",
                                style: getTextStyle(
                                  font: CustomFonts.obviously,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: "Quikle",
                                style: getTextStyle(
                                  font: CustomFonts.obviously,
                                  fontSize: 22,
                                  fontWeight: FontWeight.w500,
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
                  ),
                  SizedBox(height: 40.h),
                  _buildLabel("Full Name"),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    controller: controller.fullNameController,
                    hintText: "Enter full Name",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20.h),
                  _buildLabel("Phone Number"),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    controller: controller.accountPhoneController,
                    hintText: "XXXXXXXX",
                    keyboardType: TextInputType.phone,
                    prefixText: "+91 ",
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(10),
                    ],
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      if (value.length != 10) {
                        return 'Please enter a 10-digit phone number';
                      }
                      return null;
                    },
                  ),
                  // SizedBox(height: 20.h),
                  // _buildLabel("Driving License Number"),
                  // SizedBox(height: 8.h),
                  // _buildTextField(
                  //   controller: controller.drivingLicenseController,
                  //   hintText: "Driving License Number",
                  //   validator: (value) {
                  //     if (value == null || value.isEmpty) {
                  //       return 'Please enter your driving license number';
                  //     }
                  //     return null;
                  //   },
                  // ),
                  SizedBox(height: 20.h),
                  _buildLabel("Government ID Number"),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    controller: controller.nidcontroller,
                    hintText: "Government ID Number",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your vehicle license number';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 30.h),
                  SizedBox(
                    width: double.infinity,
                    child: Obx(
                      () => ElevatedButton(
                        onPressed: controller.termsAccepted.value
                            ? () => controller.createAccount(context)
                            : null,
                        style: ElevatedButton.styleFrom(
                          side: BorderSide.none,
                          backgroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          "Create Account",
                          style: getTextStyle(
                            font: CustomFonts.manrope,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFFFB800),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                  Obx(
                    () => Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 22.h,
                          width: 22.w,
                          child: Checkbox(
                            value: controller.termsAccepted.value,
                            onChanged: (value) {
                              controller.termsAccepted.value = value ?? false;
                            },
                            activeColor: Colors.black,
                          ),
                        ),
                        SizedBox(width: 8.w),
                        Expanded(
                          child: RichText(
                            textAlign: TextAlign.left,
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text:
                                      "I agree to the ",
                                  style: getTextStyle(
                                    font: CustomFonts.inter,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                TextSpan(
                                  text: "Terms of Services",
                                  style: getTextStyle(
                                    font: CustomFonts.inter,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                                TextSpan(
                                  text: " and ",
                                  style: getTextStyle(
                                    font: CustomFonts.inter,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.grey[600],
                                  ),
                                ),
                                TextSpan(
                                  text: "Privacy Policy",
                                  style: getTextStyle(
                                    font: CustomFonts.inter,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 30.h),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: getTextStyle(
        font: CustomFonts.inter,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: Colors.black,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    TextInputType? keyboardType,
    String? prefixText,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 52.h,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        inputFormatters: inputFormatters,
        validator: validator,
        style: getTextStyle(
          font: CustomFonts.inter,
          fontSize: 16,
          fontWeight: FontWeight.w400,
          color: Colors.black,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: getTextStyle(
            font: CustomFonts.inter,
            fontSize: 16,
            color: Colors.grey[500],
          ),
          prefixText: prefixText,
          prefixStyle: getTextStyle(
            font: CustomFonts.inter,
            fontSize: 16,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFF7C7C7C), width: 1.0),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Color(0xFF7C7C7C), width: 1.0),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Colors.black, width: 1.0),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: const BorderSide(color: Colors.red, width: 1.0),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }
}
