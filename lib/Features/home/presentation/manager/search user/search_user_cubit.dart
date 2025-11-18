import 'package:bloc/bloc.dart';
import 'package:chatbox/Features/home/data/repos/user_search_repo.dart';
import 'package:chatbox/Features/home/presentation/manager/search%20user/search_user_state.dart';

class SearchUserCubit extends Cubit<SearchUserState> {
  final SearchUserRepo _homeRepository;

  SearchUserCubit({required SearchUserRepo homeRepository})
    : _homeRepository = homeRepository,
      super(const SearchUserState());

  Future<void> search(String query) async {
    if (query.isEmpty) {
      emit(
        state.copyWith(
          status: SearchStatus.initial,
          results: const [],
          error: null,
        ),
      );
      return;
    }

    emit(state.copyWith(status: SearchStatus.loading, error: null));

    final result = await _homeRepository.searchUsers(query);

    result.fold(
      (failure) => emit(
        state.copyWith(
          status: SearchStatus.failure,
          error: failure,
          results: const [],
        ),
      ),
      (users) => emit(
        state.copyWith(
          status: SearchStatus.success,
          results: users,
          error: null,
        ),
      ),
    );
  }

  void clear() {
    emit(
      const SearchUserState(
        status: SearchStatus.initial,
        results: [],
        error: null,
      ),
    );
  }
}
