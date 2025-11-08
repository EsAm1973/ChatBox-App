// services/firestore_call_service.dart
import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// services/firestore_call_service.dart

class FirestoreCallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate unique call ID
  String generateCallId() {
    return 'call_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Generate unique channel for real-time call updates
  String _generateCallChannel(String callerId, String receiverId) {
    final sortedIds = [callerId, receiverId]..sort();
    return 'call_channel_${sortedIds[0]}_${sortedIds[1]}';
  }

  /// Create a new call document
  Future<String> createCall({
    required String callerId,
    required String callerEmail,
    required String receiverId,
    required String receiverEmail,
    CallType callType = CallType.voice,
    String? zegoRoomId,
    String? streamID, // ⭐ Added streamID parameter
  }) async {
    try {
      final callId = generateCallId();
      final callChannel = _generateCallChannel(callerId, receiverId);

      final callData = CallModel(
        callId: callId,
        callerId: callerId,
        callerEmail: callerEmail,
        receiverId: receiverId,
        receiverEmail: receiverEmail,
        callType: callType,
        status: CallStatus.calling,
        startedAt: DateTime.now(),
        callChannel: callChannel,
        zegoRoomId: zegoRoomId,
        streamID: streamID, // ⭐ Added
      ).toMap(useServerTimestamp: true);

      await _firestore.collection('calls').doc(callId).set(callData);
      return callId;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to create call: $e');
    }
  }

  /// Update call status
  Future<void> updateCallStatus({
    required String callId,
    required CallStatus status,
    int? duration,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'status': status.name,
        if (duration != null) 'duration': duration,
      };

      if (status == CallStatus.completed ||
          status == CallStatus.missed ||
          status == CallStatus.rejected) {
        updateData['endedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('calls').doc(callId).update(updateData);
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update call status: $e');
    }
  }

  /// Update call room ID and stream ID
  Future<void> updateCallRoomAndStream({
    required String callId,
    required String roomId,
    required String streamID,
  }) async {
    try {
      await _firestore.collection('calls').doc(callId).update({
        'zegoRoomId': roomId,
        'streamID': streamID,
      });
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(
        errorMessage: 'Failed to update call room and stream: $e',
      );
    }
  }

  /// Get call by ID
  Future<CallModel?> getCall(String callId) async {
    try {
      final doc = await _firestore.collection('calls').doc(callId).get();
      if (doc.exists) {
        return CallModel.fromMap(doc.data()!);
      }
      return null;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to get call: $e');
    }
  }

  /// Listen for incoming calls for a specific user
  Stream<List<CallModel>> getIncomingCallsStream(String userId) {
    return _firestore
        .collection('calls')
        .where('receiverId', isEqualTo: userId)
        .where(
          'status',
          whereIn: [CallStatus.calling.name, CallStatus.ringing.name],
        )
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => CallModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  /// Listen for call updates for a specific call
  Stream<CallModel?> getCallStream(String callId) {
    return _firestore.collection('calls').doc(callId).snapshots().map((
      snapshot,
    ) {
      if (!snapshot.exists) return null;
      return CallModel.fromMap(snapshot.data()!);
    });
  }

  /// Get user's call history
  Stream<List<CallModel>> getUserCallHistory(String userId) {
    return _firestore
        .collection('calls')
        .where(
          'status',
          whereIn: [
            CallStatus.completed.name,
            CallStatus.missed.name,
            CallStatus.rejected.name,
          ],
        )
        .orderBy('startedAt', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => CallModel.fromMap(doc.data()))
                  .where(
                    (call) =>
                        call.callerId == userId || call.receiverId == userId,
                  )
                  .toList(),
        );
  }

  /// Delete call (for cleanup)
  Future<void> deleteCall(String callId) async {
    try {
      await _firestore.collection('calls').doc(callId).delete();
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to delete call: $e');
    }
  }
}
