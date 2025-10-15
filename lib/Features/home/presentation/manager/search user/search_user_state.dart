import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:equatable/equatable.dart';

enum SearchStatus { initial, loading, success, failure }

class SearchUserState extends Equatable {
  final SearchStatus status;
  final List<UserModel> results;
  final Failure? error;

  const SearchUserState({
    this.status = SearchStatus.initial,
    this.results = const [],
    this.error,
  });

  SearchUserState copyWith({
    SearchStatus? status,
    List<UserModel>? results,
    Failure? error,
  }) {
    return SearchUserState(
      status: status ?? this.status,
      results: results ?? this.results,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [status, results, error];
}
