import 'package:bloc/bloc.dart';
import 'package:chatbox/Features/auth/presentation/data/models/user_model.dart';
import 'package:chatbox/Features/auth/presentation/data/repos/auth_repo.dart';
import 'package:meta/meta.dart';

part 'login_state.dart';

class LoginCubit extends Cubit<LoginState> {
  final AuthRepo authRepo;
  LoginCubit(this.authRepo) : super(LoginInitial());

  void loginUser({required String email, required String password}) async {
    emit(LoginLoading());
    final result = await authRepo.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    result.fold(
      (failure) {
        // Check if the error is related to email verification
        if (failure.errorMessage.contains('verify your email')) {
          emit(LoginEmailNotVerified(email: email, errorMessage: failure.errorMessage));
        } else {
          emit(LoginError(errorMessage: failure.errorMessage));
        }
      },
      (user) => emit(LoginSuccess(user: user)),
    );
  }
  
  // Method to resend verification email
  Future<void> resendVerificationEmail(String email) async {
    emit(LoginLoading());
    try {
      await authRepo.sendEmailVerification(email: email);
      emit(LoginEmailNotVerified(
        email: email,
        errorMessage: 'Verification email resent. Please check your inbox.',
      ));
    } catch (e) {
      emit(LoginError(
        errorMessage: 'Failed to resend verification email: ${e.toString()}',
      ));
    }
  }
}
