import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chatbox/Features/auth/presentation/data/models/user_model.dart';
import 'package:chatbox/Features/auth/presentation/data/repos/auth_repo.dart';
import 'package:meta/meta.dart';

part 'register_state.dart';

class RegisterCubit extends Cubit<RegisterState> {
  final AuthRepo authRepo;
  RegisterCubit(this.authRepo) : super(RegisterInitial());

  Future<void> registerUser({
    required String email,
    required String password,
    required String name,
    required File imageFile,
  }) async {
    emit(RegisterLoading());

    final result = await authRepo.createUserWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
      profilePic: imageFile,
    );

    result.fold(
      (failure) => emit(RegisterError(errorMessage: failure.errorMessage)),
      (user) => emit(RegisterSuccess(user: user)),
    );
  }
}
