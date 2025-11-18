import 'package:chatbox/Features/calling/presentation/views/call_history_view.dart';
import 'package:chatbox/Features/home/presentation/views/home_view.dart';
import 'package:chatbox/Features/navigation%20bar/presentation/views/widgets/custom_button_navigation_bar.dart';
import 'package:flutter/material.dart';

class HomeNavigationBar extends StatefulWidget {
  const HomeNavigationBar({super.key});

  @override
  State<HomeNavigationBar> createState() => _HomeNavigationBarState();
}

class _HomeNavigationBarState extends State<HomeNavigationBar> {
  int _currentIndex = 0;
  final List<Widget> _pages = [
    const HomeView(),
    const CallHistoryView(),
    // const SettingsView(),
    Container(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: CustomButtonNavigationBar(
        selectedIndex: _currentIndex,
        onTap: (i) => setState(() => _currentIndex = i),
      ),
    );
  }
}
