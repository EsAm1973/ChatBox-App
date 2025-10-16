import 'package:chatbox/Features/chat/presentation/views/widgets/chat_appbar.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/chat_input.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/message_list.dart';
import 'package:flutter/material.dart';

class ChatViewBody extends StatelessWidget {
  const ChatViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [ChatAppBar(), Expanded(child: MessageList()), ChatInput()],
    );
  }
}
