import 'package:bloc/bloc.dart';
import 'package:chatbox/Core/repos/user%20repo/user_repo.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:flutter/material.dart';

part 'user_state.dart';

class UserCubit extends Cubit<UserState> {
  final UserRepo userRepo;

  UserCubit({required this.userRepo}) : super(const UserInitial());
  Future<void> loadUser(String uid) async {
    emit(const UserLoading());

    final result = await userRepo.getUserData(uid);

    result.fold(
      (failure) => emit(UserError(failure.errorMessage)),
      (user) => emit(UserLoaded(user)),
    );
  }

  Future<void> updateUserProfile(UserModel updatedUser) async {
    if (state is UserLoaded) {
      final currentState = state as UserLoaded;
      emit(const UserLoading());

      final result = await userRepo.updateUserProfile(updatedUser);

      result.fold((failure) {
        emit(UserError(failure.errorMessage));
        emit(UserLoaded(currentState.user));
      }, (_) => emit(UserLoaded(updatedUser)));
    }
  }

  Future<void> updateProfilePicture(String imageUrl) async {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      final updatedUser = currentUser.copyWith(profilePic: imageUrl);

      emit(const UserLoading());

      final result = await userRepo.updateProfilePicture(
        currentUser.uid,
        imageUrl,
      );

      result.fold((failure) {
        emit(UserError(failure.errorMessage));
        emit(UserLoaded(currentUser));
      }, (_) => emit(UserLoaded(updatedUser)));
    }
  }

  Future<void> updateOnlineStatus(bool isOnline) async {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      final updatedUser = currentUser.copyWith(isOnline: isOnline);

      final result = await userRepo.updateUserOnlineStatus(
        currentUser.uid,
        isOnline,
      );

      result.fold(
        (failure) =>
            print('Failed to update online status: ${failure.errorMessage}'),
        (_) => emit(UserLoaded(updatedUser)),
      );
    }
  }

  Future<void> updateUserAbout(String about) async {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      final updatedUser = currentUser.copyWith(about: about);

      emit(const UserLoading());

      final result = await userRepo.updateUserAbout(currentUser.uid, about);

      result.fold((failure) {
        emit(UserError(failure.errorMessage));
        emit(UserLoaded(currentUser));
      }, (_) => emit(UserLoaded(updatedUser)));
    }
  }

  Future<void> updateUserPhoneNumber(String phoneNumber) async {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;
      final updatedUser = currentUser.copyWith(phoneNumber: phoneNumber);

      emit(const UserLoading());

      final result = await userRepo.updateUserPhoneNumber(
        currentUser.uid,
        phoneNumber,
      );

      result.fold((failure) {
        emit(UserError(failure.errorMessage));
        emit(UserLoaded(currentUser));
      }, (_) => emit(UserLoaded(updatedUser)));
    }
  }

  void subscribeToUserUpdates(String uid) {
    userRepo.getUserStream(uid).listen((result) {
      result.fold(
        (failure) => emit(UserError(failure.errorMessage)),
        (user) => emit(UserLoaded(user)),
      );
    });
  }

  Future<void> updateLastSeen() async {
    if (state is UserLoaded) {
      final currentUser = (state as UserLoaded).user;

      final result = await userRepo.updateUserLastSeen(currentUser.uid);

      result.fold(
        (failure) =>
            print('Failed to update last seen: ${failure.errorMessage}'),
        (_) {
          final updatedUser = currentUser.copyWith(lastSeen: DateTime.now());
          emit(UserLoaded(updatedUser));
        },
      );
    }
  }

  void setUser(UserModel user) {
    emit(UserLoaded(user));
  }

  void logout() {
    emit(const UserLoggedOut());
  }

  UserModel? getCurrentUser() {
    return state is UserLoaded ? (state as UserLoaded).user : null;
  }

  bool get isUserLoggedIn => state is UserLoaded;

  String? get currentUserId {
    return state is UserLoaded ? (state as UserLoaded).user.uid : null;
  }

  void setError(String message) {
    emit(UserError(message));
  }

  void reset() {
    emit(const UserInitial());
  }
}
