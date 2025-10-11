import 'package:chatbox/Features/home/presentation/views/widgets/home_appbar.dart';
import 'package:chatbox/Features/home/presentation/views/widgets/home_view_body.dart';
import 'package:flutter/material.dart';

class HomeView extends StatelessWidget {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildHomeAppBar(context),
      body: const SafeArea(child: HomeViewBody()),
    );
  }
}
