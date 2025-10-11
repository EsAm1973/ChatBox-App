import 'package:chatbox/Features/home/presentation/views/widgets/chat_list.dart';
import 'package:flutter/material.dart';

class HomeViewBody extends StatelessWidget {
  const HomeViewBody({super.key});

  @override
  Widget build(BuildContext context) {
    return  const Column(children: [
      Expanded(child: ChatList()),
    ]);
  }
}
