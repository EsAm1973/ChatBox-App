import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Core/service/firestore_service.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:chatbox/Features/home/data/repos/home_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class HomeRepoImpl implements HomeRepo {
  final FirestoreService firestore;

  HomeRepoImpl({required this.firestore});

  @override
  Future<Either<Failure, List<UserModel>>> searchUsers(
    String searchQuery,
  ) async {
    try {
      final results = await firestore.searchUsersByEmail(searchQuery);
      return Right(results);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure.fromFirestoreException(e));
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to search users: $e'));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteChatRoom(String chatRoomId) async {
    try {
      await firestore.deleteChatRoom(chatRoomId);
      return const Right(unit);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to delete chat room: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, ChatRoom?>> getChatRoom(String chatRoomId) async {
    try {
      final chatRoom = await firestore.getChatRoom(chatRoomId);
      return Right(chatRoom);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to get chat room: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<ChatRoom>>> getChatRoomsStream() {
    return firestore
        .getChatRoomsStream()
        .map((chatRooms) => Right<Failure, List<ChatRoom>>(chatRooms))
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
  Stream<Either<Failure, List<ChatRoom>>> getChatRoomsStreamFallback() {
    return firestore
        .getChatRoomsStreamFallback()
        .map((chatRooms) => Right<Failure, List<ChatRoom>>(chatRooms))
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
  Stream<Either<Failure, List<ChatRoom>>> getChatRoomsWithFilters({
    DateTime? since,
    int limit = 50,
  }) {
    return firestore
        .getChatRoomsWithFilters(since: since, limit: limit)
        .map((chatRooms) => Right<Failure, List<ChatRoom>>(chatRooms))
        .handleError((error) {
          if (error is Failure) {
            return Left<Failure, List<ChatRoom>>(error);
          }
          return Left<Failure, List<ChatRoom>>(
            FirebaseFailure(
              errorMessage: 'Failed to get chat rooms with filters.',
            ),
          );
        });
  }

  @override
  Future<Either<Failure, int>> getUnreadMessagesCount(String chatRoomId) async {
    try {
      final count = await firestore.getUnreadMessagesCount(chatRoomId);
      return Right(count);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        FirebaseFailure(
          errorMessage: 'Failed to get unread messages count: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> markAllMessagesAsRead(String chatRoomId) async {
    try {
      await firestore.markAllMessagesAsRead(chatRoomId);
      return const Right(unit);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        FirebaseFailure(
          errorMessage: 'Failed to mark all messages as read: $e',
        ),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> updateChatRoomLastSeen(
    String chatRoomId,
  ) async {
    try {
      await firestore.updateChatRoomLastSeen(chatRoomId);
      return const Right(unit);
    } on Failure catch (failure) {
      return Left(failure);
    } catch (e) {
      return Left(
        FirebaseFailure(
          errorMessage: 'Failed to update chat room last seen: $e',
        ),
      );
    }
  }
}
