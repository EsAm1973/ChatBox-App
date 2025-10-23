import 'package:chatbox/Core/helper%20functions/formatted_date_and_days.dart';
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
  final Function(MessageModel)? onRetryMessage;
  const MessageList({
    super.key,
    required this.messages,
    required this.scrollController,
    this.onRetryMessage,
  });

  @override
  Widget build(BuildContext context) {
    final msgs = messages;

    if (msgs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64.r,
              color: Theme.of(context).iconTheme.color,
            ),
            SizedBox(height: 16.h),
            const Text('No messages yet'),
            Text(
              'Start a conversation!',
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            ),
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
        final messageTimestamp = message.timestamp ?? DateTime.now();
        final previousMessageTimestamp =
            index > 0
                ? (msgs[index - 1].timestamp ?? DateTime.now())
                : DateTime.now();
        return Column(
          children: [
            if (index == 0 ||
                isDifferentDay(previousMessageTimestamp, messageTimestamp))
              DateHeader(date: formatDate(messageTimestamp)),

            if (isMe)
              GestureDetector(
                onTap:
                    message.status == MessageStatus.failed
                        ? () => onRetryMessage?.call(message)
                        : null,
                child: SentMessage(
                  time: formatTime(messageTimestamp),
                  message: message.content,
                  status: message.status,
                  isSeen: message.isRead,
                ),
              )
            else
              ReceivedMessage(
                time: formatTime(messageTimestamp),
                messages: [message.content],
              ),

            SizedBox(height: 10.h),

            if (index > 0 &&
                isDifferentDay(previousMessageTimestamp, messageTimestamp))
              const MessageDivider(),
          ],
        );
      },
    );
  }
}
