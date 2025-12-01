import 'package:chatbox/Core/repos/user%20repo/user_repo.dart';
import 'package:chatbox/Core/service/getit_service.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/auth/presentation/manager/login/login_cubit.dart';
import 'package:chatbox/Features/auth/presentation/manager/recover%20password/recover_password_cubit.dart';
import 'package:chatbox/Features/auth/presentation/manager/register/register_cubit.dart';
import 'package:chatbox/Features/auth/data/repos/auth_repo.dart';
import 'package:chatbox/Features/auth/presentation/views/choose_picture_view.dart';
import 'package:chatbox/Features/auth/presentation/views/login_view.dart';
import 'package:chatbox/Features/auth/presentation/views/recover_pass_view.dart';
import 'package:chatbox/Features/auth/presentation/views/signup_view.dart';
import 'package:chatbox/Features/calling/data/repos/call_repo.dart';
import 'package:chatbox/Features/calling/presentation/manager/call/call_cubit.dart';
import 'package:chatbox/Features/calling/presentation/views/call_history_view.dart';
import 'package:chatbox/Features/chat/data/repos/chat_repo.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_cubit.dart';
import 'package:chatbox/Features/chat/presentation/views/chat_view.dart';
import 'package:chatbox/Features/home/data/repos/user_search_repo.dart';
import 'package:chatbox/Features/home/presentation/manager/home%20chats/home_chats_cubit.dart';
import 'package:chatbox/Features/home/presentation/manager/search%20user/search_user_cubit.dart';
import 'package:chatbox/Features/home/presentation/views/home_view.dart';
import 'package:chatbox/Features/navigation%20bar/presentation/views/home_navigation_bar_view.dart';
import 'package:chatbox/Features/onboarding/presentation/views/onboard_view.dart';
import 'package:chatbox/Features/splash/presentation/views/splash_view.dart';
import 'package:chatbox/Features/profile/data/repos/profile_repo.dart';
import 'package:chatbox/Features/profile/presentation/manager/profile_cubit/profile_cubit.dart';
import 'package:chatbox/Features/profile/presentation/views/profile_view.dart';
import 'package:chatbox/main.dart';
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
  static const String kHomeNavigationBarRoute = '/home-navigation-bar';
  static const String kChatScreenRoute = '/chat-screen';
  static const String kCallScreenRoute = '/call-screen';
  static const String kProfileRoute = '/profile';
  static const String kEditProfileRoute = '/edit-profile';
  static const String kPrivacySettingsRoute = '/privacy-settings';

  static final router = GoRouter(
    navigatorKey: rootNavigatorKey,
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
      GoRoute(path: kHomeRoute, builder: (context, state) => const HomeView()),
      GoRoute(
        path: kChatScreenRoute,
        builder:
            (context, state) => BlocProvider(
              create:
                  (context) => ChatCubit(getIt<ChatRepo>(), getIt<UserRepo>()),
              child: ChatView(otherUser: state.extra as UserModel),
            ),
      ),
      GoRoute(
        path: kCallScreenRoute,
        builder: (context, state) => const CallHistoryView(),
      ),
      GoRoute(
        path: kProfileRoute,
        builder: (context, state) => const ProfileView(),
      ),
      GoRoute(
        path: kHomeNavigationBarRoute,
        builder:
            (context, state) => MultiBlocProvider(
              providers: [
                BlocProvider(
                  create:
                      (context) =>
                          HomeCubit(getIt<ChatRepo>(), getIt<UserRepo>()),
                ),
                BlocProvider(
                  create:
                      (context) => SearchUserCubit(
                        homeRepository: getIt<SearchUserRepo>(),
                      ),
                ),
                BlocProvider(
                  create:
                      (context) =>
                          ChatCubit(getIt<ChatRepo>(), getIt<UserRepo>()),
                ),
                BlocProvider(
                  create:
                      (context) =>
                          CallHistoryCubit(repository: getIt<CallRepo>()),
                ),
                BlocProvider(
                  create:
                      (context) =>
                          ProfileCubit(profileRepo: getIt<ProfileRepo>()),
                ),
              ],
              child: const HomeNavigationBar(),
            ),
      ),
    ],
  );
}
