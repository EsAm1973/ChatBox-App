import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Core/widgets/custom_bottom.dart';
import 'package:chatbox/Core/widgets/custom_textfeild.dart';
import 'package:chatbox/Features/auth/presentation/data/mixins/auth_validator_mixin.dart';
import 'package:chatbox/Core/widgets/socialmedia_login_widget.dart';
import 'package:chatbox/Core/widgets/or_divider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LoginViewBody extends StatefulWidget {
  const LoginViewBody({super.key});

  @override
  State<LoginViewBody> createState() => _LoginViewBodyState();
}

class _LoginViewBodyState extends State<LoginViewBody> with AppValidators {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 17.h),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(height: 60.h),
              Center(
                child: Text('Log in to Chatbox', style: AppTextStyles.bold18),
              ),
              SizedBox(height: 17.h),
              Text(
                'Welcome back! Sign in using your social account or email to continue us',
                textAlign: TextAlign.center,
                style: AppTextStyles.regular14.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 32.h),
              const SocialMediaLoginWidget(),
              SizedBox(height: 32.h),
              const OrDivider(),
              SizedBox(height: 32.h),
              CustomTextFormField(
                labelText: 'Your email',
                controller: _emailController,
                isPassword: false,
                keyboardType: TextInputType.emailAddress,
                // Assign the validator function.
                validator: validateEmail,
              ),
              SizedBox(height: 30.h),
              CustomTextFormField(
                labelText: 'Password',
                controller: _passwordController,
                isPassword: true,
                keyboardType: TextInputType.visiblePassword,
                validator: validatePassword,
              ),

              SizedBox(height: 100.h),
              CustomBottom(
                text: 'Login',
                backgroundColor: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    // // If the form is valid, you can process the data.
                    // GoRouter.of(context).push(
                    //   AppRouter.kChoosePictureRoute,
                    //   extra: {
                    //     'name': _nameController.text,
                    //     'email': _emailController.text,
                    //     'password': _passwordController.text,
                    //   },
                    // );
                  } else {}
                },
              ),
              SizedBox(height: 16.h),
              TextButton(
                onPressed: () {},
                child: Text(
                  'Forgot password?',
                  style: AppTextStyles.semiBold14.copyWith(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
