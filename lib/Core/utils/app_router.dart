import 'package:chatbox/Core/service/getit_service.dart';
import 'package:chatbox/Features/auth/presentation/manager/login/login_cubit.dart';
import 'package:chatbox/Features/auth/presentation/manager/recover%20password/recover_password_cubit.dart';
import 'package:chatbox/Features/auth/presentation/manager/register/register_cubit.dart';
import 'package:chatbox/Features/auth/data/repos/auth_repo.dart';
import 'package:chatbox/Features/auth/presentation/views/choose_picture_view.dart';
import 'package:chatbox/Features/auth/presentation/views/login_view.dart';
import 'package:chatbox/Features/auth/presentation/views/recover_pass_view.dart';
import 'package:chatbox/Features/auth/presentation/views/signup_view.dart';
import 'package:chatbox/Features/chat/presentation/views/chat_view.dart';
import 'package:chatbox/Features/home/data/repos/home_repo.dart';
import 'package:chatbox/Features/home/presentation/manager/search%20user/search_user_cubit.dart';
import 'package:chatbox/Features/home/presentation/views/home_view.dart';
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
  static const String kRecoverPasswordRoute = '/recover-password';
  static const String kHomeRoute = '/home';
  static const String kChatScreenRoute = '/chat-screen';
  static final router = GoRouter(
    routes: [
      GoRoute(
        path: kSplashRoute,
        builder: (context, state) => const SplashView(),
      ),
      GoRoute(
        path: kOnboardRoute,
        builder:
            (context, state) => BlocProvider(
              create: (context) => LoginCubit(getIt<AuthRepo>()),
              child: const OnboardView(),
            ),
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
      GoRoute(
        path: kRecoverPasswordRoute,
        builder:
            (context, state) => BlocProvider(
              create: (context) => RecoverPasswordCubit(getIt<AuthRepo>()),
              child: const RecoverPassView(),
            ),
      ),
      GoRoute(
        path: kHomeRoute,
        builder:
            (context, state) => BlocProvider(
              create:
                  (context) =>
                      SearchUserCubit(homeRepository: getIt<HomeRepo>()),
              child: const HomeView(),
            ),
      ),
      GoRoute(
        path: kChatScreenRoute,
        builder: (context, state) => const ChatView(),
      ),
    ],
  );
}
