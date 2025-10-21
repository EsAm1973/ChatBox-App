import 'package:chatbox/Core/utils/app_router.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/home/presentation/manager/home%20chats/home_chats_cubit.dart';
import 'package:chatbox/Features/home/presentation/manager/home%20chats/home_chats_state.dart';
import 'package:chatbox/Features/home/presentation/views/widgets/chat_list_item.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ChatList extends StatefulWidget {
  const ChatList({super.key});

  @override
  State<ChatList> createState() => _ChatListState();
}

class _ChatListState extends State<ChatList> {
  @override
  void initState() {
    super.initState();
    _loadChats();
  }

  void _loadChats() {
    final currentUserId = FirebaseAuth.instance.currentUser!.uid;
    context.read<HomeCubit>().loadUserChats(currentUserId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<HomeCubit, HomeState>(
      listener: (context, state) {
        if (state is HomeError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error), backgroundColor: Colors.red),
          );
        }
      },
      builder: (context, state) {
        if (state is HomeLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is HomeError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline, size: 48.r, color: Colors.red),
                SizedBox(height: 16.h),
                Text('Failed to load chats: ${state.error}'),
                SizedBox(height: 8.h),
                ElevatedButton(
                  onPressed: () {
                    final currentUserId =
                        FirebaseAuth.instance.currentUser!.uid;
                    context.read<HomeCubit>().loadUserChats(currentUserId);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is HomeLoaded) {
          final chats = state.chats;
          final usersCache = state.usersCache;
          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_outlined,
                    size: 64.r,
                    color: Theme.of(context).iconTheme.color,
                  ),
                  SizedBox(height: 16.h),
                  const Text('No conversations yet'),
                  Text(
                    'Start a new chat!',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final currentUserId = FirebaseAuth.instance.currentUser!.uid;

              final otherParticipantId = chat.participants.firstWhere(
                (id) => id != currentUserId,
                orElse: () => '',
              );

              if (otherParticipantId.isEmpty) {
                return const SizedBox();
              }

              final otherUser =
                  usersCache[otherParticipantId] ??
                  UserModel(
                    uid: otherParticipantId,
                    name: 'User',
                    email: '',
                    profilePic: '',
                    isOnline: false,
                    createdAt: DateTime.now(),
                    lastSeen: DateTime.now(),
                  );
              return ChatListItem(
                chat: chat,
                otherUser: otherUser,
                onTap: () {
                  GoRouter.of(
                    context,
                  ).push(AppRouter.kChatScreenRoute, extra: otherUser);
                },
              );
            },
          );
        } else {
          return const Center(child: Text('No chats available'));
        }
      },
    );
  }
}
