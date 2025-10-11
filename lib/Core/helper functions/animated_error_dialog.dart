import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void openErrorAnimatedDialog(
  BuildContext context,
  String label,
  String title,
  String description,
  String buttonText,
  void Function(BuildContext context) onTransition,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: true,
    barrierLabel: label,
    transitionDuration: const Duration(milliseconds: 500),
    pageBuilder: (context, anim1, anim2) {
      return Container();
    },
    transitionBuilder: (context, anim1, anim2, child) {
      final curvedValue = Curves.easeInOut.transform(anim1.value) - 1.0;

      return Transform(
        transform: Matrix4.translationValues(0.0, curvedValue * -300, 0.0),
        child: Opacity(
          opacity: anim1.value,
          child: AlertDialog(
            backgroundColor: Theme.of(context).colorScheme.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30.r),
            ),
            contentPadding: EdgeInsets.all(30.r),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // تغيير الأيقونة إلى أيقونة خطأ
                Icon(Icons.error_outline, color: Colors.red, size: 80.r),
                SizedBox(height: 20.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.red, // إضافة لون أحمر للعنوان
                  ),
                ),
                SizedBox(height: 15.h),
                Text(
                  description,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                SizedBox(height: 25.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop(); // استخدام Navigator بدلاً من GoRouter
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // تغيير لون الزر إلى الأحمر
                      padding: EdgeInsets.symmetric(vertical: 15.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.r),
                      ),
                    ),
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white, // نص أبيض للزر الأحمر
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  ).then((_) {
    onTransition(context);
  });
}