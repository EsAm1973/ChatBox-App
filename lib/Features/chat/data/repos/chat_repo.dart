import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:dartz/dartz.dart';

abstract class ChatRepo {
  Future<Either<Failure, String>> getOrCreateChatRoom(String otherUserId);
  Future<Either<Failure, Unit>> sendMessage({
    required String chatRoomId,
    required String text,
    required String receiverId,
  });
  Stream<Either<Failure, List<Message>>> getMessagesStream(String chatRoomId);
  Stream<Either<Failure, List<ChatRoom>>> getChatRoomsStream();
  Future<Either<Failure, Unit>> markMessagesAsRead(String chatRoomId);
}
