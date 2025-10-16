import 'package:bloc/bloc.dart';
import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:chatbox/Features/chat/data/repos/chat_repo.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo chatRepository;
  String? _currentChatRoomId;

  ChatCubit({required this.chatRepository}) : super(ChatInitial());

  Future<void> getOrCreateChatRoom(String otherUserId) async {
    emit(ChatLoading());
    try {
      final result = await chatRepository.getOrCreateChatRoom(otherUserId);
      result.fold(
        (failure) => emit(ChatError(errorMessage: failure.errorMessage)),
        (chatRoomId) {
          _currentChatRoomId = chatRoomId;
          emit(ChatRoomCreated(chatRoomId: chatRoomId));
        },
      );
    } catch (e) {
      emit(ChatError(errorMessage: 'Failed to create chat room: $e'));
    }
  }

  Future<void> sendMessage({
    required String text,
    required String receiverId,
  }) async {
    if (_currentChatRoomId == null) {
      emit(const ChatError(errorMessage: 'No active chat room'));
      return;
    }

    try {
      final result = await chatRepository.sendMessage(
        chatRoomId: _currentChatRoomId!,
        text: text,
        receiverId: receiverId,
      );

      result.fold((failure) {
        // نرسل خطأ ولكن لا نغير الحالة الرئيسية
        emit(ChatError(errorMessage: failure.errorMessage));
        // نعود للحالة الطبيعية بعد الخطأ
        if (_currentChatRoomId != null) {
          emit(ChatRoomCreated(chatRoomId: _currentChatRoomId!));
        }
      }, (_) {});
    } catch (e) {
      emit(ChatError(errorMessage: 'Failed to send message: $e'));
      // نعود للحالة الطبيعية بعد الخطأ
      if (_currentChatRoomId != null) {
        emit(ChatRoomCreated(chatRoomId: _currentChatRoomId!));
      }
    }
  }

  Stream<List<Message>> listenToMessages(String chatRoomId) {
    return chatRepository.getMessagesStream(chatRoomId).map((either) {
      return either.fold((failure) {
        emit(ChatError(errorMessage: failure.errorMessage));
        return <Message>[];
      }, (messages) => messages);
    });
  }

  Stream<List<ChatRoom>> listenToChatRooms() {
    return chatRepository.getChatRoomsStream().map((either) {
      return either.fold((failure) {
        emit(ChatError(errorMessage: failure.errorMessage));
        return <ChatRoom>[];
      }, (chatRooms) => chatRooms);
    });
  }

  Future<void> markMessagesAsRead(String chatRoomId) async {
    try {
      final result = await chatRepository.markMessagesAsRead(chatRoomId);
      result.fold(
        (failure) => emit(ChatError(errorMessage: failure.errorMessage)),
        (_) {},
      );
    } catch (e) {
      emit(ChatError(errorMessage: 'Failed to mark messages as read: $e'));
    }
  }
}
