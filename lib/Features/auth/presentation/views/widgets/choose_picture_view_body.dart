import 'dart:io';

import 'package:chatbox/Features/auth/presentation/views/widgets/choose_picture_camera_button.dart';
import 'package:chatbox/Features/auth/presentation/views/widgets/choose_picture_finish_button.dart';
import 'package:chatbox/Features/auth/presentation/views/widgets/choose_picture_gallary_button.dart';
import 'package:chatbox/Features/auth/presentation/views/widgets/choose_picture_header.dart';
import 'package:chatbox/Features/auth/presentation/views/widgets/choose_picture_selection_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';

class ChoosePictureViewBody extends StatelessWidget {
  final File? selectedImage;
  final Function(ImageSource) onPickImage;
  final String name;
  final String email;
  final String password;

  const ChoosePictureViewBody({
    super.key,
    required this.selectedImage,
    required this.onPickImage,
    required this.name,
    required this.email,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: 50.h),
              const ChoosePictureHeader(),
              SizedBox(height: 80.h),
              ChoosePictureImageSection(selectedImage: selectedImage),
              SizedBox(height: 80.h),
              ChoosePictureCameraButton(onPressed: () => onPickImage(ImageSource.camera)),
              SizedBox(height: 15.h),
              ChoosePictureGalleryButton(onPressed: () => onPickImage(ImageSource.gallery)),
              SizedBox(height: 100.h),
              ChoosePictureFinishButton(
                selectedImage: selectedImage,
                name: name,
                email: email,
                password: password,
              ),
            ],
          ),
        ),
      ),
    );
  }
}