import 'package:chatbox/Core/helper%20functions/animated_error_dialog.dart';
import 'package:chatbox/Core/helper%20functions/animated_success_dialog.dart';
import 'package:chatbox/Features/auth/presentation/manager/recover%20password/recover_password_cubit.dart';
import 'package:chatbox/Features/auth/presentation/views/widgets/recoverpass_button.dart';
import 'package:chatbox/Features/auth/presentation/views/widgets/recoverpass_email_textfeild.dart';
import 'package:chatbox/Features/auth/presentation/views/widgets/recoverpass_title.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class RecoverPassViewBody extends StatelessWidget {
  RecoverPassViewBody({super.key});
  final TextEditingController emailController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return BlocListener<RecoverPasswordCubit, RecoverPasswordState>(
      listener: (context, state) {
        if (state is RecoverPasswordError) {
          openErrorAnimatedDialog(
            context,
            'Error',
            'Error in recover',
            state.message,
            'Ok',
            (context) {},
          );
        } else if (state is RecoverPasswordSuccess) {
          openSuccessAnimatedDialog(
            context,
            'success',
            'Success',
            'We have sent a reset password link to your email',
            'Ok',
            (context) => GoRouter.of(context).pop(),
          );
        }
      },
      child: Center(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 20.h),
              child: Align(
                alignment: Alignment.topLeft,
                child: IconButton(
                  onPressed: () {
                    GoRouter.of(context).pop();
                  },
                  icon: Icon(
                    Icons.arrow_back_ios_new,
                    size: 30.sp,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
              ),
            ),
            SizedBox(height: 110.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              child: Column(
                children: [
                  const RecoverPassTitle(),
                  SizedBox(height: 30.h),
                  Form(
                    key: formKey,
                    child: RecoverPassEmailTextFeild(
                      emailController: emailController,
                    ),
                  ),
                  SizedBox(height: 50.h),
                  BlocBuilder<RecoverPasswordCubit, RecoverPasswordState>(
                    builder: (context, state) {
                      if (state is RecoverPasswordLoading) {
                        return const CircularProgressIndicator();
                      }
                      return RecoverPassButton(
                        onPressed: () {
                          if (formKey.currentState!.validate()) {
                            context
                                .read<RecoverPasswordCubit>()
                                .recoverPassword(email: emailController.text);
                          }
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
