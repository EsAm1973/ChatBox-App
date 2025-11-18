import 'package:chatbox/Core/helper%20functions/chat_input_methods.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_cubit.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ChatInput extends StatefulWidget {
  final UserModel otherUser;

  const ChatInput({super.key, required this.otherUser});

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _messageController = TextEditingController();
  bool _isRecording = false;

  void _updateRecordingState(bool recording) {
    setState(() {
      _isRecording = recording;
    });
  }

  void _handleTextChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ChatCubit, ChatState>(
      builder: (context, state) {
        final isSending = state is MessageSending;

        return ChatInputMethods.buildChatInput(
          context: context,
          messageController: _messageController,
          isRecording: _isRecording,
          isSending: isSending,
          receiverId: widget.otherUser.uid,
          updateRecordingState: _updateRecordingState,
          onTextChanged: _handleTextChanged, // أضف هذا الباراميتر
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
