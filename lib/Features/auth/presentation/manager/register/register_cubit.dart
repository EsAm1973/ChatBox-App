import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/auth/data/repos/auth_repo.dart';
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
      (user) => emit(RegisterEmailVerificationSent(
        email: email,
        message: 'Account created successfully! Please check your email to verify your account.',
      )),
    );
  }
  
  // Method to resend verification email
  Future<void> resendVerificationEmail(String email) async {
    emit(RegisterLoading());
    try {
      await authRepo.sendEmailVerification(email: email);
      emit(RegisterEmailVerificationSent(
        email: email,
        message: 'Verification email resent. Please check your inbox.',
      ));
    } catch (e) {
      emit(RegisterError(
        errorMessage: 'Failed to resend verification email: ${e.toString()}',
      ));
    }
  }
  
  // Method to check if email is verified
  Future<void> checkEmailVerification(String email) async {
    emit(RegisterLoading());
    final result = await authRepo.isEmailVerified(email: email);
    
    result.fold(
      (failure) => emit(RegisterError(errorMessage: failure.errorMessage)),
      (isVerified) {
        if (isVerified) {
          // If email is verified, get user data and emit success
          _getUserDataAndEmitSuccess();
        } else {
          emit(RegisterEmailVerificationSent(
            email: email,
            message: 'Your email is not verified yet. Please check your inbox.',
          ));
        }
      },
    );
  }
  
  // Helper method to get user data and emit success
  Future<void> _getUserDataAndEmitSuccess() async {
    final result = await authRepo.getCurrentUserData();
    
    result.fold(
      (failure) => emit(RegisterError(errorMessage: failure.errorMessage)),
      (user) => emit(RegisterSuccess(user: user)),
    );
  }
}
