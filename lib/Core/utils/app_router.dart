import 'package:chatbox/Features/auth/presentation/views/login_view.dart';
import 'package:chatbox/Features/auth/presentation/views/signup_view.dart';
import 'package:chatbox/Features/onboarding/presentation/views/onboard_view.dart';
import 'package:chatbox/Features/splash/presentation/views/splash_view.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const String kSplashRoute = '/';
  static const String kOnboardRoute = '/onboard';
  static const String kLoginRoute = '/login';
  static const String kSignupRoute = '/signup';
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
        builder: (context, state) => const LoginView(),
      ),
      GoRoute(
        path: kSignupRoute,
        builder: (context, state) => const SignupView(),
      ),
    ],
  );
}
