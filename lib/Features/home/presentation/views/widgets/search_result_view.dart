import 'package:chatbox/Core/utils/app_router.dart';
import 'package:chatbox/Features/home/presentation/manager/search%20user/search_user_cubit.dart';
import 'package:chatbox/Features/home/presentation/manager/search%20user/search_user_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class SearchResultsView extends StatelessWidget {
  const SearchResultsView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchUserCubit, SearchUserState>(
      builder: (context, state) {
        return _buildSearchResults(state, context);
      },
    );
  }

  Widget _buildSearchResults(SearchUserState state, BuildContext context) {
    switch (state.status) {
      case SearchStatus.initial:
        return const Center(child: Text('Type to search for users by email'));

      case SearchStatus.loading:
        return const Center(child: CircularProgressIndicator());

      case SearchStatus.success:
        if (state.results.isEmpty) {
          return const Center(child: Text('No users found'));
        }
        return ListView.builder(
          itemCount: state.results.length,
          itemBuilder: (context, index) {
            final user = state.results[index];
            return InkWell(
              onTap: () {
                GoRouter.of(
                  context,
                ).push(AppRouter.kChatScreenRoute, extra: user);
              },
              child: ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(user.profilePic),
                ),
                title: Text(user.name),
                subtitle: Text(user.email),
              ),
            );
          },
        );

      case SearchStatus.failure:
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [Text('Error: ${state.error?.errorMessage}')],
          ),
        );
    }
  }
}
