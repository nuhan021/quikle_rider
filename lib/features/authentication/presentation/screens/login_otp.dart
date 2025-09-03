import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../routes/app_routes.dart';

class LoginOtp extends StatefulWidget {
  const LoginOtp({super.key});

  @override
  State<LoginOtp> createState() => _LoginOtpState();
}

class _LoginOtpState extends State<LoginOtp> with TickerProviderStateMixin {
  List<TextEditingController> otpControllers = List.generate(
    6,
    (index) => TextEditingController(),
  );
  List<FocusNode> focusNodes = List.generate(6, (index) => FocusNode());
  late AnimationController _animationController;
  int resendTimer = 27;
  bool canResend = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    startResendTimer();
  }

  void startResendTimer() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted) {
        setState(() {
          if (resendTimer > 0) {
            resendTimer--;
          } else {
            canResend = true;
          }
        });
      }
      return resendTimer > 0;
    });
  }

  String get phoneNumber => Get.arguments?['phone'] ?? '+1 (654) 654-5648';

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
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Column(
            children: [
              SizedBox(height: 20.h),

              // Rider Image
              Expanded(
                flex: 2,
                child: Container(
                  width: double.infinity,
                  child: Image.asset(
                    'assets/images/loginriderimage.png',
                    fit: BoxFit.contain,
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Enter Code Title
              Text(
                "Enter Code",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),

              SizedBox(height: 12.h),

              // Description
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "We've sent a 6-digit code to\n",
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.grey[600],
                      ),
                    ),
                    TextSpan(
                      text: phoneNumber,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: const Color(0xFFFFB800),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 40.h),

              // OTP Input Fields
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: List.generate(6, (index) {
                  return Container(
                    width: 45.w,
                    height: 56.h,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: otpControllers[index].text.isNotEmpty
                            ? Colors.black
                            : Colors.grey[300]!,
                        width: otpControllers[index].text.isNotEmpty ? 2 : 1,
                      ),
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: TextFormField(
                      controller: otpControllers[index],
                      focusNode: focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      style: TextStyle(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: "",
                      ),
                      onChanged: (value) {
                        setState(() {});
                        if (value.isNotEmpty && index < 5) {
                          focusNodes[index + 1].requestFocus();
                        } else if (value.isEmpty && index > 0) {
                          focusNodes[index - 1].requestFocus();
                        }

                        // Check if all fields are filled
                        if (index == 5 && value.isNotEmpty) {
                          String otp = otpControllers
                              .map((controller) => controller.text)
                              .join();
                          if (otp.length == 6) {
                            // Verify OTP
                            _verifyOtp(otp);
                          }
                        }
                      },
                    ),
                  );
                }),
              ),

              SizedBox(height: 40.h),

              // Verify Code Button
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: () {
                    String otp = otpControllers
                        .map((controller) => controller.text)
                        .join();
                    if (otp.length == 6) {
                      _verifyOtp(otp);
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
                    "Verify Code",
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFFFB800),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              // Resend Code
              GestureDetector(
                onTap: canResend ? _resendCode : null,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Resend code in ",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey[600],
                        ),
                      ),
                      TextSpan(
                        text: canResend ? "Resend now" : "${resendTimer}s",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: canResend
                              ? const Color(0xFFFFB800)
                              : Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }

  void _verifyOtp(String otp) {
    // Here you would typically verify the OTP with your backend
    // For demo purposes, we'll just navigate to the next screen

    // Simulate verification delay
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB800)),
        ),
      ),
    );

    Future.delayed(const Duration(seconds: 2), () {
      Get.back(); // Close loading dialog

      // Navigate to Welcome Screen for demo
      // In real app, check if user exists and navigate accordingly
      Get.offNamed(AppRoute.getWelcomeScreen());
    });
  }

  void _resendCode() {
    setState(() {
      canResend = false;
      resendTimer = 27;
    });
    startResendTimer();

    // Clear OTP fields
    for (var controller in otpControllers) {
      controller.clear();
    }

    // Focus first field
    focusNodes[0].requestFocus();

    // Show snackbar
    Get.snackbar(
      "Code Sent",
      "A new verification code has been sent to $phoneNumber",
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: const Color(0xFFFFB800),
      colorText: Colors.black,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    for (var controller in otpControllers) {
      controller.dispose();
    }
    for (var node in focusNodes) {
      node.dispose();
    }
    super.dispose();
  }
}
