import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatInput extends StatefulWidget {
  final String chatRoomId;
  final UserModel otherUser;

  const ChatInput({
    super.key,
    required this.chatRoomId,
    required this.otherUser,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _messageController = TextEditingController();
  bool _isSending = false;

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty || _isSending) {
      return;
    }

    setState(() {
      _isSending = true;
    });

    try {
      await context.read<ChatCubit>().sendMessage(
        text: _messageController.text.trim(),
        receiverId: widget.otherUser.uid,
      );

      _messageController.clear();
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
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
            onPressed: _isSending ? null : () {},
          ),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
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
                onSubmitted:
                    (_isSending || _messageController.text.trim().isEmpty)
                        ? null
                        : (_) => _sendMessage(),
                enabled: !_isSending,
              ),
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.mic_none_outlined,
              color: Theme.of(context).iconTheme.color,
              size: 28.r,
            ),
            onPressed: _isSending ? null : () {},
          ),
          _isSending
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
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
