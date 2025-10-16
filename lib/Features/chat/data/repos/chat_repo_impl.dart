import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Core/service/firestore_service.dart';
import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:chatbox/Features/chat/data/repos/chat_repo.dart';
import 'package:dartz/dartz.dart';

class ChatRepoImpl implements ChatRepo {
  final FirestoreService firestoreService;

  ChatRepoImpl({required this.firestoreService});
  @override
  Stream<Either<Failure, List<ChatRoom>>> getChatRoomsStream() {
    return firestoreService
        .getChatRoomsStream()
        .map(
          (chatRooms) =>
              Right<Failure, List<ChatRoom>>(chatRooms as List<ChatRoom>),
        )
        .handleError((error) {
          if (error is Failure) {
            return Left<Failure, List<ChatRoom>>(error);
          }
          return Left<Failure, List<ChatRoom>>(
            FirebaseFailure(errorMessage: 'Failed to get chat rooms stream.'),
          );
        });
  }

  @override
  Stream<Either<Failure, List<Message>>> getMessagesStream(String chatRoomId) {
    return firestoreService
        .getMessagesStream(chatRoomId)
        .map(
          (messages) =>
              Right<Failure, List<Message>>(messages as List<Message>),
        )
        .handleError((error) {
          if (error is Failure) {
            return Left<Failure, List<Message>>(error);
          }
          return Left<Failure, List<Message>>(
            FirebaseFailure(errorMessage: 'Failed to get messages stream.'),
          );
        });
  }

  @override
  Future<Either<Failure, String>> getOrCreateChatRoom(
    String otherUserId,
  ) async {
    try {
      final chatRoomId = await firestoreService.getOrCreateChatRoom(
        otherUserId,
      );
      return Right(chatRoomId);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to get or create chat room.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> markMessagesAsRead(String chatRoomId) async {
    try {
      await firestoreService.markMessagesAsRead(chatRoomId);
      return const Right(unit);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to mark messages as read.'),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> sendMessage({
    required String chatRoomId,
    required String text,
    required String receiverId,
  }) async {
    try {
      await firestoreService.sendMessage(
        chatRoomId: chatRoomId,
        text: text,
        receiverId: receiverId,
      );
      return const Right(unit);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to send message.'));
    }
  }
}
