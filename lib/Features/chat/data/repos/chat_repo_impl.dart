import 'dart:developer';

import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Core/service/firestore_chat_service.dart';
import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:chatbox/Features/chat/data/repos/chat_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class ChatRepoImpl implements ChatRepo {
  final FirestoreChatService firestoreChatService;

  ChatRepoImpl({required this.firestoreChatService});

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
}
