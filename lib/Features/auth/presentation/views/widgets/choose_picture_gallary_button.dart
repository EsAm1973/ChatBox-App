import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChoosePictureGalleryButton extends StatelessWidget {
  final VoidCallback onPressed;

  const ChoosePictureGalleryButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 50.h,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.primary,
          foregroundColor: Theme.of(context).colorScheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          elevation: 2,
        ),
        onPressed: onPressed,
        icon: const Icon(Icons.photo_library_rounded),
        label: const Text('Choose from Gallery'),
      ),
    );
  }
}