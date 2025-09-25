import 'package:chatbox/Core/service/getit_service.dart';
import 'package:chatbox/Features/auth/manager/login/login_cubit.dart';
import 'package:chatbox/Features/auth/manager/register/register_cubit.dart';
import 'package:chatbox/Features/auth/presentation/data/repos/auth_repo.dart';
import 'package:chatbox/Features/auth/presentation/views/choose_picture_view.dart';
import 'package:chatbox/Features/auth/presentation/views/login_view.dart';
import 'package:chatbox/Features/auth/presentation/views/signup_view.dart';
import 'package:chatbox/Features/onboarding/presentation/views/onboard_view.dart';
import 'package:chatbox/Features/splash/presentation/views/splash_view.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const String kSplashRoute = '/';
  static const String kOnboardRoute = '/onboard';
  static const String kLoginRoute = '/login';
  static const String kSignupRoute = '/signup';
  static const String kChoosePictureRoute = '/choose-picture';
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: kSplashRoute,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: kOnboardRoute,
        builder: (context, state) => const OnboardView(),
      ),
      GoRoute(
        path: kLoginRoute,
        builder:
            (context, state) => BlocProvider(
              create: (context) => LoginCubit(getIt<AuthRepo>()),
              child: const LoginView(),
            ),
      ),
      GoRoute(
        path: kSignupRoute,
        builder: (context, state) => const SignupView(),
      ),
      GoRoute(
        path: kChoosePictureRoute,
        builder: (context, state) {
          final extra = state.extra;
          if (extra == null || extra is! Map<String, dynamic>) {
            throw Exception('Expected Map<String, dynamic> in state.extra');
          }

          final data = extra;
          final name = data['name'] as String? ?? '';
          final email = data['email'] as String? ?? '';
          final password = data['password'] as String? ?? '';

          return BlocProvider(
            create: (context) => RegisterCubit(getIt<AuthRepo>()),
            child: ChoosePictureScreen(
              email: email,
              password: password,
              name: name,
            ),
          );
        },
      ),
    ],
  );
}
