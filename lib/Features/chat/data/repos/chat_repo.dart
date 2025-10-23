import 'dart:io';

import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepo {
  /// Sends a message and returns success or failure
  Future<Either<Failure, void>> sendMessage(MessageModel message);

  /// Sends a voice message and returns success or failure
  Future<Either<Failure, void>> sendVoiceMessage({
    required File voiceFile,
    required String senderId,
    required String receiverId,
    required int duration,
  });

  /// Gets real-time stream of messages for a chat room
  Stream<Either<Failure, List<MessageModel>>> getMessages(String chatRoomId);

  /// Gets real-time stream of user's chat conversations
  Stream<Either<Failure, List<ChatRoomModel>>> getUserChats(String userId);

  /// Creates chat room if not exists and returns chat ID
  Future<Either<Failure, String>> createChatRoom(String user1, String user2);

  /// Marks messages as seen for the current user in a chat
  Future<Either<Failure, void>> markMessagesAsSeen(
    String chatId,
    String userId,
  );
}
