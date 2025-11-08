import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Core/service/firestore_call_service.dart';
import 'package:chatbox/Core/service/zego_cloud_service.dart';
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:chatbox/Features/calling/data/repos/call_repo.dart';
import 'package:dartz/dartz.dart';

class CallRepoImpl implements CallRepo {
  final FirestoreCallService _firestoreCallService;
  final ZegoCloudService _zegoCloudService;

  CallRepoImpl({
    required FirestoreCallService firestoreCallService,
    required ZegoCloudService zegoCloudService,
  }) : _firestoreCallService = firestoreCallService,
       _zegoCloudService = zegoCloudService;

  @override
  Future<Either<Failure, String>> initiateCall({
    required String callerId,
    required String callerEmail,
    required String receiverId,
    required String receiverEmail,
    CallType callType = CallType.voice,
  }) async {
    try {
      // Generate room ID and stream ID
      final roomId = _zegoCloudService.generateRoomId(
        callerEmail,
        receiverEmail,
      );
      final callId = _firestoreCallService.generateCallId();
      final streamID = _zegoCloudService.generateStreamId(callId);

      // Create call in Firestore
      final createdCallId = await _firestoreCallService.createCall(
        callerId: callerId,
        callerEmail: callerEmail,
        receiverId: receiverId,
        receiverEmail: receiverEmail,
        callType: callType,
        zegoRoomId: roomId,
        streamID: streamID,
      );

      return Right(createdCallId);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to initiate call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateCallStatus({
    required String callId,
    required CallStatus status,
    int? duration,
  }) async {
    try {
      await _firestoreCallService.updateCallStatus(
        callId: callId,
        status: status,
        duration: duration,
      );
      return const Right(null);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to update call status: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, CallModel?>> getCall(String callId) async {
    try {
      final call = await _firestoreCallService.getCall(callId);
      return Right(call);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to get call: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteCall(String callId) async {
    try {
      await _firestoreCallService.deleteCall(callId);
      return const Right(null);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to delete call: $e'));
    }
  }

  @override
  Stream<Either<Failure, List<CallModel>>> getIncomingCalls(String userId) {
    return _firestoreCallService
        .getIncomingCallsStream(userId)
        .map((calls) => Right<Failure, List<CallModel>>(calls))
        .handleError((error) {
          return Left<Failure, List<CallModel>>(
            FirebaseFailure(
              errorMessage: 'Failed to get incoming calls: $error',
            ),
          );
        });
  }

  @override
  Stream<Either<Failure, CallModel?>> getCallUpdates(String callId) {
    return _firestoreCallService
        .getCallStream(callId)
        .map((call) => Right<Failure, CallModel?>(call))
        .handleError((error) {
          return Left<Failure, CallModel?>(
            FirebaseFailure(errorMessage: 'Failed to get call updates: $error'),
          );
        });
  }

  @override
  Stream<Either<Failure, List<CallModel>>> getCallHistory(String userId) {
    return _firestoreCallService
        .getUserCallHistory(userId)
        .map((calls) => Right<Failure, List<CallModel>>(calls))
        .handleError((error) {
          return Left<Failure, List<CallModel>>(
            FirebaseFailure(errorMessage: 'Failed to get call history: $error'),
          );
        });
  }

  // ZEGOCLOUD Methods
  @override
  Future<Either<Failure, void>> joinVoiceCall({
    required String roomId,
    required String userId,
    required String userName,
    required String streamID,
  }) async {
    try {
      await _zegoCloudService.joinVoiceCall(
        roomId: roomId,
        userId: userId,
        userName: userName,
        streamID: streamID,
      );
      return const Right(null);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to join voice call: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> startPlayingStream(String streamID) async {
    try {
      await _zegoCloudService.startPlayingStream(streamID);
      return const Right(null);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to start playing stream: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> leaveVoiceCall() async {
    try {
      await _zegoCloudService.leaveVoiceCall();
      return const Right(null);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to leave voice call: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> toggleMicrophone(bool isMuted) async {
    try {
      await _zegoCloudService.toggleMicrophone(isMuted);
      return const Right(null);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to toggle microphone: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> toggleSpeaker(bool useSpeaker) async {
    try {
      await _zegoCloudService.toggleSpeaker(useSpeaker);
      return const Right(null);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to toggle speaker: $e'),
      );
    }
  }

  @override
  String generateRoomId(String callerEmail, String receiverEmail) {
    return _zegoCloudService.generateRoomId(callerEmail, receiverEmail);
  }

  @override
  String generateStreamId(String callId) {
    return _zegoCloudService.generateStreamId(callId);
  }
}
