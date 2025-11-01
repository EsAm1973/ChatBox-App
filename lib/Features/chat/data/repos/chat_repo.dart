import 'dart:io';

import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepo {
  Future<Either<Failure, void>> sendMessage(MessageModel message);
  Future<Either<Failure, void>> sendVoiceMessage({
    required File voiceFile,
    required String senderId,
    required String receiverId,
    required int duration,
    required String messageId,
  });
  Future<Either<Failure, void>> sendAttachment({
    required File file,
    required String senderId,
    required String receiverId,
    required MessageType fileType,
    required String messageId,
  });
  Stream<Either<Failure, List<MessageModel>>> getMessages(String chatRoomId);
  Stream<Either<Failure, List<ChatRoomModel>>> getUserChats(String userId);
  Future<Either<Failure, String>> createChatRoom(String user1, String user2);
  Future<Either<Failure, void>> markMessagesAsSeen(
    String chatId,
    String userId,
  );

  // Download methods
  Future<Either<Failure, String>> downloadImage(
    String url,
    String messageId,
    Function(double)? onProgress,
  );
  Future<Either<Failure, String>> downloadFile(
    String url,
    String fileName,
    String messageId,
    Function(double)? onProgress,
  );
  Future<bool> isFileDownloaded(String messageId);
  Future<String?> getLocalFilePath(String messageId);
}
