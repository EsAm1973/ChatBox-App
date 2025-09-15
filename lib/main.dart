import 'package:chatbox/Core/service/getit_service.dart';
import 'package:chatbox/Core/service/supabase_storage.dart';
import 'package:chatbox/Core/utils/app_router.dart';
import 'package:chatbox/Core/utils/app_theme.dart';
import 'package:chatbox/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await SupabaseStorageService.initSupabaseStorage();
  setupGetIt();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
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
