// // repos/call_repo_impl.dart
// import 'package:chatbox/Core/errors/firebase_failures.dart';
// import 'package:chatbox/Core/service/firestore_call_service.dart';
// import 'package:chatbox/Features/calling/data/models/call_model.dart';
// import 'package:chatbox/Features/calling/data/repos/call_repo.dart';
// import 'package:dartz/dartz.dart';


// class CallRepoImpl implements CallRepo {
//   final FirestoreCallService _firestoreCallService;

//   CallRepoImpl({required FirestoreCallService firestoreCallService})
//     : _firestoreCallService = firestoreCallService;

//   @override
//   Future<Either<Failure, String>> initiateCall({
//     required String callerId,
//     required String callerEmail,
//     required String receiverId,
//     required String receiverEmail,
//     CallType callType = CallType.voice,
//   }) async {
//     try {
//       final createdCallId = await _firestoreCallService.createCall(
//         callerId: callerId,
//         callerEmail: callerEmail,
//         receiverId: receiverId,
//         receiverEmail: receiverEmail,
//         callType: callType,
//       );

//       return Right(createdCallId);
//     } on FirebaseFailure catch (e) {
//       return Left(e);
//     } catch (e) {
//       return Left(FirebaseFailure(errorMessage: 'Failed to initiate call: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> updateCallStatus({
//     required String callId,
//     required CallStatus status,
//     int? duration,
//   }) async {
//     try {
//       await _firestoreCallService.updateCallStatus(
//         callId: callId,
//         status: status,
//         duration: duration,
//       );
//       return const Right(null);
//     } on FirebaseFailure catch (e) {
//       return Left(e);
//     } catch (e) {
//       return Left(
//         FirebaseFailure(errorMessage: 'Failed to update call status: $e'),
//       );
//     }
//   }

//   @override
//   Future<Either<Failure, CallModel?>> getCall(String callId) async {
//     try {
//       final call = await _firestoreCallService.getCall(callId);
//       return Right(call);
//     } on FirebaseFailure catch (e) {
//       return Left(e);
//     } catch (e) {
//       return Left(FirebaseFailure(errorMessage: 'Failed to get call: $e'));
//     }
//   }

//   @override
//   Future<Either<Failure, void>> deleteCall(String callId) async {
//     try {
//       await _firestoreCallService.deleteCall(callId);
//       return const Right(null);
//     } on FirebaseFailure catch (e) {
//       return Left(e);
//     } catch (e) {
//       return Left(FirebaseFailure(errorMessage: 'Failed to delete call: $e'));
//     }
//   }

//   @override
//   Stream<Either<Failure, List<CallModel>>> getIncomingCalls(String userId) {
//     return _firestoreCallService
//         .getIncomingCallsStream(userId)
//         .map((calls) => Right<Failure, List<CallModel>>(calls))
//         .handleError((error) {
//           return Left<Failure, List<CallModel>>(
//             FirebaseFailure(
//               errorMessage: 'Failed to get incoming calls: $error',
//             ),
//           );
//         });
//   }

//   @override
//   Stream<Either<Failure, CallModel?>> getCallUpdates(String callId) {
//     return _firestoreCallService
//         .getCallStream(callId)
//         .map((call) => Right<Failure, CallModel?>(call))
//         .handleError((error) {
//           return Left<Failure, CallModel?>(
//             FirebaseFailure(errorMessage: 'Failed to get call updates: $error'),
//           );
//         });
//   }

//   @override
//   Stream<Either<Failure, List<CallModel>>> getCallHistory(String userId) {
//     return _firestoreCallService
//         .getUserCallHistory(userId)
//         .map((calls) => Right<Failure, List<CallModel>>(calls))
//         .handleError((error) {
//           return Left<Failure, List<CallModel>>(
//             FirebaseFailure(errorMessage: 'Failed to get call history: $error'),
//           );
//         });
//   }

//   @override
//   String generateCallId() {
//     return _firestoreCallService.generateCallId();
//   }
// }
