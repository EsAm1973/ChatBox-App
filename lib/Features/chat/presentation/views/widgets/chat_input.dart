import 'dart:io';

import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_cubit.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_state.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/voice_recorder.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatInput extends StatefulWidget {
  final UserModel otherUser;

  const ChatInput({super.key, required this.otherUser});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _messageController = TextEditingController();
  bool _isRecording = false;

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final message = MessageModel(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: FirebaseAuth.instance.currentUser!.uid,
      receiverId: widget.otherUser.uid,
      content: _messageController.text.trim(),
      timestamp: DateTime.now(),
      isRead: false,
      type: MessageType.text,
    );

    context.read<ChatCubit>().sendMessage(message);
    _messageController.clear();
  }

  // جديد: دالة إرسال الرسالة الصوتية
  void _sendVoiceMessage(File voiceFile, int duration) {
    context.read<ChatCubit>().sendVoiceMessage(
      voiceFile: voiceFile,
      senderId: FirebaseAuth.instance.currentUser!.uid,
      receiverId: widget.otherUser.uid,
      duration: duration,
    );

    setState(() {
      _isRecording = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final isSending = state is MessageSending;

        if (_isRecording) {
          return VoiceRecorderWidget(
            onVoiceRecorded: _sendVoiceMessage,
            onCancel: () {
              setState(() {
                _isRecording = false;
              });
            },
          );
        }

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 4.0.w, vertical: 8.0.h),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.attachment,
                  color: Theme.of(context).iconTheme.color,
                  size: 28.r,
                ),
                onPressed: isSending ? null : () {},
              ),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(30.0.r),
                  ),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Write your message',
                      contentPadding: EdgeInsets.symmetric(
                        vertical: 12.0.h,
                        horizontal: 20.0.w,
                      ),
                    ),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    onSubmitted: isSending ? null : (_) => _sendMessage(),
                    enabled: !isSending,
                    onChanged: (value) {
                      setState(() {});
                    },
                  ),
                ),
              ),

              // جديد: عرض زر المايك أو الإرسال حسب النص
              if (_messageController.text.trim().isEmpty)
                IconButton(
                  icon: Icon(
                    Icons.mic_none_outlined,
                    color: Theme.of(context).iconTheme.color,
                    size: 28.r,
                  ),
                  onPressed:
                      isSending
                          ? null
                          : () {
                            setState(() {
                              _isRecording = true;
                            });
                          },
                )
              else
                isSending
                    ? Padding(
                      padding: EdgeInsets.all(8.0.r),
                      child: SizedBox(
                        width: 20.r,
                        height: 20.r,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      ),
                    )
                    : IconButton(
                      icon: Icon(
                        Icons.send,
                        color: Theme.of(context).iconTheme.color,
                        size: 28.r,
                      ),
                      onPressed: _sendMessage,
                    ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
