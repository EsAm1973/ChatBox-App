import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:chatbox/Core/cubit/user cubit/user_cubit.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/profile/presentation/manager/profile_cubit/profile_cubit.dart';
import 'package:chatbox/Core/service/supabase_storage.dart';
import 'package:chatbox/Core/helper functions/animated_loading_dialog.dart';

/// Service responsible for handling image picking and uploading functionality
class ProfileImageService {
  final BuildContext context;
  
  ProfileImageService(this.context);

  /// Pick image from camera or gallery and upload it
  Future<void> pickAndUploadImage({
    required ImageSource source,
    required Function(String) onSuccess,
    required Function(String) onError,
  }) async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (image != null) {
        await _uploadImage(File(image.path), onSuccess, onError);
      }
    } catch (e) {
      onError('Failed to pick image: $e');
    }
  }

  /// Upload image to Supabase storage and handle success/error
  Future<void> _uploadImage(
    File imageFile,
    Function(String) onSuccess,
    Function(String) onError,
  ) async {
    // Show loading dialog first
    if (context.mounted) {
      openLoadingAnimatedDialog(
        context,
        'uploading_image',
        'Uploading Image',
        'Please wait while we upload your profile picture...',
      );
    }

    try {
      // Get current user from both user cubit and profile cubit for reliability
      UserModel? currentUser = context.read<UserCubit>().getCurrentUser();
      currentUser ??= context.read<ProfileCubit>().currentUser;

      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // Initialize Supabase storage service if not already done
      await SupabaseStorageService.initSupabaseStorage();

      // Upload image to Supabase storage
      final storageService = SupabaseStorageService();
      final imageUrl = await storageService.uploadFile(
        imageFile,
        'profile_pictures',
        currentUser.uid,
      );

      if (context.mounted) {
        // Close the loading dialog
        Navigator.of(context).pop();
        
        // Call success callback
        onSuccess(imageUrl);
      }
    } catch (e) {
      if (context.mounted) {
        // Close the loading dialog
        Navigator.of(context).pop();
        
        // Call error callback
        onError(e.toString());
      }
    }
  }

  /// Check if user has existing profile picture
  bool hasExistingPicture(UserModel? user) {
    return user?.profilePic != null && user!.profilePic.isNotEmpty;
  }
}