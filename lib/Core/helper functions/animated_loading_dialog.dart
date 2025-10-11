import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void openLoadingAnimatedDialog(
  BuildContext context,
  String label,
  String title,
  String description,
) {
  showGeneralDialog(
    context: context,
    barrierDismissible: false, // لمنع المستخدم من إغلاق الدايالوج بالنقر خارجها
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
                // استبدال الأيقونة بمؤشر تحميل
                SizedBox(
                  width: 80.r,
                  height: 80.r,
                  child: CircularProgressIndicator(
                    strokeWidth: 4.w,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
                SizedBox(height: 20.h),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
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
                // تم إزالة الزر لأنه غير ضروري في Loading Dialog
              ],
            ),
          ),
        ),
      );
    },
  );
}