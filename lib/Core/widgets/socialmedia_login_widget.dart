import 'package:chatbox/Features/auth/presentation/manager/login/login_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart' show BlocBuilder, ReadContext;
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:svg_flutter/svg_flutter.dart';

class SocialMediaLoginWidget extends StatelessWidget {
  const SocialMediaLoginWidget({super.key});
  String _getAppleIconPath(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? 'assets/apple logo light.svg'
        : 'assets/apple logo dark.svg';
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildSocialButton(
          iconAssetPath: 'assets/facebook logo.svg',
          onPressed: () {
            context.read<LoginCubit>().signInWithFacebook();
          },
          context: context,
        ),
        SizedBox(width: 20.w),

        _buildSocialButton(
          iconAssetPath: 'assets/google logo.svg',
          onPressed: () {
            context.read<LoginCubit>().signInWithGoogle();
          },
          context: context,
        ),
        SizedBox(width: 20.w),

        _buildSocialButton(
          iconAssetPath: _getAppleIconPath(context),
          onPressed: () {},
          context: context,
        ),
      ],
    );
  }

  Widget _buildSocialButton({
    required String iconAssetPath,
    required VoidCallback onPressed,
    required BuildContext context,
  }) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: EdgeInsets.all(10.r),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Theme.of(context).colorScheme.onSurface,
            width: 1.w,
          ),
        ),
        child: SvgPicture.asset(
          iconAssetPath,
          width: 28.w,
          height: 28.h,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
