import 'dart:async';
import 'dart:io';

import 'package:chatbox/Core/repos/user%20repo/user_repo.dart';
import 'package:chatbox/Core/service/notification_service.dart';
import 'package:bloc/bloc.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:chatbox/Features/chat/data/repos/chat_repo.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_state.dart';
import 'package:open_file/open_file.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo _chatRepo;
  final UserRepo _userRepo;
  StreamSubscription? _messagesSubscription;
  StreamSubscription? _chatsSubscription;
  final Map<String, MessageModel> _pendingMessages = {};
  final Map<String, MessageModel> _downloadingMessages = {};

  ChatCubit(this._chatRepo, this._userRepo) : super(const ChatInitial());

  void initializeChat(String user1, String user2) async {
    emit(const ChatLoading());

    final result = await _chatRepo.createChatRoom(user1, user2);

    result.fold(
      (failure) => emit(ChatError(error: failure.errorMessage)),
      (chatId) => _listenToMessages(chatId),
    );
  }

  void _listenToMessages(String chatId) {
    _messagesSubscription?.cancel();

    _messagesSubscription = _chatRepo.getMessages(chatId).listen((result) {
      result.fold(
        (failure) => emit(
          ChatError(error: failure.errorMessage, messages: state.messages),
        ),
        (messages) async {
          // Check download status for each message
          final updatedMessages = await _checkDownloadStatus(messages);
          final allMessages = _mergeMessages(updatedMessages);
          emit(MessagesLoaded(messages: allMessages));
        },
      );
    });
  }

  Future<List<MessageModel>> _checkDownloadStatus(
    List<MessageModel> messages,
  ) async {
    final updatedMessages = <MessageModel>[];

    for (final message in messages) {
      if (message.type == MessageType.image ||
          message.type == MessageType.file) {
        final isDownloaded = await _chatRepo.isFileDownloaded(message.id);
        final localPath = await _chatRepo.getLocalFilePath(message.id);

        updatedMessages.add(
          message.copyWith(
            downloadStatus:
                isDownloaded
                    ? DownloadStatus.downloaded
                    : DownloadStatus.notDownloaded,
            localFilePath: localPath,
            downloadProgress: isDownloaded ? 1.0 : 0.0,
          ),
        );
      } else {
        updatedMessages.add(message);
      }
    }

    return updatedMessages;
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

    for (final downloadingMessage in _downloadingMessages.values) {
      final index = mergedMessages.indexWhere(
        (m) => m.id == downloadingMessage.id,
      );
      if (index != -1) {
        mergedMessages[index] = downloadingMessage;
      } else {
        mergedMessages.add(downloadingMessage);
      }
    }

    mergedMessages.sort((a, b) {
      final aTime = a.timestamp ?? DateTime.now();
      final bTime = b.timestamp ?? DateTime.now();
      return aTime.compareTo(bTime);
    });

    return mergedMessages;
  }

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
    }, (_) async {
      // Fetch sender and receiver UserModels
      final senderResult = await _userRepo.getUserData(message.senderId);
      final receiverResult = await _userRepo.getUserData(message.receiverId);

      await senderResult.fold(
        (failure) {
          print('Error fetching sender data: ${failure.errorMessage}');
        },
        (senderUser) async {
          await receiverResult.fold(
            (failure) {
              print('Error fetching receiver data: ${failure.errorMessage}');
            },
            (receiverUser) async {
              print('Sender: ${senderUser.name}');
              print('Receiver: ${receiverUser.name}');
              print('Receiver FCM Token: ${receiverUser.fcmToken}');

              if (receiverUser.fcmToken != null && receiverUser.fcmToken!.isNotEmpty) {
                // Generate chat room ID using the same logic as FirestoreChatService
                final sortedIds = [message.senderId, message.receiverId]..sort();
                final chatId = 'chat_${sortedIds[0]}_${sortedIds[1]}';

                await sendNotification(
                  token: receiverUser.fcmToken!,
                  title: 'New message from ${senderUser.name}',
                  body: message.content,
                  data: {
                    'chatId': chatId,
                    'senderId': message.senderId,
                    'messageId': message.id,
                    'route': '/chat_screen', // Placeholder, needs actual route for chat screen
                    // Potentially add more data like sender's profile picture etc.
                  },
                );
              } else {
                print('Receiver does not have an FCM token.');
              }
            },
          );
        },
      );
    });
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
      (_) async {
        _pendingMessages.remove(messageId);
        final senderResult = await _userRepo.getUserData(senderId);
        final receiverResult = await _userRepo.getUserData(receiverId);
        await senderResult.fold((l) => null, (sender) async {
          await receiverResult.fold((l) => null, (receiver) async {
            if (receiver.fcmToken != null && receiver.fcmToken!.isNotEmpty) {
              final sortedIds = [senderId, receiverId]..sort();
              final chatId = 'chat_${sortedIds[0]}_${sortedIds[1]}';
              await sendNotification(
                token: receiver.fcmToken!,
                title: 'New message from ${sender.name}',
                body: "Sent a voice message",
                data: {
                  'chatId': chatId,
                  'senderId': senderId,
                  'messageId': messageId,
                  'route': '/chat_screen',
                },
              );
            }
          });
        });
      },
    );
  }

  void sendImageAttachment({
    required File imageFile,
    required String senderId,
    required String receiverId,
  }) {
    _sendAttachment(
      file: imageFile,
      senderId: senderId,
      receiverId: receiverId,
      fileType: MessageType.image,
    );
  }

  void sendFileAttachment({
    required File file,
    required String senderId,
    required String receiverId,
  }) {
    _sendAttachment(
      file: file,
      senderId: senderId,
      receiverId: receiverId,
      fileType: MessageType.file,
    );
  }

  void _sendAttachment({
    required File file,
    required String senderId,
    required String receiverId,
    required MessageType fileType,
  }) async {
    final messageId = DateTime.now().millisecondsSinceEpoch.toString();

    final pendingMessage = MessageModel(
      id: messageId,
      senderId: senderId,
      receiverId: receiverId,
      content: '${fileType.name}_pending',
      timestamp: DateTime.now(),
      isRead: false,
      type: fileType,
      status: MessageStatus.pending,
    );

    _pendingMessages[messageId] = pendingMessage;

    final updatedMessages = _mergeMessages(
      state.messages.where((m) => m.status != MessageStatus.pending).toList(),
    );
    emit(MessagesLoaded(messages: updatedMessages));

    final result = await _chatRepo.sendAttachment(
      file: file,
      senderId: senderId,
      receiverId: receiverId,
      fileType: fileType,
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
      (_) async {
        _pendingMessages.remove(messageId);
        final senderResult = await _userRepo.getUserData(senderId);
        final receiverResult = await _userRepo.getUserData(receiverId);
        await senderResult.fold((l) => null, (sender) async {
          await receiverResult.fold((l) => null, (receiver) async {
            if (receiver.fcmToken != null && receiver.fcmToken!.isNotEmpty) {
              final sortedIds = [senderId, receiverId]..sort();
              final chatId = 'chat_${sortedIds[0]}_${sortedIds[1]}';
              final String notificationBody;
              if (fileType == MessageType.image) {
                notificationBody = "Sent an image";
              } else {
                notificationBody = "Sent a file";
              }
              await sendNotification(
                token: receiver.fcmToken!,
                title: 'New message from ${sender.name}',
                body: notificationBody,
                data: {
                  'chatId': chatId,
                  'senderId': senderId,
                  'messageId': messageId,
                  'route': '/chat_screen',
                },
              );
            }
          });
        });
      },
    );
  }

  void downloadImage(MessageModel message) async {
    if (message.downloadStatus == DownloadStatus.downloading ||
        message.downloadStatus == DownloadStatus.downloaded) {
      return;
    }

    // Start download - set initial progress
    final downloadingMessage = message.copyWith(
      downloadStatus: DownloadStatus.downloading,
      downloadProgress: 0.0,
    );

    _downloadingMessages[message.id] = downloadingMessage;
    _updateMessagesInState();

    // Download with progress callback
    final result = await _chatRepo.downloadImage(message.content, message.id, (
      progress,
    ) {
      // Update progress in real-time
      final updatingMessage = message.copyWith(
        downloadStatus: DownloadStatus.downloading,
        downloadProgress: progress,
      );
      _downloadingMessages[message.id] = updatingMessage;
      _updateMessagesInState();
    });

    result.fold(
      (failure) {
        final failedMessage = message.copyWith(
          downloadStatus: DownloadStatus.failed,
          downloadProgress: 0.0, // Reset progress on failure
        );
        _downloadingMessages[message.id] = failedMessage;
        _updateMessagesInState();
        emit(ChatError(error: failure.errorMessage, messages: state.messages));
      },
      (localPath) {
        // Download complete - update message with downloaded path
        final downloadedMessage = message.copyWith(
          downloadStatus: DownloadStatus.downloaded,
          downloadProgress: 1.0, // Set to 100%
          localFilePath: localPath, // Set the local file path
        );

        // Update in downloading messages first
        _downloadingMessages[message.id] = downloadedMessage;
        _updateMessagesInState();

        // Then remove from downloading map after a short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          _downloadingMessages.remove(message.id);
          _updateMessagesInState();
        });
      },
    );
  }

  void downloadAndOpenFile(MessageModel message, String fileName) async {
    if (message.downloadStatus == DownloadStatus.downloaded &&
        message.localFilePath != null) {
      await OpenFile.open(message.localFilePath!);
      return;
    }

    if (message.downloadStatus == DownloadStatus.downloading) {
      return;
    }

    // Start download - set initial progress
    final downloadingMessage = message.copyWith(
      downloadStatus: DownloadStatus.downloading,
      downloadProgress: 0.0,
    );

    _downloadingMessages[message.id] = downloadingMessage;
    _updateMessagesInState();

    // Download with progress callback
    final result = await _chatRepo.downloadFile(
      message.content,
      fileName,
      message.id,
      (progress) {
        // Update progress in real-time
        final updatingMessage = message.copyWith(
          downloadStatus: DownloadStatus.downloading,
          downloadProgress: progress,
        );
        _downloadingMessages[message.id] = updatingMessage;
        _updateMessagesInState();
      },
    );

    result.fold(
      (failure) {
        final failedMessage = message.copyWith(
          downloadStatus: DownloadStatus.failed,
          downloadProgress: 0.0, // Reset progress on failure
        );
        _downloadingMessages[message.id] = failedMessage;
        _updateMessagesInState();
        emit(ChatError(error: failure.errorMessage, messages: state.messages));
      },
      (localPath) async {
        // Download complete - update message with downloaded path
        final downloadedMessage = message.copyWith(
          downloadStatus: DownloadStatus.downloaded,
          downloadProgress: 1.0, // Set to 100%
          localFilePath: localPath, // Set the local file path
        );

        // Update in downloading messages first
        _downloadingMessages[message.id] = downloadedMessage;
        _updateMessagesInState();

        // Then remove from downloading map after a short delay
        Future.delayed(const Duration(milliseconds: 300), () {
          _downloadingMessages.remove(message.id);
          _updateMessagesInState();
        });

        // Open file
        await OpenFile.open(localPath);
      },
    );
  }

  void _updateMessagesInState() {
    final updatedMessages = _mergeMessages(state.messages);
    emit(MessagesLoaded(messages: updatedMessages));
  }

  void retryMessage(MessageModel message) {
    if (message.status == MessageStatus.failed) {
      _pendingMessages.remove(message.id);

      if (message.type == MessageType.voice ||
          message.type == MessageType.image ||
          message.type == MessageType.file) {
        emit(
          ChatError(
            error:
                'Cannot retry ${message.type.name} message. Please send again.',
            messages: state.messages,
          ),
        );
      } else {
        sendMessage(message.copyWith(status: MessageStatus.pending));
      }
    }
  }

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

  void markMessagesAsSeen(String chatId, String userId) async {
    await _chatRepo.markMessagesAsSeen(chatId, userId);
  }

  @override
  Future<void> close() {
    _messagesSubscription?.cancel();
    _chatsSubscription?.cancel();
    _pendingMessages.clear();
    _downloadingMessages.clear();
    return super.close();
  }
}
