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
      (failure) => emit(LoginError(errorMessage: failure.errorMessage)),
      (user) => emit(LoginSuccess(user: user)),
    );
  }
}
