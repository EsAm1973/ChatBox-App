import 'package:chatbox/Features/home/presentation/manager/home%20chats/home_chats_cubit.dart';
import 'package:chatbox/Features/home/presentation/manager/home%20chats/home_chats_state.dart';
import 'package:chatbox/Features/home/presentation/views/widgets/chat_list.dart';
import 'package:chatbox/Features/home/presentation/views/widgets/search_result_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeViewBody extends StatelessWidget {
  final bool isSearching;
  final TextEditingController searchController;

  const HomeViewBody({
    super.key,
    required this.isSearching,
    required this.searchController,
  });

@override
  Widget build(BuildContext context) {
    if (isSearching) {
      return const SearchResultsView();
    }

    // Add a HomeCubit provider check as a safeguard
    return BlocBuilder<HomeCubit, HomeState>(
      builder: (context, state) {
        return const Column(children: [Expanded(child: ChatList())]);
      },
    );
  }
}
