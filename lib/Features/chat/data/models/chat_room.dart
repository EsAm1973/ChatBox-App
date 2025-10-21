import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoomModel {
  final String id;
  final List<String> participants;
  final MessageModel lastMessage;
  final DateTime lastMessageTime;
  final Map<String, int> unreadCounts;

  ChatRoomModel({
    required this.id,
    required this.participants,
    required this.lastMessage,
    required this.lastMessageTime,
    required this.unreadCounts,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'lastMessage': lastMessage.toMap(),
      'lastMessageTime': Timestamp.fromDate(lastMessageTime),
      'unreadCounts': unreadCounts,
    };
  }

  factory ChatRoomModel.fromMap(Map<String, dynamic> map) {
    DateTime lastMessageTime;
    if (map['lastMessageTime'] is Timestamp) {
      lastMessageTime = (map['lastMessageTime'] as Timestamp).toDate();
    } else if (map['lastMessageTime'] is int) {
      lastMessageTime = DateTime.fromMillisecondsSinceEpoch(
        map['lastMessageTime'],
      );
    } else {
      lastMessageTime = DateTime.now(); // fallback
    }

    return ChatRoomModel(
      id: map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      lastMessage: MessageModel.fromMap(map['lastMessage'] ?? {}),
      lastMessageTime: lastMessageTime,
      unreadCounts: Map<String, int>.from(map['unreadCounts'] ?? {}),
    );
  }

  ChatRoomModel copyWith({
    String? id,
    List<String>? participants,
    MessageModel? lastMessage,
    DateTime? lastMessageTime,
    Map<String, int>? unreadCounts,
  }) {
    return ChatRoomModel(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      lastMessage: lastMessage ?? this.lastMessage,
      lastMessageTime: lastMessageTime ?? this.lastMessageTime,
      unreadCounts: unreadCounts ?? this.unreadCounts,
    );
  }
}
