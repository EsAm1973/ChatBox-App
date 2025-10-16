import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

enum MessageType { text, image, file, location }

class Message extends Equatable {
  final String id;
  final String chatRoomId;
  final String senderId;
  final String text;
  final DateTime timestamp;
  final bool isRead;
  final MessageType type;
  final Map<String, dynamic>? metadata;

  const Message({
    required this.id,
    required this.chatRoomId,
    required this.senderId,
    required this.text,
    required this.timestamp,
    this.isRead = false,
    this.type = MessageType.text,
    this.metadata,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'chatRoomId': chatRoomId,
      'senderId': senderId,
      'text': text,
      'timestamp': Timestamp.fromDate(timestamp),
      'isRead': isRead,
      'type': type.name,
      'metadata': metadata,
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      id: map['id'] ?? '',
      chatRoomId: map['chatRoomId'] ?? '',
      senderId: map['senderId'] ?? '',
      text: map['text'] ?? '',
      timestamp: (map['timestamp'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      type: MessageType.values.firstWhere(
        (e) => e.name == map['type'],
        orElse: () => MessageType.text,
      ),
      metadata: map['metadata'] != null 
          ? Map<String, dynamic>.from(map['metadata'])
          : null,
    );
  }

  Message copyWith({
    bool? isRead,
  }) {
    return Message(
      id: id,
      chatRoomId: chatRoomId,
      senderId: senderId,
      text: text,
      timestamp: timestamp,
      isRead: isRead ?? this.isRead,
      type: type,
      metadata: metadata,
    );
  }

  @override
  List<Object?> get props => [
        id,
        chatRoomId,
        senderId,
        text,
        timestamp,
        isRead,
        type,
        metadata,
      ];
}