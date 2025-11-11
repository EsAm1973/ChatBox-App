import 'package:chatbox/Core/cubit/user%20cubit/user_cubit.dart';
import 'package:chatbox/Core/repos/user%20repo/user_repo.dart';
import 'package:chatbox/Core/service/bloc_observer.dart';
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
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Bloc.observer = CustomBlocObserver();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await requestPermission();
  ZegoUIKitPrebuiltCallInvitationService().setNavigatorKey(rootNavigatorKey);
  await ZegoUIKitPrebuiltCallInvitationService()
      .init(
        appID: appIdZegoCloud,
        appSign: appSignZegoCloud,
        userID: FirebaseAuth.instance.currentUser?.uid ?? '000',
        userName: FirebaseAuth.instance.currentUser?.displayName ?? '000',
        plugins: [ZegoUIKitSignalingPlugin()],
        invitationEvents: ZegoUIKitPrebuiltCallInvitationEvents(),
      )
      .catchError((error) => print(error));
  await Prefs.init();
  await SupabaseStorageService.initSupabaseStorage();
  await SupabaseStorageService.initializeDownloadedFiles();
  setupGetIt();
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

class ChatBox extends StatelessWidget {
  const ChatBox({super.key});
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
