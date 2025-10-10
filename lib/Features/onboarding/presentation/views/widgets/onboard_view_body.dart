import 'package:chatbox/Core/helper%20functions/animated_error_dialog.dart';
import 'package:chatbox/Core/helper%20functions/animated_loading_dialog.dart';
import 'package:chatbox/Core/utils/app_router.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Core/widgets/custom_bottom.dart';
import 'package:chatbox/Features/auth/presentation/manager/login/login_cubit.dart';
import 'package:chatbox/Features/onboarding/presentation/views/widgets/login_row.dart';
import 'package:chatbox/Core/widgets/socialmedia_login_widget.dart';
import 'package:chatbox/Core/widgets/or_divider.dart';
import 'package:chatbox/Features/onboarding/presentation/views/widgets/welcome_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class OnboardViewBody extends StatelessWidget {
  const OnboardViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginCubit, LoginState>(
      listener: (context, state) {
        if (state is LoginSuccess) {
          //GoRouter.of(context).push(AppRouter.kHomeRoute);
          GoRouter.of(context).pop();
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Login successful!')));
        } else if (state is LoginError) {
          GoRouter.of(context).pop();
          openErrorAnimatedDialog(
            context,
            'Error',
            'Error in login',
            state.errorMessage,
            'Ok',
            (context) {},
          );
        } else if (state is LoginLoading) {
          openLoadingAnimatedDialog(
            context,
            'Loading Dialog',
            'Login in progress',
            'Please wait until login is completed',
          );
        }
      },
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 17.h),
        child: SingleChildScrollView(
          child: Column(
            children: [
              const WelcomeAppBar(),
              SizedBox(height: 30.h),
              Text(
                'Connect friends easily & quickly',
                style: AppTextStyles.bold68,
              ),
              SizedBox(height: 16.h),
              Text(
                'Our chat app is the perfect way to stay connected with friends and family.',
                style: AppTextStyles.regular16.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withValues(alpha: 0.7),
                ),
              ),
              SizedBox(height: 38.h),
              const SocialMediaLoginWidget(),
              SizedBox(height: 30.h),
              const OrDivider(),
              SizedBox(height: 30.h),
              CustomBottom(
                text: 'Sign up with email',
                backgroundColor: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
                onTap: () {
                  GoRouter.of(context).push(AppRouter.kSignupRoute);
                },
              ),
              SizedBox(height: 30.h),
              LoginRow(
                onTap: () {
                  GoRouter.of(context).push(AppRouter.kLoginRoute);
                },
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
