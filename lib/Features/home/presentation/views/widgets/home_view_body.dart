import 'package:chatbox/Features/home/presentation/views/widgets/chat_list.dart';
import 'package:chatbox/Features/home/presentation/views/widgets/search_result_view.dart';
import 'package:flutter/material.dart';

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

    return const Column(children: [Expanded(child: ChatList())]);
  }
}
