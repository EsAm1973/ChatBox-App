import 'package:bloc/bloc.dart';
import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:chatbox/Features/chat/data/repos/chat_repo.dart';
import 'package:chatbox/Features/chat/presentation/manager/chat%20cubit/chat_state.dart';

class ChatCubit extends Cubit<ChatState> {
  final ChatRepo chatRepository;

  ChatCubit({required this.chatRepository}) : super(ChatInitial());

  Future<void> getOrCreateChatRoom(String otherUserId) async {
    emit(ChatLoading());
    final result = await chatRepository.getOrCreateChatRoom(otherUserId);
    result.fold(
      (failure) => emit(ChatError(errorMessage: failure.errorMessage)),
      (chatRoomId) => emit(ChatRoomCreated(chatRoomId: chatRoomId)),
    );
  }

  Future<void> sendMessage({
    required String chatRoomId,
    required String text,
    required String receiverId,
  }) async {
    emit(MessageSending());
    final result = await chatRepository.sendMessage(
      chatRoomId: chatRoomId,
      text: text,
      receiverId: receiverId,
    );

    result.fold(
      (failure) => emit(ChatError(errorMessage: failure.errorMessage)),
      (_) {
        final message = Message(
          id: 'temp_${DateTime.now().millisecondsSinceEpoch}',
          chatRoomId: chatRoomId,
          senderId: '', // سيتم تعبئته من الخدمة
          text: text,
          timestamp: DateTime.now(),
        );
        emit(MessageSent(message: message));
      },
    );
  }

  Stream<List<Message>> listenToMessages(String chatRoomId) {
    return chatRepository
        .getMessagesStream(chatRoomId)
        .map(
          (either) => either.fold(
            (failure) => <Message>[], // or handle error as needed
            (messages) => messages,
          ),
        );
  }

  Stream<List<ChatRoom>> listenToChatRooms() {
    return chatRepository.getChatRoomsStream().map(
      (either) => either.fold(
        (failure) => <ChatRoom>[], // or handle error as needed
        (chatRooms) => chatRooms,
      ),
    );
  }

  Future<void> markMessagesAsRead(String chatRoomId) async {
    final result = await chatRepository.markMessagesAsRead(chatRoomId);
    result.fold(
      (failure) => emit(ChatError(errorMessage: failure.errorMessage)),
      (_) => emit(MessagesMarkedAsRead()),
    );
  }

  void resetState() {
    emit(ChatInitial());
  }
}
