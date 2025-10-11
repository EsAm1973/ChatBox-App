import 'package:chatbox/Features/auth/presentation/views/widgets/recoverpass_view_body.dart';
import 'package:flutter/material.dart';

class RecoverPassView extends StatelessWidget {
  const RecoverPassView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: RecoverPassViewBody()));
  }
}
