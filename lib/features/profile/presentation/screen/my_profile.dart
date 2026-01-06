// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:quikle_rider/core/common/widgets/common_appbar.dart';
import 'package:quikle_rider/features/profile/data/models/profile_model.dart';
import 'package:quikle_rider/features/profile/presentation/controller/profile_controller.dart';
import 'package:quikle_rider/features/profile/presentation/screen/upload_documents.dart';

import 'edit_profile.dart';

class MyProfilePage extends StatelessWidget {
  MyProfilePage({super.key}) {
    _controller = Get.isRegistered<ProfileController>()
        ? Get.find<ProfileController>()
        : Get.put(ProfileController());
  }

  late final ProfileController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: UnifiedProfileAppBar(title: "My Profile"),
      body: Obx(() {
        final profile = _controller.profile.value;
        if (_controller.isLoading.value && profile == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (profile == null) {
          return _buildErrorState();
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 16.h),
              _buildHeader(profile),
              const SizedBox(height: 30),
              _buildDetailsCard(context, profile),
              const SizedBox(height: 30),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _controller.errorMessage.value ?? 'Unable to load profile.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _controller.fetchProfile,
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(ProfileModel profile) {
    final imageUrl = profile.profileImage;
    final Widget avatar = imageUrl != null && imageUrl.trim().isNotEmpty
        ? Image.network(
            imageUrl.trim(),
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return Image.asset(
                'assets/images/quickle_black.png',
                fit: BoxFit.cover,
              );
            },
          )
        : Image.asset(
            'assets/images/loginriderimage.png',
            fit: BoxFit.cover,
          );

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
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.grey.shade200,
            child: ClipOval(
              child: SizedBox(
                width: 100,
                height: 100,
                child: avatar,
              ),
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            profile.name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            profile.email,
            style: TextStyle(fontSize: 14, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(BuildContext context, ProfileModel profile) {
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
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'My Profile',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                GestureDetector(
                  onTap: () {
                    if (_controller.isVerifiedApproved) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const EditProfilePage(),
                        ),
                      );
                    } else {
                      SnackBar(content: Text('You are not verified yet'));
                      return;
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF434343), Color(0xFF000000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        !_controller.isVerifiedApproved
                            ? Icon(
                                Icons.lock_outline,
                                color: Colors.white70,
                                size: 18,
                              )
                            : SizedBox.shrink(),
                        !_controller.isVerifiedApproved
                            ? const SizedBox(width: 8)
                            : SizedBox.shrink(),
                        const Text(
                          'Edit',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          _buildProfileItem('Name', profile.name),
          _buildDivider(),
          _buildProfileItem('Email Address', profile.email),
          _buildDivider(),
          _buildProfileItem('Phone Number', profile.phone),
          _buildDivider(),
          // _buildProfileItem('Driving License Number', profile.drivingLicense),
          // _buildDivider(),
          _buildProfileItem('National Identity Number', profile.nid),
          _buildDivider(),
          _buildUploadDocumentsRow(context),
        ],
      ),
    );
  }

  Widget _buildProfileItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 14, color: Colors.grey[600])),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return Divider(
      height: 1,
      thickness: 1,
      color: Colors.grey[200],
      indent: 20,
      endIndent: 20,
    );
  }

  Widget _buildUploadDocumentsRow(BuildContext context) {
    return InkWell(
      onTap: () {
        Get.to(UploadDocumentsPage());
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        child: Row(
          children: [
            const Icon(Icons.upload_file, color: Colors.black54),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                'Upload Documents',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
            ),
            Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }
}
