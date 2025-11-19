import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/features/profile/data/models/profile_model.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:quikle_rider/features/profile/presentation/widgets/upload_dialog.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  late final ProfileController _controller;
  Worker? _profileWorker;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _licenseController = TextEditingController();
  final TextEditingController _identityController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
    _populateFields(_controller.profile.value);
    _profileWorker = ever(_controller.profile, _populateFields);
  }

  void _populateFields(ProfileModel? profile) {
    if (profile == null) return;
    _nameController.text = profile.name;
    _emailController.text = profile.email;
    _phoneController.text = profile.phone;
    _licenseController.text = profile.drivingLicense;
    _identityController.text = profile.nid;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: UnifiedProfileAppBar(title: "Edit Profile"),
      body: SingleChildScrollView(
        padding: EdgeInsets.only(bottom: 30.h),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              SizedBox(height: 16.h),
              _buildHeader(context),
              SizedBox(height: 30.h),
              _buildFormCard(),
              SizedBox(height: 30.h),
              _buildSaveButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Obx(() {
        final imageUrl = _controller.profileImageUrl;
        final imageProvider = imageUrl != null
            ? NetworkImage(imageUrl)
            : const AssetImage('assets/images/loginriderimage.png')
                as ImageProvider;
        final displayName = _controller.displayName;
        final displayEmail = _controller.displayEmail;

        return Column(
          children: [
            InkWell(
              onTap: () {
                showDialog(
                  context: context,
                  builder: (context) => const UpdateProfilePictureDialog(),
                );
              },
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: imageProvider,
              ),
            ),
            const SizedBox(height: 15),
            Text(
              displayName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              displayEmail,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildFormCard() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(20),
            child: Text(
              'Edit Profile',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
          ),
          _buildEditField(
            label: 'Name',
            controller: _nameController,
            validator: (value) => _requiredValidator(value, 'Name'),
          ),
          _buildEditField(
            label: 'Email Address',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: _emailValidator,
          ),
          _buildEditField(
            label: 'Phone Number',
            controller: _phoneController,
            readOnly: true,
          ),
          _buildEditField(
            label: 'Driving License Number',
            controller: _licenseController,
            validator: (value) =>
                _requiredValidator(value, 'Driving License Number'),
          ),
          _buildEditField(
            label: 'National Identity Number',
            controller: _identityController,
            validator: (value) =>
                _requiredValidator(value, 'National Identity Number'),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return Obx(() {
      final isSaving = _controller.isUpdatingProfile.value;
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isSaving ? null : _handleSave,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: isSaving
                ? const SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : const Text(
                    'Save Changes',
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w600,
                    ),
                  ),
          ),
        ),
      );
    });
  }

  Future<void> _handleSave() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;

    final success = await _controller.updateProfileData(
      name: _nameController.text.trim(),
      email: _emailController.text.trim(),
      drivingLicense: _licenseController.text.trim(),
      nid: _identityController.text.trim(),
    );

    if (success) {
      Get.back();
      Get.snackbar('Profile Updated', 'Your profile has been updated.');
    } else {
      Get.snackbar('Update Failed', _controller.profileUpdateErrorText);
    }
  }

  Widget _buildEditField({
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            validator: validator ??
                (value) => readOnly ? null : _requiredValidator(value, label),
            style: TextStyle(fontSize: 14, color: Colors.grey[800]),
            decoration: InputDecoration(
              hintText: 'Enter $label',
              hintStyle: TextStyle(color: Colors.grey[400]),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.grey[300]!),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.orange),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String? _requiredValidator(String? value, String fieldName) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  String? _emailValidator(String? value) {
    final requiredMessage = _requiredValidator(value, 'Email Address');
    if (requiredMessage != null) {
      return requiredMessage;
    }
    final email = value!.trim();
    if (!GetUtils.isEmail(email)) {
      return 'Enter a valid email address';
    }
    return null;
  }

  @override
  void dispose() {
    _profileWorker?.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _licenseController.dispose();
    _identityController.dispose();
    super.dispose();
  }
}
