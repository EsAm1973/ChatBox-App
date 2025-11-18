import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:dartz/dartz.dart';

abstract class CallRepo {
  Stream<Either<Failure, List<CallModel>>> getCallHistory(String userId);
  Future<Either<Failure, Unit>> deleteCall(String callId);
}
