import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:chatbox/Features/calling/data/repos/call_repo.dart';
import 'package:chatbox/Features/calling/presentation/manager/call/call_state.dart';


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
      // Get the created call to get room ID and stream ID
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

  /// Join a call as the caller (for ZegoUIKit, this is handled automatically)
  Future<void> joinCallAsCaller(CallModel call) async {
    // For ZegoUIKit, the call is joined automatically when the CallView is opened
    // We just need to update the status
    _callRepo.updateCallStatus(
      callId: call.callId,
      status: CallStatus.in_progress,
    );
    emit(CallInProgress(currentCall: call));
  }

  /// Accept an incoming call (ZegoUIKit handles the actual call joining)
  Future<void> acceptCall(CallModel call) async {
    emit(const CallLoading());

    // Update call status to in_progress
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

  /// End an ongoing call
  Future<void> endCall(CallModel call) async {
    emit(const CallLoading());

    // Calculate duration
    final duration = DateTime.now().difference(call.startedAt).inSeconds;

    // Update call status and duration
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
              break;
            default:
              break;
          }
        }
      });
    });
  }

  // Note: Microphone and speaker controls are handled by ZegoUIKit internally
  // No need for separate toggle methods in the cubit

  /// Load call history
  void loadCallHistory(String userId) {
    _callRepo.getCallHistory(userId).listen((result) {
      result.fold(
        (failure) => emit(CallError(error: failure.errorMessage)),
        (callHistory) => emit(CallHistoryLoaded(callHistory: callHistory)),
      );
    });
  }

  @override
  Future<void> close() {
    _incomingCallsSubscription?.cancel();
    _callUpdatesSubscription?.cancel();
    return super.close();
  }
}
