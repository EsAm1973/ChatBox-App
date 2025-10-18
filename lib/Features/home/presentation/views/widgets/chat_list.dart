import 'package:chatbox/Core/utils/app_router.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/home/presentation/manager/home%20chats/home_chats_cubit.dart';
import 'package:chatbox/Features/home/presentation/manager/home%20chats/home_chats_state.dart';
import 'package:chatbox/Features/home/presentation/views/widgets/chat_list_item.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
    // نبدأ تحميل المحادثات عند تهيئة الـ State
    context.read<HomeChatsCubit>().loadChatRooms();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeChatsCubit, HomeChatListState>(
      builder: (context, state) {
        if (state is ChatListLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is HomeChatListError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 16),
                Text('Failed to load chats: ${state.errorMessage}'),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () {
                    context.read<HomeChatsCubit>().loadChatRooms();
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is HomeChatListLoaded) {
          final chatRooms = state.chatRooms;
          if (chatRooms.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.chat_outlined, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('No conversations yet'),
                  Text(
                    'Start a new chat!',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chatRooms.length,
            itemBuilder: (context, index) {
              final chatRoom = chatRooms[index];
              final currentUserId = FirebaseAuth.instance.currentUser!.uid;

              // الحصول على المستخدم الآخر
              final otherParticipantId = chatRoom.participants.firstWhere(
                (id) => id != currentUserId,
              );
              final otherUserData =
                  chatRoom.participantData?[otherParticipantId] ?? {};

              final lastMessage = chatRoom.lastMessage;
              final lastMessageText = lastMessage['text'] ?? '';
              final lastMessageTime =
                  lastMessage['timestamp'] != null
                      ? _formatLastMessageTime(lastMessage['timestamp'])
                      : '';

              return ChatListItem(
                chatRoom: chatRoom,
                otherUserName: otherUserData['name'] ?? 'Unknown User',
                otherUserProfilePic: otherUserData['profilePic'] ?? '',
                lastMessage: lastMessageText,
                lastMessageTime: lastMessageTime,
                isOnline: otherUserData['isOnline'] ?? false,
                unreadCount: 0,
                onTap: () {
                  // الانتقال لشاشة الدردشة
                  final otherUser = UserModel(
                    uid: otherParticipantId,
                    name: otherUserData['name'] ?? 'Unknown User',
                    email: otherUserData['email'] ?? '',
                    profilePic: otherUserData['profilePic'] ?? '',
                    isOnline: otherUserData['isOnline'] ?? false,
                    createdAt: DateTime.now(),
                    lastSeen: DateTime.now(),
                  );

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

  String _formatLastMessageTime(Timestamp timestamp) {
    final messageTime = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(messageTime);

    if (difference.inMinutes < 1) {
      return 'Now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d';
    } else {
      return '${messageTime.day}/${messageTime.month}';
    }
  }
}
