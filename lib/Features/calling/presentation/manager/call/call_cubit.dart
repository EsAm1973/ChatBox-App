import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:chatbox/Features/calling/data/repos/call_repo.dart';
import 'package:chatbox/Features/calling/presentation/manager/call/call_state.dart';

import 'package:flutter_bloc/flutter_bloc.dart';

class CallCubit extends Cubit<CallState> {
  final CallRepo _callRepo;
  StreamSubscription? _incomingCallsSubscription;
  StreamSubscription? _callUpdatesSubscription;

  CallCubit(this._callRepo) : super(const CallInitial());

  /// Initiate a call to another user
  Future<void> initiateCall({
    required String callerId,
    required String callerEmail,
    required String receiverId,
    required String receiverEmail,
    CallType callType = CallType.voice,
  }) async {
    emit(const CallLoading());

    final result = await _callRepo.initiateCall(
      callerId: callerId,
      callerEmail: callerEmail,
      receiverId: receiverId,
      receiverEmail: receiverEmail,
      callType: callType,
    );

    result.fold((failure) => emit(CallError(error: failure.errorMessage)), (
      callId,
    ) async {
      final callResult = await _callRepo.getCall(callId);
      callResult.fold(
        (failure) => emit(CallError(error: failure.errorMessage)),
        (call) {
          if (call != null) {
            emit(CallInvitationSent(currentCall: call));
            _listenToCallUpdates(callId);
          } else {
            emit(const CallError(error: 'Failed to create call'));
          }
        },
      );
    });
  }

  /// Accept an incoming call
  Future<void> acceptCall(CallModel call) async {
    emit(const CallLoading());

    final updateResult = await _callRepo.updateCallStatus(
      callId: call.callId,
      status: CallStatus.in_progress,
    );

    updateResult.fold(
      (failure) =>
          emit(CallError(error: failure.errorMessage, currentCall: call)),
      (_) {
        emit(
          CallInProgress(
            currentCall: call.copyWith(status: CallStatus.in_progress),
          ),
        );
      },
    );
  }

  /// Reject a call
  Future<void> rejectCall(CallModel call) async {
    emit(const CallLoading());

    final result = await _callRepo.updateCallStatus(
      callId: call.callId,
      status: CallStatus.rejected,
    );

    result.fold(
      (failure) =>
          emit(CallError(error: failure.errorMessage, currentCall: call)),
      (_) => emit(
        CallEnded(callHistory: [call.copyWith(status: CallStatus.rejected)]),
      ),
    );
  }

  /// Cancel a call (for the caller)
  Future<void> cancelCall(CallModel call) async {
    final result = await _callRepo.updateCallStatus(
      callId: call.callId,
      status: CallStatus.cancelled,
    );

    result.fold(
      (failure) =>
          emit(CallError(error: failure.errorMessage, currentCall: call)),
      (_) => emit(
        CallEnded(callHistory: [call.copyWith(status: CallStatus.cancelled)]),
      ),
    );
  }

  /// End an ongoing call
  Future<void> endCall(CallModel call) async {
    final duration = DateTime.now().difference(call.startedAt).inSeconds;

    final result = await _callRepo.updateCallStatus(
      callId: call.callId,
      status: CallStatus.completed,
      duration: duration,
    );

    result.fold(
      (failure) =>
          emit(CallError(error: failure.errorMessage, currentCall: call)),
      (_) {
        final endedCall = call.copyWith(
          status: CallStatus.completed,
          duration: duration,
          endedAt: DateTime.now(),
        );
        emit(CallEnded(callHistory: [endedCall]));
      },
    );
  }

  /// Listen for incoming calls
  void listenForIncomingCalls(String userId) {
    _incomingCallsSubscription?.cancel();
    _incomingCallsSubscription = _callRepo.getIncomingCalls(userId).listen((
      result,
    ) {
      result.fold((failure) => emit(CallError(error: failure.errorMessage)), (
        calls,
      ) {
        if (calls.isNotEmpty) {
          final incomingCall = calls.first;
          emit(CallInvitationReceived(currentCall: incomingCall));
          _listenToCallUpdates(incomingCall.callId);
        }
      });
    });
  }

  /// Listen for call updates
  void _listenToCallUpdates(String callId) {
    _callUpdatesSubscription?.cancel();
    _callUpdatesSubscription = _callRepo.getCallUpdates(callId).listen((
      result,
    ) {
      result.fold((failure) => emit(CallError(error: failure.errorMessage)), (
        call,
      ) {
        if (call != null) {
          switch (call.status) {
            case CallStatus.ringing:
              emit(CallInvitationReceived(currentCall: call));
              break;
            case CallStatus.in_progress:
              emit(CallInProgress(currentCall: call));
              break;
            case CallStatus.completed:
            case CallStatus.missed:
            case CallStatus.rejected:
            case CallStatus.cancelled:
            case CallStatus.failed:
              emit(CallEnded(callHistory: [call]));
              _callUpdatesSubscription?.cancel();
              break;
            default:
              break;
          }
        }
      });
    });
  }

  /// Load call history
  void loadCallHistory(String userId) {
    _callRepo.getCallHistory(userId).listen((result) {
      result.fold(
        (failure) => emit(CallError(error: failure.errorMessage)),
        (callHistory) => emit(CallHistoryLoaded(callHistory: callHistory)),
      );
    });
  }

  /// Stop listening to incoming calls
  void stopListeningForIncomingCalls() {
    _incomingCallsSubscription?.cancel();
  }

  @override
  Future<void> close() {
    _incomingCallsSubscription?.cancel();
    _callUpdatesSubscription?.cancel();
    return super.close();
  }
}
