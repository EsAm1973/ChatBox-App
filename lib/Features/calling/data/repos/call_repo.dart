import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:dartz/dartz.dart';

abstract class CallRepo {
  Future<Either<Failure, String>> initiateCall({
    required String callerId,
    required String callerEmail,
    required String receiverId,
    required String receiverEmail,
    CallType callType = CallType.voice,
  });

  Future<Either<Failure, void>> updateCallStatus({
    required String callId,
    required CallStatus status,
    int? duration,
  });

  Future<Either<Failure, CallModel?>> getCall(String callId);
  Future<Either<Failure, void>> deleteCall(String callId);

  Stream<Either<Failure, List<CallModel>>> getIncomingCalls(String userId);
  Stream<Either<Failure, CallModel?>> getCallUpdates(String callId);
  Stream<Either<Failure, List<CallModel>>> getCallHistory(String userId);

  // Helper methods for ZegoUIKit
  String generateCallId();
  String generateCallIdForUsers(String user1, String user2);
}
