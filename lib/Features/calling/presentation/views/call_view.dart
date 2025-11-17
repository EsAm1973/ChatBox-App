import 'package:chatbox/Features/calling/presentation/views/widgets/call_view_body.dart';
import 'package:flutter/material.dart';

class CallView extends StatelessWidget {
  const CallView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SafeArea(child: CallViewBody()));
  }
}
