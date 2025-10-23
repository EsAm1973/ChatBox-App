import 'dart:async';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:chatbox/Features/chat/data/repos/chat_repo.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _chatRepo;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _chatsSubscription;
  final Map<String, MessageModel> _pendingMessages = {};

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
        (messages) {
          final allMessages = _mergeMessages(messages);
          emit(MessagesLoaded(messages: allMessages));
        },
      );
    });
  }

  List<MessageModel> _mergeMessages(List<MessageModel> firestoreMessages) {
    final mergedMessages = <MessageModel>[];
    final firestoreIds = firestoreMessages.map((m) => m.id).toSet();

    mergedMessages.addAll(firestoreMessages);

    for (final pendingMessage in _pendingMessages.values) {
      if (!firestoreIds.contains(pendingMessage.id)) {
        mergedMessages.add(pendingMessage);
      } else {
        _pendingMessages.remove(pendingMessage.id);
      }
    }

    mergedMessages.sort((a, b) {
      final aTime = a.timestamp ?? DateTime.now();
      final bTime = b.timestamp ?? DateTime.now();
      return aTime.compareTo(bTime);
    });

    return mergedMessages;
  }

  /// Sends a new message to the chat
  void sendMessage(MessageModel message) async {
    final pendingMessage = message.copyWith(
      status: MessageStatus.pending,
      timestamp: DateTime.now(),
    );

    _pendingMessages[message.id] = pendingMessage;

    final updatedMessages = _mergeMessages(
      state.messages.where((m) => m.status != MessageStatus.pending).toList(),
    );
    emit(MessagesLoaded(messages: updatedMessages));

    final result = await _chatRepo.sendMessage(message);

    result.fold((failure) {
      _pendingMessages[message.id] = pendingMessage.copyWith(
        status: MessageStatus.failed,
      );

      final updatedMessages = _mergeMessages(
        state.messages.where((m) => m.id != message.id).toList(),
      );
      emit(MessagesLoaded(messages: updatedMessages));

      emit(ChatError(error: failure.errorMessage, messages: updatedMessages));
    }, (_) {});
  }

  void sendVoiceMessage({
    required File voiceFile,
    required String senderId,
    required String receiverId,
    required int duration,
  }) async {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    final pendingMessage = MessageModel(
      id: messageId,
      senderId: senderId,
      receiverId: receiverId,
      content: 'voice_pending',
      timestamp: DateTime.now(),
      isRead: false,
      type: MessageType.voice,
      voiceDuration: duration,
      status: MessageStatus.pending,
    );

    _pendingMessages[messageId] = pendingMessage;

    final updatedMessages = _mergeMessages(
      state.messages.where((m) => m.status != MessageStatus.pending).toList(),
    );
    emit(MessagesLoaded(messages: updatedMessages));

    final result = await _chatRepo.sendVoiceMessage(
      voiceFile: voiceFile,
      senderId: senderId,
      receiverId: receiverId,
      duration: duration,
      messageId: messageId,
    );

    result.fold(
      (failure) {
        _pendingMessages[messageId] = pendingMessage.copyWith(
          status: MessageStatus.failed,
        );

        final updatedMessages = _mergeMessages(
          state.messages.where((m) => m.id != messageId).toList(),
        );
        emit(MessagesLoaded(messages: updatedMessages));
        emit(ChatError(error: failure.errorMessage, messages: updatedMessages));
      },
      (_) {
        _pendingMessages.remove(messageId);
      },
    );
  }

  void retryMessage(MessageModel message) {
    if (message.status == MessageStatus.failed) {
      _pendingMessages.remove(message.id);

      if (message.type == MessageType.voice) {
        emit(
          ChatError(
            error: 'Cannot retry voice message. Please record again.',
            messages: state.messages,
          ),
        );
      } else {
        sendMessage(message.copyWith(status: MessageStatus.pending));
      }
    }
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
    _pendingMessages.clear();
    return super.close();
  }
}
