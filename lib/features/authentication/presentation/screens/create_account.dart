import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
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
  bool acceptedTerms = false;

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
                          width: 60.w,
                          height: 60.h,
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFB800),
                            borderRadius: BorderRadius.circular(15.r),
                          ),
                          child: Icon(
                            Icons.delivery_dining,
                            size: 32.sp,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: 16.h),

                        RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Join ",
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.black,
                                ),
                              ),
                              TextSpan(
                                text: "Quikle",
                                style: TextStyle(
                                  fontSize: 28.sp,
                                  fontWeight: FontWeight.w600,
                                  color: const Color(0xFFFFB800),
                                ),
                              ),
                            ],
                          ),
                        ),

                        SizedBox(height: 8.h),

                        Text(
                          "The premier platform for riders",
                          style: TextStyle(
                            fontSize: 16.sp,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w400,
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
                    hintText: "John Doe",
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
                    hintText: "(555) 123-4567",
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
                    height: 56.h,
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
                        style: TextStyle(
                          fontSize: 18.sp,
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
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          TextSpan(
                            text: "Terms of Services",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                          TextSpan(
                            text: " and ",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.grey[600],
                            ),
                          ),
                          TextSpan(
                            text: "Privacy Policy",
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: Colors.black,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                            ),
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
      style: TextStyle(
        fontSize: 16.sp,
        fontWeight: FontWeight.w500,
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
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(fontSize: 16.sp, color: Colors.grey[500]),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 16.h,
          ),
        ),
        style: TextStyle(fontSize: 16.sp, color: Colors.black),
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
          colorText: Colors.black,
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
