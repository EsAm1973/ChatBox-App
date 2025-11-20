import 'package:flutter/material.dart';
import 'package:chatbox/Features/profile/presentation/views/widgets/profile_app_bar.dart';
import 'package:chatbox/Features/profile/presentation/controllers/profile_view_controller.dart';
import 'package:chatbox/Features/profile/presentation/builders/profile_content_builder.dart';
import 'package:chatbox/Features/profile/presentation/builders/profile_state_builder.dart';

class ProfileView extends StatefulWidget {
  const ProfileView({super.key});

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> {
  late final ProfileViewController _controller;
  late final ProfileContentBuilder _contentBuilder;
  late final ProfileStateBuilder _stateBuilder;

  @override
  void initState() {
    super.initState();
    _initializeComponents();
  }

  void _initializeComponents() {
    _controller = ProfileViewController(context);
    _contentBuilder = ProfileContentBuilder();
    _stateBuilder = ProfileStateBuilder(
      controller: _controller,
      contentBuilder: _contentBuilder,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const ProfileAppBar(),
      body: SafeArea(child: _stateBuilder),
    );
  }
}
