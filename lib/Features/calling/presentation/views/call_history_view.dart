import 'package:chatbox/Features/calling/presentation/views/widgets/call_history_app_bar.dart';
import 'package:chatbox/Features/calling/presentation/views/widgets/call_history_view_body.dart';
import 'package:flutter/material.dart';

class CallHistoryView extends StatelessWidget {
  const CallHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CallHistoryAppBar(),
      body: SafeArea(
        child: CallHistoryViewBody(),
      ),
    );
  }
}
