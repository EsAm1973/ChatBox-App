import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';

class ProfileEditDialog extends StatelessWidget {
  final String title;
  final String initialValue;
  final Function(String) onSave;

  const ProfileEditDialog({
    super.key,
    required this.title,
    required this.initialValue,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required String title,
    required String initialValue,
    required Function(String) onSave,
  }) {
    return showDialog(
      context: context,
      builder: (context) => ProfileEditDialog(
        title: title,
        initialValue: initialValue,
        onSave: onSave,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final controller = TextEditingController(text: initialValue);
    final formKey = GlobalKey<FormState>();

    return AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20.r),
      ),
      title: Text(
        title,
        style: AppTextStyles.semiBold20.copyWith(
          color: Theme.of(context).textTheme.bodyLarge?.color,
        ),
      ),
      content: Form(
        key: formKey,
        child: TextFormField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'This field cannot be empty';
            }
            return null;
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            'Cancel',
            style: AppTextStyles.regular14.copyWith(
              color: Theme.of(context).textTheme.bodyMedium?.color,
            ),
          ),
        ),
        ElevatedButton(
          onPressed: () {
            if (formKey.currentState!.validate()) {
              onSave(controller.text.trim());
              Navigator.pop(context);
            }
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Theme.of(context).primaryColor,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Save',
            style: AppTextStyles.semiBold14.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}