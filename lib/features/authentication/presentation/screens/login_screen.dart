import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/utils/constants/enums.dart';
import 'login_otp.dart';
import 'package:quikle_rider/features/authentication/presentation/screens/create_account.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final FocusNode _phoneFocusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _phoneFocusNode.addListener(() {
      setState(() {
        _isFocused = _phoneFocusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    phoneController.dispose();
    _phoneFocusNode.dispose();
    super.dispose();
  }

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

                // Title Section
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

                SizedBox(height: 0.h),

                // Rider Image
                Image.asset(
                  'assets/images/loginriderimage.png',
                  fit: BoxFit.contain,
                  width: double.infinity,
                  height: 300.h,
                ),

                SizedBox(height: 40.h),

                // Form Section
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

                    SizedBox(
                      height: 52.h,
                      child: TextFormField(
                        controller: phoneController,
                        focusNode: _phoneFocusNode,
                        keyboardType: TextInputType.phone,
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
                              color: _isFocused
                                  ? Colors.black
                                  : const Color(0xFF7C7C7C),
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

                    SizedBox(height: 24.h),

                    // Log In Button
                    SizedBox(
                      width: 352.w,
                      child: ElevatedButton(
                        onPressed: () {
                          if (phoneController.text.isNotEmpty) {
                            Get.to(
                              () => const LoginOtp(),
                              arguments: {'phone': phoneController.text},
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
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
                        onPressed: () {
                          // Navigate to the CreateAccount screen
                          Get.to(() => const CreateAccount());
                        },
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
