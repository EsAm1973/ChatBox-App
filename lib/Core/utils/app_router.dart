import 'package:chatbox/Features/onboarding/presentation/views/onboard_view.dart';
import 'package:chatbox/Features/splash/presentation/views/splash_view.dart';
import 'package:go_router/go_router.dart';

abstract class AppRouter {
  static const String kSplashRoute = '/';
  static const String kOnboardRoute = '/onboard';
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
    ],
  );
}
