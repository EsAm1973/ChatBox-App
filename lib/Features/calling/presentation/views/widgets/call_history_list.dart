import 'package:chatbox/Core/utils/app_text_styles.dart';
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:chatbox/Features/calling/presentation/manager/call/call_cubit.dart';
import 'package:chatbox/Features/calling/presentation/views/widgets/call_history_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
      return const Center(child: Text('No call history available'));
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
            padding: EdgeInsets.only(right: 20.w),
            color: Colors.red,
            child: Icon(Icons.delete, color: Theme.of(context).iconTheme.color),
          ),
          confirmDismiss: (direction) async {
            return await showDialog(
              context: context,
              builder: (BuildContext context) {
                return AlertDialog(
                  backgroundColor: Theme.of(context).colorScheme.surface,
                  title: const Text('Delete Call'),
                  content: const Text(
                    'Are you sure you want to delete this call from history?',
                  ),
                  actions: <Widget>[
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(false),
                      child: Text(
                        'Cancel',
                        style: AppTextStyles.semiBold14.copyWith(
                          fontFamily: null,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => Navigator.of(context).pop(true),
                      child: Text(
                        'Delete',
                        style: AppTextStyles.semiBold14.copyWith(
                          fontFamily: null,
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
          onDismissed: (direction) {
            context.read<CallHistoryCubit>().deleteCall(call.callId);
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5),
            child: CallHistoryItem(
              call: call,
              isDeleting: isDeleting && deletedCallId == call.callId,
              deletedCallId: deletedCallId,
              errorMessage: errorMessage,
            ),
          ),
        );
      },
    );
  }
}
