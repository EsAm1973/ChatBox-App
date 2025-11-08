// ui/screens/incoming_call_screen.dart
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:chatbox/Features/calling/presentation/manager/call/call_cubit.dart';
import 'package:chatbox/Features/calling/presentation/views/call_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IncomingCallWidget extends StatelessWidget {
  final CallModel call;

  const IncomingCallWidget({super.key, required this.call});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<CallCubit>();

    return Material(
      color: Colors.black54,
      child: Center(
        child: Container(
          width: 320,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Incoming ${call.callType == CallType.voice ? 'Voice' : 'Video'} Call',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text('From: ${call.callerEmail}'),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      // accept -> update state via cubit and open Zego UI
                      await cubit.acceptCall(call);
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder:
                              (_) => CallView(
                                call: call,
                                localUserId: call.receiverId,
                                localUserName: call.receiverEmail,
                              ),
                        ),
                      );
                      await cubit.endCall(call);
                    },
                    child: const Text('Accept'),
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    onPressed: () async {
                      await cubit.rejectCall(call);
                    },
                    child: const Text('Reject'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
