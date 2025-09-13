import 'package:chatbox/Core/utils/app_router.dart';
import 'package:chatbox/Core/utils/app_theme.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
      title: 'ChatBox',
      theme: AppThemes.getLightTheme,
    );
  }
}
