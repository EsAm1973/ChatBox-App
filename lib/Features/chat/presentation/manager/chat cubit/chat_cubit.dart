import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:chatbox/Features/chat/data/repos/chat_repo.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _chatRepo;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _chatsSubscription;

  ChatCubit(this._chatRepo) : super(const ChatInitial());

  /// Initializes chat room and starts listening to messages
  void initializeChat(String user1, String user2) async {
    emit(const ChatLoading());

    final result = await _chatRepo.createChatRoom(user1, user2);

    result.fold(
      (failure) => emit(ChatError(error: failure.errorMessage)),
      (chatId) => _listenToMessages(chatId),
    );
  }

  /// Starts listening to messages for a specific chat
  void _listenToMessages(String chatId) {
    _messagesSubscription?.cancel();

    _messagesSubscription = _chatRepo.getMessages(chatId).listen((result) {
      result.fold(
        (failure) => emit(
          ChatError(error: failure.errorMessage, messages: state.messages),
        ),
        (messages) => emit(MessagesLoaded(messages: messages)),
      );
    });
  }

  /// Sends a new message to the chat
  void sendMessage(MessageModel message) async {
    emit(MessageSending(messages: state.messages));

    final result = await _chatRepo.sendMessage(message);

    result.fold(
      (failure) => emit(
        ChatError(error: failure.errorMessage, messages: state.messages),
      ),
      (_) => emit(MessageSent(messages: state.messages)),
    );
  }

  /// Loads user's chat conversations
  void loadUserChats(String userId) {
    _chatsSubscription?.cancel();

    _chatsSubscription = _chatRepo.getUserChats(userId).listen((result) {
      result.fold(
        (failure) => emit(
          ChatError(error: failure.errorMessage, userChats: state.userChats),
        ),
        (chats) => emit(UserChatsLoaded(userChats: chats)),
      );
    });
  }

  /// Marks messages as seen for the current user
  void markMessagesAsSeen(String chatId, String userId) async {
    await _chatRepo.markMessagesAsSeen(chatId, userId);
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _chatsSubscription?.cancel();
    return super.close();
  }
}
