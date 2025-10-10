import 'package:bloc/bloc.dart';
import 'package:chatbox/Features/auth/data/repos/auth_repo.dart';
import 'package:meta/meta.dart';

part 'recover_password_state.dart';

class RecoverPasswordCubit extends Cubit<RecoverPasswordState> {
  final AuthRepo authRepo;
  RecoverPasswordCubit(this.authRepo) : super(RecoverPasswordInitial());

  Future<void> recoverPassword({required String email}) async {
    emit(RecoverPasswordLoading());
    final result = await authRepo.sendPasswordResetEmail(email: email);
    result.fold(
      (l) => emit(RecoverPasswordError(message: l.errorMessage)),
      (r) => emit(RecoverPasswordSuccess()),
    );
  }
}
