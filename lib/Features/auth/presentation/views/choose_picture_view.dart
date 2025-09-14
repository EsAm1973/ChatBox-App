import 'dart:io';
import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Core/widgets/custom_bottom.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePictureScreen extends StatefulWidget {
  const ProfilePictureScreen({super.key});

  @override
  State<ProfilePictureScreen> createState() => _ProfilePictureScreenState();
}

class _ProfilePictureScreenState extends State<ProfilePictureScreen> {
  File? _selectedImage;
  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    try {
      final pickedFile = await picker.pickImage(source: source);
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
        });
      }
    } catch (e) {
      // Handle potential errors, such as permission denied.
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => GoRouter.of(context).pop(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: 50.h),
                Text(
                  'Add a Profile Picture',
                  style: AppTextStyles.bold18,
                ),
                SizedBox(height: 10.h),
                Text(
                  'Choose a picture that represents you best',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.regular14,
                ),
                SizedBox(height: 80.h),

                // The main circular profile picture area
                Stack(
                  children: [
                    // This is the main profile picture container.
                    CircleAvatar(
                      radius: 80.r,
                      backgroundColor: Theme.of(
                        context,
                      ).colorScheme.primary.withOpacity(0.1),
                      // Conditionally display the selected image or the placeholder icon.
                      child:
                          _selectedImage != null
                              ? ClipOval(
                                child: Image.file(
                                  _selectedImage!,
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
                ),
                SizedBox(height: 80.h),

                // Button for camera
                SizedBox(
                  width: double.infinity,
                  height: 50.h,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      foregroundColor:
                          Theme.of(context).colorScheme.onSurfaceVariant,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () => _pickImage(ImageSource.camera),
                    icon: const Icon(Icons.camera_alt_rounded),
                    label: const Text('Take Photo'),
                  ),
                ),
                SizedBox(height: 15.h),

                // Button for gallery
                SizedBox(
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
                    onPressed: () => _pickImage(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_rounded),
                    label: const Text('Choose from Gallery'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      // Use bottomNavigationBar to keep the button fixed at the bottom.
      bottomNavigationBar: Padding(
        padding: EdgeInsets.all(24.w),
        child: CustomBottom(
          text: 'Finish Creating Account',
          backgroundColor: Theme.of(context).colorScheme.primary,
          textColor: Theme.of(context).colorScheme.onPrimary,
          onTap: () {},
        ),
      ),
    );
  }
}
