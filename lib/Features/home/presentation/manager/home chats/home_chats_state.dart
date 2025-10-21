import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/chat/data/models/chat_room.dart';

abstract class HomeState {
  final List<ChatRoomModel> chats;
  final Map<String, UserModel> usersCache;

  const HomeState({this.chats = const [], this.usersCache = const {}});
}

class HomeInitial extends HomeState {
  const HomeInitial();
}

class HomeLoading extends HomeState {
  const HomeLoading();
}

class HomeLoaded extends HomeState {
  const HomeLoaded({required super.chats, required super.usersCache});
}

class HomeError extends HomeState {
  final String error;

  const HomeError({required this.error, super.chats, super.usersCache});
}
