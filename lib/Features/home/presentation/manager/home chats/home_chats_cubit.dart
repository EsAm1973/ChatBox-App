import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chatbox/Features/home/data/repos/home_repo.dart';
import 'package:chatbox/Features/home/presentation/manager/home%20chats/home_chats_state.dart';

class HomeChatsCubit extends Cubit<HomeChatListState> {
  final HomeRepo homeRepo;
  StreamSubscription? _chatRoomsSubscription;
  HomeChatsCubit(this.homeRepo) : super(HomeChatListInitial());

  // تحميل قائمة المحادثات
  void loadChatRooms() {
    emit(ChatListLoading());

    _chatRoomsSubscription?.cancel();

    // محاولة الاستخدام مع التعامل مع الأخطاء
    _chatRoomsSubscription = homeRepo.getChatRoomsStream().listen(
      (either) {
        either.fold((failure) {
          // إذا كان الخطأ متعلقاً بالفهرس، استخدم البديل
          if (failure.errorMessage.contains('index') ||
              failure.errorMessage.contains('FAILED_PRECONDITION')) {
            _useFallbackChatRooms();
          } else {
            emit(HomeChatListError(errorMessage: failure.errorMessage));
          }
        }, (chatRooms) => emit(HomeChatListLoaded(chatRooms: chatRooms)));
      },
      onError: (error) {
        emit(HomeChatListError(errorMessage: error.toString()));
      },
    );
  }

  void _useFallbackChatRooms() {
    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = homeRepo.getChatRoomsStreamFallback().listen(
      (either) {
        either.fold(
          (failure) =>
              emit(HomeChatListError(errorMessage: failure.errorMessage)),
          (chatRooms) => emit(HomeChatListLoaded(chatRooms: chatRooms)),
        );
      },
      onError: (error) {
        emit(HomeChatListError(errorMessage: error.toString()));
      },
    );
  }

  // تحميل المحادثات مع فلتر
  void loadChatRoomsWithFilters({DateTime? since, int limit = 50}) {
    emit(ChatListLoading());

    _chatRoomsSubscription?.cancel();
    _chatRoomsSubscription = homeRepo
        .getChatRoomsWithFilters(since: since, limit: limit)
        .listen(
          (either) {
            either.fold(
              (failure) =>
                  emit(HomeChatListError(errorMessage: failure.errorMessage)),
              (chatRooms) => emit(HomeChatListLoaded(chatRooms: chatRooms)),
            );
          },
          onError: (error) {
            emit(HomeChatListError(errorMessage: error.toString()));
          },
        );
  }

  // تحديث آخر رؤية للمحادثة
  Future<void> updateChatRoomLastSeen(String chatRoomId) async {
    try {
      final result = await homeRepo.updateChatRoomLastSeen(chatRoomId);
      result.fold(
        (failure) =>
            emit(HomeChatListError(errorMessage: failure.errorMessage)),
        (_) {},
      );
    } catch (e) {
      emit(HomeChatListError(errorMessage: 'Failed to update last seen: $e'));
    }
  }

  // حذف محادثة
  Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      final result = await homeRepo.deleteChatRoom(chatRoomId);
      result.fold(
        (failure) =>
            emit(HomeChatListError(errorMessage: failure.errorMessage)),
        (_) => emit(HomeChatListDeleted(chatRoomId: chatRoomId)),
      );
    } catch (e) {
      emit(HomeChatListError(errorMessage: 'Failed to delete chat room: $e'));
    }
  }

  // جلب عدد الرسائل غير المقروءة
  Future<int> getUnreadMessagesCount(String chatRoomId) async {
    try {
      final result = await homeRepo.getUnreadMessagesCount(chatRoomId);
      return result.fold((failure) {
        emit(HomeChatListError(errorMessage: failure.errorMessage));
        return 0;
      }, (count) => count);
    } catch (e) {
      emit(HomeChatListError(errorMessage: 'Failed to get unread count: $e'));
      return 0;
    }
  }

  // تحديد كل الرسائل كمقروءة
  Future<void> markAllMessagesAsRead(String chatRoomId) async {
    try {
      final result = await homeRepo.markAllMessagesAsRead(chatRoomId);
      result.fold(
        (failure) =>
            emit(HomeChatListError(errorMessage: failure.errorMessage)),
        (_) => emit(MessagesMarkedAsRead(chatRoomId: chatRoomId)),
      );
    } catch (e) {
      emit(
        HomeChatListError(errorMessage: 'Failed to mark messages as read: $e'),
      );
    }
  }

  // Cleanup
  @override
  Future<void> close() {
    _chatRoomsSubscription?.cancel();
    return super.close();
  }
}
