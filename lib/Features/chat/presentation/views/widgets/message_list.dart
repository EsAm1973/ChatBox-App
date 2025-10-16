import 'package:chatbox/Features/chat/presentation/views/widgets/date_header.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/message_divider.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/recieve_message.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/sent_message.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MessageList extends StatelessWidget {
  const MessageList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
      children: const [
        DateHeader(date: 'Today'),
        SentMessage(time: '09:25 AM', message: 'Hello! Jhon abraham'),
        MessageDivider(),
        ReceivedMessage(
          time: '09:25 AM',
          messages: ['Hello ! Narzu! How are you?', 'You did your job well!'],
        ),
        MessageDivider(),
        ReceivedMessage(
          time: '09:22 AM',
          messages: ['Have a great working week!!', 'Hope you like it'],
        ),
      ],
    );
  }
}
