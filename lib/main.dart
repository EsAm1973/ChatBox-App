import 'package:chatbox/Core/cubit/user%20cubit/user_cubit.dart';
import 'package:chatbox/Core/helper%20functions/call_events_handler.dart';
import 'package:chatbox/Core/repos/user%20repo/user_repo.dart';
import 'package:chatbox/Core/service/bloc_observer.dart';
import 'package:chatbox/Core/service/firestore_call_service.dart';
import 'package:chatbox/Core/service/getit_service.dart';
import 'package:chatbox/Core/service/shared_prefrences_sengelton.dart';
import 'package:chatbox/Core/service/supabase_storage.dart';
import 'package:chatbox/Core/utils/app_router.dart';
import 'package:chatbox/Core/utils/app_theme.dart';
import 'package:chatbox/constants.dart';
import 'package:chatbox/firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:zego_uikit_prebuilt_call/zego_uikit_prebuilt_call.dart';
import 'package:zego_uikit_signaling_plugin/zego_uikit_signaling_plugin.dart';

final GlobalKey<NavigatorState> rootNavigatorKey = GlobalKey<NavigatorState>();
late CallEventsHandler _callEventsHandler;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = CustomBlocObserver();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await requestPermission();
  setupGetIt();
  _callEventsHandler = CallEventsHandler(getIt<FirestoreCallService>());

  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(rootNavigatorKey);

  await ZegoUIKitPrebuiltCallInvitationService()
      .init(
        appID: appIdZegoCloud,
        appSign: appSignZegoCloud,
        userID: FirebaseAuth.instance.currentUser?.uid ?? '000',
        userName: FirebaseAuth.instance.currentUser?.displayName ?? '000',
        plugins: [ZegoUIKitSignalingPlugin()],
        invitationEvents: _callEventsHandler.getInvitationEvents(),
        requireConfig: (ZegoCallInvitationData data) {
          return ZegoUIKitPrebuiltCallConfig(
            durationConfig: ZegoCallDurationConfig(isVisible: true),
          );
        },
      )
      .catchError((error) => print('❌ ZegoCloud init error: $error'));

  await Prefs.init();
  await SupabaseStorageService.initSupabaseStorage();
  await SupabaseStorageService.initializeDownloadedFiles();

  runApp(
    BlocProvider(
      create: (context) => UserCubit(userRepo: getIt<UserRepo>()),
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
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _callEventsHandler.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      _callEventsHandler.completeAllActiveCalls();
    }
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      child: MaterialApp.router(
        routerConfig: AppRouter.router,
        debugShowCheckedModeBanner: false,
        title: 'ChatBox',
        theme: AppThemes.getLightTheme,
      ),
    );
  }
}
