import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:equatable/equatable.dart';

abstract class ChatState extends Equatable {
  const ChatState();

  @override
  List<Object> get props => [];
}

class ChatInitial extends ChatState {}

class ChatLoading extends ChatState {}

class ChatRoomCreated extends ChatState {
  final String chatRoomId;

  const ChatRoomCreated({required this.chatRoomId});

  @override
  List<Object> get props => [chatRoomId];
}

class MessageSending extends ChatState {}

class MessageSent extends ChatState {
  final Message message;

  const MessageSent({required this.message});

  @override
  List<Object> get props => [message];
}

class MessagesLoaded extends ChatState {
  final List<Message> messages;

  const MessagesLoaded({required this.messages});

  @override
  List<Object> get props => [messages];
}

class ChatRoomsLoaded extends ChatState {
  final List<ChatRoom> chatRooms;

  const ChatRoomsLoaded({required this.chatRooms});

  @override
  List<Object> get props => [chatRooms];
}

class MessagesMarkedAsRead extends ChatState {}

class ChatError extends ChatState {
  final String errorMessage;

  const ChatError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
