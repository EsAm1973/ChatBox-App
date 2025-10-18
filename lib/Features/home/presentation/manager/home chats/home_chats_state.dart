import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:equatable/equatable.dart';

abstract class HomeChatListState extends Equatable {
  const HomeChatListState();

  @override
  List<Object> get props => [];
}

class HomeChatListInitial extends HomeChatListState {}

class ChatListLoading extends HomeChatListState {}

class HomeChatListLoaded extends HomeChatListState {
  final List<ChatRoom> chatRooms;

  const HomeChatListLoaded({required this.chatRooms});

  @override
  List<Object> get props => [chatRooms];
}

class HomeChatListError extends HomeChatListState {
  final String errorMessage;

  const HomeChatListError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}

class HomeChatListDeleted extends HomeChatListState {
  final String chatRoomId;

  const HomeChatListDeleted({required this.chatRoomId});

  @override
  List<Object> get props => [chatRoomId];
}

class MessagesMarkedAsRead extends HomeChatListState {
  final String chatRoomId;

  const MessagesMarkedAsRead({required this.chatRoomId});

  @override
  List<Object> get props => [chatRoomId];
}
