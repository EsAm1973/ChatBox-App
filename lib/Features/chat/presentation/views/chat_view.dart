import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/chat_view_body.dart';
import 'package:flutter/material.dart';

class ChatView extends StatelessWidget {
  const ChatView({super.key, required this.otherUser});
  final UserModel otherUser;
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: ChatViewBody(otherUser: otherUser)));
  }
}
