import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:dartz/dartz.dart';

abstract class HomeRepo {
  Future<Either<Failure, List<UserModel>>> searchUsers(String query);
  Stream<Either<Failure, List<ChatRoom>>> getChatRoomsStream();
  Stream<Either<Failure, List<ChatRoom>>> getChatRoomsStreamFallback();
  Stream<Either<Failure, List<ChatRoom>>> getChatRoomsWithFilters({
    DateTime? since,
    int limit = 50,
  });
  Future<Either<Failure, ChatRoom?>> getChatRoom(String chatRoomId);
  Future<Either<Failure, Unit>> updateChatRoomLastSeen(String chatRoomId);
  Future<Either<Failure, Unit>> deleteChatRoom(String chatRoomId);
  Future<Either<Failure, int>> getUnreadMessagesCount(String chatRoomId);
  Future<Either<Failure, Unit>> markAllMessagesAsRead(String chatRoomId);
}
