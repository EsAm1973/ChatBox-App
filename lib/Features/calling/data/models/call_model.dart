// models/call_model.dart
import 'package:cloud_firestore/cloud_firestore.dart';

// models/call_model.dart

enum CallStatus {
  calling, // Calling another user
  ringing, // Receiving a call
  // ignore: constant_identifier_names
  in_progress, // Call is ongoing
  completed, // Call ended successfully
  missed, // Call was missed
  rejected, // Call was rejected
  cancelled, // Call was cancelled
  failed, // Call failed
}

enum CallType { voice, video }

class CallModel {
  final String callId;
  final String callerId;
  final String callerEmail;
  final String callerName;
  final String callerImage;
  final String receiverId;
  final String receiverEmail;
  final String receiverName;
  final String receiverImage;
  final CallType callType;
  final CallStatus status;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int duration; // in seconds
  final String? callChannel; // For Firestore real-time updates

  CallModel({
    required this.callId,
    required this.callerId,
    required this.callerEmail,
    required this.callerName,
    required this.callerImage,
    required this.receiverId,
    required this.receiverEmail,
    required this.receiverName,
    required this.receiverImage,
    this.callType = CallType.voice,
    required this.status,
    required this.startedAt,
    this.endedAt,
    this.duration = 0,
    this.callChannel,
  });

  Map<String, dynamic> toMap({bool useServerTimestamp = false}) {
    final map = {
      'callId': callId,
      'callerId': callerId,
      'callerEmail': callerEmail,
      'callerName': callerName,
      'callerImage': callerImage,
      'receiverId': receiverId,
      'receiverEmail': receiverEmail,
      'receiverName': receiverName,
      'receiverImage': receiverImage,
      'callType': callType.name,
      'status': status.name,
      'duration': duration,
      if (callChannel != null) 'callChannel': callChannel,
    };

    if (useServerTimestamp) {
      map['startedAt'] = FieldValue.serverTimestamp();
      if (endedAt != null) {
        map['endedAt'] = FieldValue.serverTimestamp();
      }
    } else {
      map['startedAt'] = Timestamp.fromDate(startedAt);
      if (endedAt != null) {
        map['endedAt'] = Timestamp.fromDate(endedAt!);
      }
    }

    return map;
  }

  factory CallModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDateTime(dynamic date) {
      if (date is Timestamp) {
        return date.toDate();
      } else if (date is int) {
        return DateTime.fromMillisecondsSinceEpoch(date);
      } else if (date is String) {
        return DateTime.parse(date);
      } else {
        return DateTime.now();
      }
    }

    CallType parseCallType(String type) {
      try {
        return CallType.values.firstWhere(
          (e) => e.name == type,
          orElse: () => CallType.voice,
        );
      } catch (e) {
        return CallType.voice;
      }
    }

    CallStatus parseCallStatus(String status) {
      try {
        return CallStatus.values.firstWhere(
          (e) => e.name == status,
          orElse: () => CallStatus.completed,
        );
      } catch (e) {
        return CallStatus.completed;
      }
    }

    return CallModel(
      callId: map['callId'] ?? '',
      callerId: map['callerId'] ?? '',
      callerEmail: map['callerEmail'] ?? '',
      callerName: map['callerName'] ?? '',
      callerImage: map['callerImage'] ?? '',
      receiverId: map['receiverId'] ?? '',
      receiverEmail: map['receiverEmail'] ?? '',
      receiverName: map['receiverName'] ?? '',
      receiverImage: map['receiverImage'] ?? '',
      callType: parseCallType(map['callType'] ?? 'voice'),
      status: parseCallStatus(map['status'] ?? 'completed'),
      startedAt: parseDateTime(map['startedAt']),
      endedAt: map['endedAt'] != null ? parseDateTime(map['endedAt']) : null,
      duration: map['duration'] ?? 0,
      callChannel: map['callChannel'],
    );
  }

  CallModel copyWith({
    String? callId,
    String? callerId,
    String? callerEmail,
    String? callerName,
    String? callerImage,
    String? receiverId,
    String? receiverEmail,
    String? receiverName,
    String? receiverImage,
    CallType? callType,
    CallStatus? status,
    DateTime? startedAt,
    DateTime? endedAt,
    int? duration,
    String? callChannel,
  }) {
    return CallModel(
      callId: callId ?? this.callId,
      callerId: callerId ?? this.callerId,
      callerEmail: callerEmail ?? this.callerEmail,
      callerName: callerName ?? this.callerName,
      callerImage: callerImage ?? this.callerImage,
      receiverId: receiverId ?? this.receiverId,
      receiverEmail: receiverEmail ?? this.receiverEmail,
      receiverName: receiverName ?? this.receiverName,
      receiverImage: receiverImage ?? this.receiverImage,
      callType: callType ?? this.callType,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      duration: duration ?? this.duration,
      callChannel: callChannel ?? this.callChannel,
    );
  }

  bool get isActive =>
      status == CallStatus.calling ||
      status == CallStatus.ringing ||
      status == CallStatus.in_progress;

  bool get isIncoming => status == CallStatus.ringing;
}
