import 'dart:developer';
import 'dart:io';

import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Core/service/firestore_chat_service.dart';
import 'package:chatbox/Core/service/storage_service.dart';
import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:chatbox/Features/chat/data/repos/chat_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class ChatRepoImpl implements ChatRepo {
  final FirestoreChatService firestoreChatService;
  final StorageService storageService;

  ChatRepoImpl({
    required this.firestoreChatService,
    required this.storageService,
  });

  @override
  Future<Either<Failure, String>> createChatRoom(
    String user1,
    String user2,
  ) async {
    try {
      final chatId = await firestoreChatService.createChatRoomIfNotExists(
        user1,
        user2,
      );
      return Right(chatId);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure.fromFirestoreException(e));
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to create chat room: $e'),
      );
    }
  }

  @override
  Stream<Either<Failure, List<MessageModel>>> getMessages(String chatRoomId) {
    return firestoreChatService
        .getMessagesStream(chatRoomId)
        .map((messages) => Right<Failure, List<MessageModel>>(messages))
        .handleError((error) {
          return Left<Failure, List<MessageModel>>(
            FirebaseFailure(errorMessage: 'Failed to get messages: $error'),
          );
        });
  }

  @override
  Stream<Either<Failure, List<ChatRoomModel>>> getUserChats(String userId) {
    return firestoreChatService
        .getUserChatsStream(userId)
        .map((chats) => Right<Failure, List<ChatRoomModel>>(chats))
        .handleError((error) {
          log('Error getting user chats: $error');
          return Left<Failure, List<ChatRoomModel>>(
            FirebaseFailure(errorMessage: 'Failed to get chat rooms: $error'),
          );
        });
  }

  @override
  Future<Either<Failure, void>> markMessagesAsSeen(
    String chatId,
    String userId,
  ) async {
    try {
      await firestoreChatService.markMessagesAsSeen(chatId, userId);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure.fromFirestoreException(e));
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to mark messages as seen: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendMessage(MessageModel message) async {
    try {
      await firestoreChatService.sendMessage(message);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure.fromFirestoreException(e));
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to send message: $e'));
    }
  }

  @override
  @override
  Future<Either<Failure, void>> sendVoiceMessage({
    required File voiceFile,
    required String senderId,
    required String receiverId,
    required int duration,
    required String messageId,
  }) async {
    try {
      final voiceUrl = await storageService.uploadVoiceRecord(
        voiceFile,
        senderId,
      );

      final message = MessageModel(
        id: messageId,
        senderId: senderId,
        receiverId: receiverId,
        content: voiceUrl,
        timestamp: DateTime.now(),
        isRead: false,
        type: MessageType.voice,
        voiceDuration: duration,
      );

      await firestoreChatService.sendMessage(message);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure.fromFirestoreException(e));
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to send voice message: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> sendAttachment({
    required File file,
    required String senderId,
    required String receiverId,
    required MessageType fileType,
    required String messageId,
  }) async {
    try {
      if (fileType != MessageType.image && fileType != MessageType.file) {
        return Left(
          FirebaseFailure(errorMessage: 'Invalid file type for attachment'),
        );
      }

      final fileUrl = await storageService.uploadChatAttachment(
        file,
        senderId,
        fileType,
      );

      final message = MessageModel(
        id: messageId,
        senderId: senderId,
        receiverId: receiverId,
        content: fileUrl,
        timestamp: DateTime.now(),
        isRead: false,
        type: fileType,
      );

      await firestoreChatService.sendMessage(message);
      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure.fromFirestoreException(e));
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to send attachment: $e'),
      );
    }
  }
}
