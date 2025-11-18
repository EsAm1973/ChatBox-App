import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Core/service/firestore_call_service.dart';
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:chatbox/Features/calling/data/repos/call_repo.dart';
import 'package:dartz/dartz.dart';

class CallRepoImpl implements CallRepo {
  final FirestoreCallService _firestoreCallService;

  CallRepoImpl(this._firestoreCallService);

  @override
  Stream<Either<Failure, List<CallModel>>> getCallHistory(String userId) {
    try {
      // استخدم الـ method الموجود مباشرة
      return _firestoreCallService
          .getUserCallHistory(userId)
          .map((calls) => Right(calls));
    } catch (e) {
      return Stream.value(
        Left(FirebaseFailure(errorMessage: 'Failed to get call history: $e')),
      );
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCall(String callId) async {
    try {
      await _firestoreCallService.deleteCall(callId);
      return const Right(unit);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to delete call: $e'));
    }
  }
}
