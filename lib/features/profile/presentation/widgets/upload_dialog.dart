import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:quikle_rider/core/common/styles/global_text_style.dart';

class UpdateProfilePictureDialog extends StatefulWidget {
  final Function(File?)? onImageSelected;

  const UpdateProfilePictureDialog({
    super.key,
    this.onImageSelected,
  });

  @override
  State<UpdateProfilePictureDialog> createState() => _UpdateProfilePictureDialogState();
}

class _UpdateProfilePictureDialogState extends State<UpdateProfilePictureDialog> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile != null) {
        final File imageFile = File(pickedFile.path);
        
        // Check file size (10MB = 10 * 1024 * 1024 bytes)
        final int fileSizeInBytes = await imageFile.length();
        const int maxSizeInBytes = 10 * 1024 * 1024; // 10MB
        
        if (fileSizeInBytes > maxSizeInBytes) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Image size should be less than 10MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (widget.onImageSelected != null) {
          widget.onImageSelected!(imageFile);
        }
        
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error picking image: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: 350.w,
        padding: EdgeInsets.all(30.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            Text(
              'Update Your Profile Picture',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 40.h),

            // Image Icon
            Image.asset(
              'assets/images/upload.png',
              width: 28.sp,
              height: 28.sp,
              color: Colors.grey[600],
            ),
            SizedBox(height: 25.h),

            // Upload Text
            Text(
              'Click to upload or drag and drop',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.w500,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 8.h),

            // Format Text
            Text(
              'JPG, JPEG, PNG less than 10MB',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey[600],
              ),
            ),
            SizedBox(height: 35.h),

            // Upload Button
            SizedBox(
              width: double.infinity,
         
              child: ElevatedButton(
                onPressed: _pickImage,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black87,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  'Upload Image',
                  style: getTextStyle2(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Helper function to show the dialog
void showUpdateProfilePictureDialog(
  BuildContext context, {
  Function(File?)? onImageSelected,
}) {
  showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return UpdateProfilePictureDialog(
        onImageSelected: onImageSelected,
      );
    },
  );
}