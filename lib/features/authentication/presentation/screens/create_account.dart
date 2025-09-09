import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/styles/global_text_style.dart';
import 'package:quikle_rider/core/utils/constants/enums.dart';
import '../../../../routes/app_routes.dart';

class CreateAccount extends StatefulWidget {
  const CreateAccount({super.key});

  @override
  State<CreateAccount> createState() => _CreateAccountState();
}

class _CreateAccountState extends State<CreateAccount> {
  final TextEditingController fullNameController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController drivingLicenseController =
      TextEditingController();
  final TextEditingController vehicleLicenseController =
      TextEditingController();

  final _formKey = GlobalKey<FormState>();

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
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 20.h),

                  // Logo and Title
                  Center(
                    child: Column(
                      children: [
                        Container(
                          width: 64.w,
                          height: 64.h,
                          child: Image.asset(
                            // Changed from Icon to Image.asset
                            'assets/images/welcomeimage.png',
                            fit: BoxFit.contain,
                            width: 32
                                .sp, // Using sp for consistency with original Icon size
                            height: 32.sp,
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

                  // Full Name Field
                  _buildLabel("Full Name"),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    controller: fullNameController,
                    hintText: "S. M. Mahedi Hasan",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your full name';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Phone Number Field
                  _buildLabel("Phone Number"),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    controller: phoneController,
                    hintText: "(+880) 123-4567",
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your phone number';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Driving License Field
                  _buildLabel("Driving License Number"),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    controller: drivingLicenseController,
                    hintText: "Driving License Number",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your driving license number';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 20.h),

                  // Vehicle License Field
                  _buildLabel("Vehicle License Number"),
                  SizedBox(height: 8.h),
                  _buildTextField(
                    controller: vehicleLicenseController,
                    hintText: "Vehicle License Number",
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your vehicle license number';
                      }
                      return null;
                    },
                  ),

                  SizedBox(height: 30.h),

                  // Create Account Button
                  SizedBox(
                    width: double.infinity,
                    height: 48.h,
                    child: ElevatedButton(
                      onPressed: _createAccount,
                      style: ElevatedButton.styleFrom(
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

                  SizedBox(height: 20.h),

                  // Terms and Privacy Policy
                  Center(
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "By creating an account, you agree to our ",
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
                            ).copyWith(decoration: TextDecoration.underline),
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
                            ).copyWith(decoration: TextDecoration.underline),
                          ),
                        ],
                      ),
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
    String? Function(String?)? validator,
  }) {
    return SizedBox(
      height: 52.h,
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
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
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
      ),
    );
  }

  void _createAccount() {
    if (_formKey.currentState!.validate()) {
      // Show loading
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFFB800)),
          ),
        ),
      );

      // Simulate account creation delay
      Future.delayed(const Duration(seconds: 2), () {
        Get.back(); // Close loading dialog

        // Show success message
        Get.snackbar(
          "Account Created",
          "Your account has been created successfully!",
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: const Color(0xFFFFB800),
          titleText: const Text(
            "Account Created",
            style: TextStyle(
              fontSize: 18.0,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          messageText: const Text(
            "Your account has been created successfully!",
            style: TextStyle(
              fontSize: 16.0,
              color: Colors.black,
            ),
          ),
          duration: const Duration(seconds: 3),
        );

        // Navigate to Welcome Screen
        Get.offNamed(AppRoute.getWelcomeScreen());
      });
    }
  }

  @override
  void dispose() {
    fullNameController.dispose();
    phoneController.dispose();
    drivingLicenseController.dispose();
    vehicleLicenseController.dispose();
    super.dispose();
  }
}
