import 'package:chatbox/Core/utils/app_router.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Core/widgets/custom_bottom.dart';
import 'package:chatbox/Core/widgets/custom_textfeild.dart';
import 'package:chatbox/Features/auth/data/mixins/auth_validator_mixin.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class SignupViewBody extends StatefulWidget {
  const SignupViewBody({super.key});

  @override
  State<SignupViewBody> createState() => _SignupViewBodyState();
}

class _SignupViewBodyState extends State<SignupViewBody> with AppValidators {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
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
                child: Text('Sign up with Email', style: AppTextStyles.bold18),
              ),
              SizedBox(height: 17.h),
              Text(
                'Get chatting with friends and family today by signing up for our chat app!',
                textAlign: TextAlign.center,
                style: AppTextStyles.regular14.copyWith(
                  color: Theme.of(
                    context,
                  ).colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 60.h),
              CustomTextFormField(
                labelText: 'Your name',
                controller: _nameController,
                isPassword: false,
                keyboardType: TextInputType.name,
                validator: validateName,
              ),
              SizedBox(height: 30.h),
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
              SizedBox(height: 30.h),
              CustomTextFormField(
                labelText: 'Confirm Password',
                controller: _confirmPasswordController,
                isPassword: true,
                keyboardType: TextInputType.visiblePassword,
                validator:
                    (value) => validateConfirmPassword(
                      _passwordController.text,
                      value,
                    ),
              ),
              SizedBox(height: 100.h),
              CustomBottom(
                text: 'Next',
                backgroundColor: Theme.of(context).colorScheme.primary,
                textColor: Theme.of(context).colorScheme.onPrimary,
                onTap: () {
                  if (_formKey.currentState!.validate()) {
                    // If the form is valid, you can process the data.
                    GoRouter.of(context).push(
                      AppRouter.kChoosePictureRoute,
                      extra: {
                        'name': _nameController.text,
                        'email': _emailController.text,
                        'password': _passwordController.text,
                      },
                    );
                  } else {}
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
