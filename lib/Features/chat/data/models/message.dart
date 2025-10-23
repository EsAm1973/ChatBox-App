import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus { pending, sent, delivered, read, failed }

enum MessageType { text, voice, image, file }

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime? timestamp; // جعلناها nullable لاستخدام server timestamp
  final bool isRead;
  final MessageStatus status;
  final MessageType type;
  final int? voiceDuration;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.timestamp, // لم نعد نطلب timestamp إجباري
    required this.isRead,
    this.status = MessageStatus.sent,
    this.type = MessageType.text,
    this.voiceDuration,
  });

  Map<String, dynamic> toMap({bool useServerTimestamp = false}) {
    final map = {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'isRead': isRead,
      'status': status.name,
      'type': type.name,
      if (voiceDuration != null) 'voiceDuration': voiceDuration,
    };

    if (useServerTimestamp) {
      map['timestamp'] = FieldValue.serverTimestamp();
    } else if (timestamp != null) {
      map['timestamp'] = Timestamp.fromDate(timestamp!);
    } else {
      map['timestamp'] = FieldValue.serverTimestamp();
    }

    return map;
  }

  factory MessageModel.fromMap(Map<String, dynamic> map) {
    DateTime timestamp;
    if (map['timestamp'] is Timestamp) {
      timestamp = (map['timestamp'] as Timestamp).toDate();
    } else if (map['timestamp'] is int) {
      timestamp = DateTime.fromMillisecondsSinceEpoch(map['timestamp']);
    } else {
      timestamp = DateTime.now();
    }

    MessageStatus status = MessageStatus.sent;
    if (map['status'] != null) {
      try {
        status = MessageStatus.values.firstWhere(
          (e) => e.name == map['status'],
          orElse: () => MessageStatus.sent,
        );
      } catch (e) {
        status = MessageStatus.sent;
      }
    }

    MessageType type = MessageType.text;
    if (map['type'] != null) {
      try {
        type = MessageType.values.firstWhere(
          (e) => e.name == map['type'],
          orElse: () => MessageType.text,
        );
      } catch (e) {
        type = MessageType.text;
      }
    }

    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: timestamp,
      isRead: map['isRead'] ?? false,
      status: status,
      type: type,
      voiceDuration: map['voiceDuration'],
    );
  }
  MessageModel copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    MessageStatus? status,
    MessageType? type,
    int? voiceDuration,
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status,
      type: type ?? this.type,
      voiceDuration: voiceDuration ?? this.voiceDuration,
    );
  }
}
