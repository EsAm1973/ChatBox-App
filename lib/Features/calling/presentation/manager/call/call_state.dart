import 'package:chatbox/Features/calling/data/models/call_model.dart';

abstract class CallHistoryState {
  const CallHistoryState();
}

class CallHistoryInitial extends CallHistoryState {}

class CallHistoryLoading extends CallHistoryState {}

class CallHistoryLoaded extends CallHistoryState {
  final List<CallModel> calls;
  const CallHistoryLoaded(this.calls);
}

class CallHistoryError extends CallHistoryState {
  final String message;
  const CallHistoryError(this.message);
}

class CallHistoryDeleting extends CallHistoryState {
  final List<CallModel> calls;
  const CallHistoryDeleting(this.calls);
}

class CallHistoryDeleteSuccess extends CallHistoryState {
  final List<CallModel> calls;
  final String deletedCallId;
  const CallHistoryDeleteSuccess(this.calls, this.deletedCallId);
}

class CallHistoryDeleteError extends CallHistoryState {
  final List<CallModel> calls;
  final String message;
  const CallHistoryDeleteError(this.calls, this.message);
}
