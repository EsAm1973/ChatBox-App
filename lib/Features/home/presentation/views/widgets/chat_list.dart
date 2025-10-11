import 'package:chatbox/Features/home/data/models/chat_message.dart';
import 'package:chatbox/Features/home/presentation/views/widgets/chat_list_item.dart';
import 'package:flutter/material.dart';

class ChatList extends StatelessWidget {
  const ChatList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: mockChats.length,
      itemBuilder: (context, index) {
        final chat = mockChats[index];
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: ChatListItem(chat: chat),
        );
      },
    );
  }
}
