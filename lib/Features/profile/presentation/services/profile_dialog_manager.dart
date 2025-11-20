import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_edit_picture_bottom_sheet.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_edit_dialog.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_logout_dialog.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_delete_account_dialog.dart';

/// Service responsible for managing all profile-related dialogs and bottom sheets
class ProfileDialogManager {
  final BuildContext context;
  
  ProfileDialogManager(this.context);

  /// Show edit profile picture options bottom sheet
  Future<void> showEditPictureBottomSheet({
    required bool hasExistingPhoto,
    required VoidCallback onTakePhoto,
    required VoidCallback onChooseFromGallery,
  }) async {
    await ProfileEditPictureBottomSheet.show(
      context: context,
      onTakePhoto: onTakePhoto,
      onChooseFromGallery: onChooseFromGallery,
      hasExistingPhoto: hasExistingPhoto,
    );
  }

  /// Show edit dialog for any user field
  Future<void> showEditDialog({
    required String title,
    required String initialValue,
    required Function(String) onSave,
  }) async {
    await ProfileEditDialog.show(
      context: context,
      title: title,
      initialValue: initialValue,
      onSave: onSave,
    );
  }

  /// Show logout confirmation dialog
  Future<void> showLogoutDialog({
    required VoidCallback onLogout,
  }) async {
    await ProfileLogoutDialog.show(
      context: context,
      onLogout: onLogout,
    );
  }

  /// Show delete account confirmation dialog
  Future<void> showDeleteAccountDialog({
    required VoidCallback onDelete,
  }) async {
    await ProfileDeleteAccountDialog.show(
      context: context,
      onDelete: onDelete,
    );
  }

  /// Show loading indicator dialog
  Future<void> showLoadingDialog({
    String title = 'Loading',
    String message = 'Please wait...',
  }) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              SizedBox(height: 16.h),
              Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Close any open dialog
  void closeDialog() {
    if (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }

  /// Close all open dialogs
  void closeAllDialogs() {
    while (Navigator.canPop(context)) {
      Navigator.of(context).pop();
    }
  }
}