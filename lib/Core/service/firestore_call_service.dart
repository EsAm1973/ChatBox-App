import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/calling/data/models/call_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreCallService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generate unique call ID (or use ZegoCloud's callID)
  String generateCallId() {
    return 'call_${DateTime.now().millisecondsSinceEpoch}';
  }

  /// Generate unique channel for real-time call updates
  String _generateCallChannel(String callerId, String receiverId) {
    final sortedIds = [callerId, receiverId]..sort();
    return 'call_channel_${sortedIds[0]}_${sortedIds[1]}';
  }

  /// Create a new call document with optional custom callId (for ZegoCloud)
  Future<String> createCall({
    String? callId, // Optional: use ZegoCloud's callID
    required String callerId,
    required String callerEmail,
    required String receiverId,
    required String receiverEmail,
    CallType callType = CallType.voice,
  }) async {
    try {
      final finalCallId = callId ?? generateCallId();
      final callChannel = _generateCallChannel(callerId, receiverId);

      final callData = CallModel(
        callId: finalCallId,
        callerId: callerId,
        callerEmail: callerEmail,
        receiverId: receiverId,
        receiverEmail: receiverEmail,
        callType: callType,
        status: CallStatus.calling,
        startedAt: DateTime.now(),
        callChannel: callChannel,
      ).toMap(useServerTimestamp: true);

      // Use set with merge to avoid overwriting if call already exists
      await _firestore
          .collection('calls')
          .doc(finalCallId)
          .set(callData, SetOptions(merge: true));
      return finalCallId;
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
          status == CallStatus.rejected ||
          status == CallStatus.cancelled) {
        updateData['endedAt'] = FieldValue.serverTimestamp();
      }

      await _firestore.collection('calls').doc(callId).update(updateData);
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update call status: $e');
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

  /// Get user's call history (all completed, missed, rejected calls)
  Stream<List<CallModel>> getUserCallHistory(String userId) {
    return _firestore
        .collection('calls')
        .where(
          'status',
          whereIn: [
            CallStatus.completed.name,
            CallStatus.missed.name,
            CallStatus.rejected.name,
            CallStatus.cancelled.name,
          ],
        )
        .orderBy('startedAt', descending: true)
        .limit(50) // Limit to last 50 calls for performance
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

  /// Batch delete old calls (cleanup utility)
  Future<void> deleteOldCalls({int daysOld = 30}) async {
    try {
      final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
      final snapshot =
          await _firestore
              .collection('calls')
              .where('startedAt', isLessThan: Timestamp.fromDate(cutoffDate))
              .get();

      final batch = _firestore.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('Deleted ${snapshot.docs.length} old calls');
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to delete old calls: $e');
    }
  }
}
