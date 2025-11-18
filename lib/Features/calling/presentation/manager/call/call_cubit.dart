import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:chatbox/Features/calling/data/repos/call_repo.dart';
import 'package:dartz/dartz.dart';

import 'call_state.dart';

class CallHistoryCubit extends Cubit<CallHistoryState> {
  final CallRepo _repository;
  Stream<Either<Failure, List<CallModel>>>? _callHistoryStream;

  CallHistoryCubit({required CallRepo repository})
    : _repository = repository,
      super(CallHistoryInitial());

  void loadCallHistory(String userId) {
    emit(CallHistoryLoading());

    _callHistoryStream = _repository.getCallHistory(userId);

    _callHistoryStream!.listen((either) {
      either.fold(
        (failure) => emit(CallHistoryError(failure.errorMessage)),
        (calls) => emit(CallHistoryLoaded(calls)),
      );
    });
  }

  void deleteCall(String callId) {
    final currentState = state;
    if (currentState is CallHistoryLoaded) {
      emit(CallHistoryDeleting(currentState.calls));

      _repository
          .deleteCall(callId)
          .then((_) {
            final updatedCalls =
                currentState.calls
                    .where((call) => call.callId != callId)
                    .toList();
            emit(CallHistoryDeleteSuccess(updatedCalls, callId));

            // نرجع للحالة العادية بعد ثانيتين
            Future.delayed(const Duration(seconds: 2), () {
              emit(CallHistoryLoaded(updatedCalls));
            });
          })
          .catchError((error) {
            emit(
              CallHistoryDeleteError(
                currentState.calls,
                'Failed to delete call: $error',
              ),
            );

            // نرجع للحالة العادية بعد ثانيتين
            Future.delayed(const Duration(seconds: 2), () {
              emit(CallHistoryLoaded(currentState.calls));
            });
          });
    }
  }

  void refreshCallHistory(String userId) {
    loadCallHistory(userId);
  }
}
