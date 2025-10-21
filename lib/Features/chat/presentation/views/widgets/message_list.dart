import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/date_header.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/message_divider.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/recieve_message.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/sent_message.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageList extends StatelessWidget {
  final List<MessageModel> messages;
  final ScrollController scrollController;
  const MessageList({
    super.key,
    required this.messages,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    final msgs = messages;

    if (msgs.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('No messages yet'),
            Text('Start a conversation!', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: scrollController,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      itemCount: msgs.length,
      itemBuilder: (context, index) {
        final message = msgs[index];
        final isMe = message.senderId == FirebaseAuth.instance.currentUser!.uid;

        return Column(
          children: [
            if (index == 0 ||
                _isDifferentDay(msgs[index - 1].timestamp, message.timestamp))
              DateHeader(date: _formatDate(message.timestamp)),

            if (isMe)
              SentMessage(
                time: _formatTime(message.timestamp),
                message: message.content,
                isSeen: message.isRead,
              )
            else
              ReceivedMessage(
                time: _formatTime(message.timestamp),
                messages: [message.content],
              ),

            const SizedBox(height: 10),

            if (index > 0 &&
                _isDifferentDay(msgs[index - 1].timestamp, message.timestamp))
              const MessageDivider(),
          ],
        );
      },
    );
  }

  bool _isDifferentDay(DateTime date1, DateTime date2) {
    return date1.year != date2.year ||
        date1.month != date2.month ||
        date1.day != date2.day;
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    if (messageDate == today) {
      return 'Today';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Yesterday';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  String _formatTime(DateTime timestamp) {
    return '${timestamp.hour}:${timestamp.minute.toString().padLeft(2, '0')}';
  }
}
