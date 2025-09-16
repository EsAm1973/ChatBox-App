import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChoosePictureImageSection extends StatelessWidget {
  final File? selectedImage;

  const ChoosePictureImageSection({super.key, required this.selectedImage});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        CircleAvatar(
          radius: 80.r,
          backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.1),
          child: selectedImage != null
              ? ClipOval(
                  child: Image.file(
                    selectedImage!,
                    width: 160.r,
                    height: 160.r,
                    fit: BoxFit.cover,
                  ),
                )
              : Icon(
                  Icons.person_rounded,
                  size: 80.r,
                  color: Theme.of(context).colorScheme.primary,
                ),
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.all(4.r),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
              shape: BoxShape.circle,
              border: Border.all(
                color: Theme.of(context).colorScheme.surface,
                width: 3.w,
              ),
            ),
            child: Icon(
              Icons.add_a_photo_rounded,
              color: Theme.of(context).colorScheme.onPrimary,
              size: 24.r,
            ),
          ),
        ),
      ],
    );
  }
}