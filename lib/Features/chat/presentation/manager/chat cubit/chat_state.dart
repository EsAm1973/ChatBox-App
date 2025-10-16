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

class ChatError extends ChatState {
  final String errorMessage;

  const ChatError({required this.errorMessage});

  @override
  List<Object> get props => [errorMessage];
}
