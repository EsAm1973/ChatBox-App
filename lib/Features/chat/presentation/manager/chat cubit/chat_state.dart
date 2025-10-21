import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';

abstract class ChatState {
  final List<MessageModel> messages;
  final List<ChatRoomModel> userChats;

  const ChatState({this.messages = const [], this.userChats = const []});
}

class ChatInitial extends ChatState {
  const ChatInitial();
}

class ChatLoading extends ChatState {
  const ChatLoading();
}

class MessagesLoaded extends ChatState {
  const MessagesLoaded({required super.messages});
}

class UserChatsLoaded extends ChatState {
  const UserChatsLoaded({required super.userChats});
}

class MessageSending extends ChatState {
  const MessageSending({required super.messages});
}

class MessageSent extends ChatState {
  const MessageSent({required super.messages});
}

class ChatError extends ChatState {
  final String error;

  const ChatError({
    required this.error,
    super.messages,
    super.userChats,
  });
}
