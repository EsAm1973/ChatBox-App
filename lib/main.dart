import 'dart:async';

import 'package:chatbox/Core/cubit/toggle%20theme/toggle_theme_cubit.dart';
import 'package:chatbox/Core/cubit/user%20cubit/user_cubit.dart';
import 'package:chatbox/Core/repos/user%20repo/user_repo.dart';
import 'package:chatbox/Core/service/bloc_observer.dart';
import 'package:chatbox/Core/service/getit_service.dart';
import 'package:chatbox/Core/service/shared_prefrences_sengelton.dart';
import 'package:chatbox/Core/service/supabase_storage.dart';
import 'package:chatbox/Core/service/theme_service.dart';
import 'package:chatbox/Core/service/zego_service.dart';
import 'package:chatbox/Core/theme/dark_theme.dart';
import 'package:chatbox/Core/theme/light_theme.dart';
import 'package:chatbox/Core/utils/app_router.dart';
import 'package:chatbox/Core/utils/app_theme_enum.dart';
import 'package:chatbox/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
late ZegoService zegoService;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = CustomBlocObserver();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await requestPermission();
  setupGetIt();
  zegoService = ZegoService(navigatorKey: rootNavigatorKey);

  await Prefs.init();
  await SupabaseStorageService.initSupabaseStorage();
  await SupabaseStorageService.initializeDownloadedFiles();

  // Pre-initialize theme to avoid flash
  final initialTheme = await ThemeService.getInitialTheme();

  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ToggleThemeCubit()..setTheme(initialTheme),
        ),
        BlocProvider(
          create: (context) => UserCubit(userRepo: getIt<UserRepo>()),
        ),
      ],
      child: const ChatBox(),
    ),
  );
}

Future<void> requestPermission() async {
  await [
    Permission.camera,
    Permission.microphone,
    Permission.notification,
  ].request();
}

class ChatBox extends StatefulWidget {
  const ChatBox({super.key});

  @override
  State<ChatBox> createState() => _ChatBoxState();
}

class _ChatBoxState extends State<ChatBox> with WidgetsBindingObserver {
  StreamSubscription<User?>? _authSubscription;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _authSubscription =
        FirebaseAuth.instance.authStateChanges().listen((User? user) {
      if (user != null) {
        // User is signed in.
        zegoService.initForUser(user);
      } else {
        // User is signed out.
        zegoService.uninit();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _authSubscription?.cancel();
    zegoService.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      zegoService.callEventsHandler.completeAllActiveCalls();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: BlocBuilder<ToggleThemeCubit, AppTheme>(
        builder: (context, theme) {
          return MaterialApp.router(
            routerConfig: AppRouter.router,
            debugShowCheckedModeBanner: false,
            title: 'ChatBox',
            theme: theme == AppTheme.dark ? darkTheme : lightTheme,
            themeAnimationCurve: Curves.linear,
            themeAnimationDuration: const Duration(milliseconds: 300),
          );
        },
      ),
    );
  }
}
