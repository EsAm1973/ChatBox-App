import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageStatus { pending, sent, delivered, read, failed }

class MessageModel {
  final String id;
  final String senderId;
  final String receiverId;
  final String content;
  final DateTime? timestamp; // جعلناها nullable لاستخدام server timestamp
  final bool isRead;
  final MessageStatus status;

  MessageModel({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.content,
    this.timestamp, // لم نعد نطلب timestamp إجباري
    required this.isRead,
    this.status = MessageStatus.sent,
  });

  Map<String, dynamic> toMap({bool useServerTimestamp = false}) {
    final map = {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
      'isRead': isRead,
      'status': status.name,
    };

    // استخدام server timestamp أو client timestamp بناءً على الإعداد
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

    return MessageModel(
      id: map['id'] ?? '',
      senderId: map['senderId'] ?? '',
      receiverId: map['receiverId'] ?? '',
      content: map['content'] ?? '',
      timestamp: timestamp,
      isRead: map['isRead'] ?? false,
      status: status,
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
  }) {
    return MessageModel(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      status: status ?? this.status,
    );
  }
}
