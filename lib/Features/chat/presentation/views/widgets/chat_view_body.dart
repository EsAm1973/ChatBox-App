import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_cubit.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_state.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/chat_appbar.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/chat_input.dart';
import 'package:chatbox/Features/chat/presentation/views/widgets/message_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ChatViewBody extends StatefulWidget {
  const ChatViewBody({super.key, required this.otherUser});
  final UserModel otherUser;

  @override
  State<ChatViewBody> createState() => _ChatViewBodyState();
}

class _ChatViewBodyState extends State<ChatViewBody> {
  @override
  void initState() {
    super.initState();
    // استخدام الـ Cubit الجديد لتهيئة الدردشة
    context.read<ChatCubit>().initializeChat(
      FirebaseAuth.instance.currentUser!.uid,
      widget.otherUser.uid,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ChatCubit, ChatState>(
      listener: (context, state) {
        if (state is ChatError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is MessagesLoaded ||
            state is MessageSent ||
            state is MessageSending) {
          return Column(
            children: [
              ChatAppBar(otherUser: widget.otherUser),
              Expanded(child: MessageList(messages: state.messages)),
              ChatInput(otherUser: widget.otherUser),
            ],
          );
        } else if (state is ChatLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is ChatError) {
          return Column(
            children: [
              ChatAppBar(otherUser: widget.otherUser),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Error: ${state.error}'),
                      SizedBox(height: 16.h),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ChatCubit>().initializeChat(
                            FirebaseAuth.instance.currentUser!.uid,
                            widget.otherUser.uid,
                          );
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
