import 'package:chatbox/Features/home/presentation/manager/search%20user/search_user_cubit.dart';
import 'package:chatbox/Features/home/presentation/views/widgets/home_appbar.dart';
import 'package:chatbox/Features/home/presentation/views/widgets/home_view_body.dart';
import 'package:chatbox/Features/home/presentation/views/widgets/search_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();

  void _startSearch() {
    setState(() {
      _isSearching = true;
    });
  }

  void _stopSearch() {
    setState(() {
      _isSearching = false;
      _searchController.clear();
    });
    context.read<SearchUserCubit>().clear();
  }

  void _onSearchChanged(String query) {
    context.read<SearchUserCubit>().search(query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          _isSearching
              ? SearchAppBar(
                controller: _searchController,
                onBackPressed: _stopSearch,
                onSearchChanged: _onSearchChanged,
              )
              : HomeAppBar(onSearchPressed: _startSearch),
      body: HomeViewBody(
        isSearching: _isSearching,
        searchController: _searchController,
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
