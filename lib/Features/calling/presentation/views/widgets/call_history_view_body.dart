import 'package:chatbox/Features/calling/presentation/manager/call/call_cubit.dart';
import 'package:chatbox/Features/calling/presentation/manager/call/call_state.dart';
import 'package:chatbox/Features/calling/presentation/views/widgets/call_history_list.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CallHistoryViewBody extends StatefulWidget {
  const CallHistoryViewBody({super.key});

  @override
  State<CallHistoryViewBody> createState() => _CallHistoryViewBodyState();
}

class _CallHistoryViewBodyState extends State<CallHistoryViewBody> {
  @override
  void initState() {
    super.initState();
    final userId = FirebaseAuth.instance.currentUser!.uid;
    context.read<CallHistoryCubit>().loadCallHistory(userId);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CallHistoryCubit, CallHistoryState>(
      builder: (context, state) {
        if (state is CallHistoryLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is CallHistoryLoaded) {
          return CallHistoryList(calls: state.calls);
        } else if (state is CallHistoryError) {
          return Center(child: Text('Error: ${state.message}'));
        } else if (state is CallHistoryDeleting) {
          return CallHistoryList(calls: state.calls, isDeleting: true);
        } else if (state is CallHistoryDeleteSuccess) {
          return CallHistoryList(calls: state.calls, deletedCallId: state.deletedCallId);
        } else if (state is CallHistoryDeleteError) {
          return CallHistoryList(calls: state.calls, errorMessage: state.message);
        } else {
          return const Center(child: Text('No call history available'));
        }
      },
    );
  }
}