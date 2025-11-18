import 'package:chatbox/Core/cubit/user%20cubit/user_cubit.dart';
import 'package:chatbox/Core/utils/app_router.dart';
import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:svg_flutter/svg.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  void _initializeApp() {
    final userCubit = context.read<UserCubit>();

    // استمع لتغيرات حالة المصادقة
    FirebaseAuth.instance.authStateChanges().listen((User? user) async {
      if (user != null && mounted) {
        await userCubit.loadUser(user.uid);

        userCubit.subscribeToUserUpdates(user.uid);

        _navigateToHome();
      } else if (mounted) {
        _navigateToOnboard();
      }
    });
  }

  void _navigateToHome() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        GoRouter.of(context).pushReplacement(AppRouter.kHomeNavigationBarRoute);
      }
    });
  }

  void _navigateToOnboard() {
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        GoRouter.of(context).pushReplacement(AppRouter.kOnboardRoute);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.asset('assets/logo.svg', height: 80.h, width: 80.w),
              SizedBox(height: 13.h),
              Text('ChatBox', style: AppTextStyles.semiBold40),
            ],
          ),
        ),
      ),
    );
  }
}
