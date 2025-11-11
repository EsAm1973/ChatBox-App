// import 'package:chatbox/Features/calling/data/models/call_model.dart';

// abstract class CallState {
//   final CallModel? currentCall;
//   final List<CallModel> callHistory;

//   const CallState({this.currentCall, this.callHistory = const []});
// }

// class CallInitial extends CallState {
//   const CallInitial();
// }

// class CallLoading extends CallState {
//   const CallLoading();
// }

// class CallInvitationSent extends CallState {
//   const CallInvitationSent({required super.currentCall});
// }

// class CallInvitationReceived extends CallState {
//   const CallInvitationReceived({required super.currentCall});
// }

// class CallInProgress extends CallState {
//   const CallInProgress({required super.currentCall});
// }

// class CallHistoryLoaded extends CallState {
//   const CallHistoryLoaded({required super.callHistory});
// }

// class CallEnded extends CallState {
//   const CallEnded({required super.callHistory});
// }

// class CallError extends CallState {
//   final String error;

//   const CallError({required this.error, super.currentCall, super.callHistory});
// }

