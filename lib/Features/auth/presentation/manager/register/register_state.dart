part of 'register_cubit.dart';

@immutable
sealed class RegisterState {}

final class RegisterInitial extends RegisterState {}

final class RegisterLoading extends RegisterState {}

final class RegisterError extends RegisterState {
  final String errorMessage;
  RegisterError({required this.errorMessage});
}

final class RegisterSuccess extends RegisterState {
  final UserModel user;
  RegisterSuccess({required this.user});
}

final class RegisterEmailVerificationSent extends RegisterState {
  final String email;
  final String message;
  RegisterEmailVerificationSent({
    required this.email,
    this.message = 'Verification email sent. Please check your inbox.',
  });
}
