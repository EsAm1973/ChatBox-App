import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chatbox/Core/repos/user%20repo/user_repo.dart';
import 'package:chatbox/Features/chat/data/repos/chat_repo.dart';
import 'package:chatbox/Features/home/presentation/manager/home%20chats/home_chats_state.dart';

class HomeCubit extends Cubit<HomeState> {
  final ChatRepo chatRepo;
  final UserRepo userRepo;
  StreamSubscription? _chatsSubscription;
  HomeCubit(this.chatRepo, this.userRepo) : super(const HomeInitial());

  // تحميل قائمة المحادثات
  void loadUserChats(String userId) {
    emit(const HomeLoading());

    _chatsSubscription?.cancel();

    _chatsSubscription = chatRepo
        .getUserChats(userId)
        .listen(
          (either) {
            either.fold(
              (failure) {
                emit(
                  HomeError(
                    error: failure.errorMessage,
                    chats: state.chats,
                    usersCache: state.usersCache,
                  ),
                );
              },
              (chats) async {
                // إذا لم توجد محادثات، نرسل حالة فارغة
                if (chats.isEmpty) {
                  emit(HomeLoaded(chats: chats, usersCache: {}));
                  return;
                }

                // جمع جميع IDs للمستخدمين الآخرين
                final otherUserIds = <String>{};
                for (final chat in chats) {
                  final otherUserId = chat.participants.firstWhere(
                    (id) => id != userId,
                    orElse: () => '',
                  );
                  if (otherUserId.isNotEmpty) {
                    otherUserIds.add(otherUserId);
                  }
                }

                try {
                  // جلب بيانات جميع المستخدمين الآخرين في مرة واحدة
                  final usersCacheEither = await userRepo.getUsersData(
                    otherUserIds.toList(),
                  );

                  usersCacheEither.fold(
                    (failure) {
                      emit(
                        HomeError(
                          error: failure.errorMessage,
                          chats: chats,
                          usersCache: {},
                        ),
                      );
                    },
                    (usersCache) {
                      emit(HomeLoaded(chats: chats, usersCache: usersCache));
                    },
                  );
                } catch (e) {
                  print('Error loading users: $e');
                  // في حالة الخطأ، نرسل المحادثات بدون بيانات المستخدمين
                  emit(HomeLoaded(chats: chats, usersCache: {}));
                }
              },
            );
          },
          onError: (error) {
            emit(
              HomeError(
                error: error.toString(),
                chats: state.chats,
                usersCache: state.usersCache,
              ),
            );
          },
        );
  }

  @override
  Future<void> close() {
    _chatsSubscription?.cancel();
    return super.close();
  }
}
