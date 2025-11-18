import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:chatbox/Features/calling/presentation/manager/call/call_cubit.dart';
import 'package:chatbox/Features/calling/presentation/views/widgets/call_history_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CallHistoryList extends StatelessWidget {
  final List<CallModel> calls;
  final bool isDeleting;
  final String? deletedCallId;
  final String? errorMessage;

  const CallHistoryList({
    super.key,
    required this.calls,
    this.isDeleting = false,
    this.deletedCallId,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    if (calls.isEmpty) {
      return const Center(
        child: Text('No call history available'),
      );
    }

    return ListView.builder(
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        return Dismissible(
          key: Key(call.callId),
          direction: DismissDirection.endToStart,
          background: Container(
            alignment: Alignment.centerRight,
            padding: const EdgeInsets.only(right: 20),
            color: Colors.red,
            child: const Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  title: const Text('Delete Call'),
                  content: const Text('Are you sure you want to delete this call from history?'),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: const Text('Delete'),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            context.read<CallHistoryCubit>().deleteCall(call.callId);
          },
          child: CallHistoryItem(
            call: call,
            isDeleting: isDeleting && deletedCallId == call.callId,
            deletedCallId: deletedCallId,
            errorMessage: errorMessage,
          ),
        );
      },
    );
  }
}