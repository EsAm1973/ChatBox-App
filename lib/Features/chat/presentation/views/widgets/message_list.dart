import 'package:chatbox/Core/helper%20functions/formatted_date_and_days.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/date_header.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/recieve_attachment_message.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/recieve_message.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/recieve_voice_message.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/sent_attachment_message.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/sent_message.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/sent_voice_message.dart';
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

        return Padding(
          padding: EdgeInsets.only(top: 15.h),
          child: Column(
            children: [
              if (index == 0 ||
                  isDifferentDay(previousMessageTimestamp, messageTimestamp))
                DateHeader(date: formatDate(messageTimestamp)),

              // الرسائل الصوتية
              if (message.type == MessageType.voice)
                isMe
                    ? SentVoiceMessage(
                      voiceUrl: message.content,
                      duration: message.voiceDuration ?? 0,
                      time: formatTime(messageTimestamp),
                      isSeen: message.isRead,
                      status: message.status,
                    )
                    : ReceivedVoiceMessage(
                      voiceUrl: message.content,
                      duration: message.voiceDuration ?? 0,
                      time: formatTime(messageTimestamp),
                    )
              // الرسائل النصية
              else if (message.type == MessageType.text)
                GestureDetector(
                  onTap:
                      message.status == MessageStatus.failed
                          ? () => onRetryMessage?.call(message)
                          : null,
                  child:
                      isMe
                          ? SentMessage(
                            time: formatTime(messageTimestamp),
                            message: message.content,
                            status: message.status,
                            isSeen: message.isRead,
                          )
                          : ReceivedMessage(
                            time: formatTime(messageTimestamp),
                            messages: [message.content],
                          ),
                )
              // المرفقات (صور وملفات)
              else if (message.type == MessageType.image ||
                  message.type == MessageType.file)
                isMe
                    ? SentAttachmentMessage(
                      fileUrl: message.content,
                      time: formatTime(messageTimestamp),
                      isSeen: message.isRead,
                      status: message.status,
                      messageType: message.type,
                      fileName: _getFileNameFromUrl(message.content),
                      onRetry:
                          message.status == MessageStatus.failed
                              ? () => onRetryMessage?.call(message)
                              : null,
                    )
                    : ReceivedAttachmentMessage(
                      fileUrl: message.content,
                      time: formatTime(messageTimestamp),
                      messageType: message.type,
                      fileName: _getFileNameFromUrl(message.content),
                      message: message,
                    ),

              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  String? _getFileNameFromUrl(String url) {
    try {
      final uri = Uri.parse(url);
      final pathSegments = uri.pathSegments;
      return pathSegments.isNotEmpty ? pathSegments.last : null;
    } catch (e) {
      return null;
    }
  }
}
