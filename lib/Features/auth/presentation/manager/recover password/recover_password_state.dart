part of 'recover_password_cubit.dart';

@immutable
sealed class RecoverPasswordState {}

final class RecoverPasswordInitial extends RecoverPasswordState {}

final class RecoverPasswordLoading extends RecoverPasswordState {}

final class RecoverPasswordError extends RecoverPasswordState {
  final String message;
  RecoverPasswordError({required this.message});
}

final class RecoverPasswordSuccess extends RecoverPasswordState {}
