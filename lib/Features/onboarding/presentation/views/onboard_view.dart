import 'package:chatbox/Features/onboarding/presentation/views/widgets/onboard_view_body.dart';
import 'package:flutter/material.dart';

class OnboardView extends StatelessWidget {
  const OnboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: const SafeArea(child: OnboardViewBody()),
    );
  }
}
