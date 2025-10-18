import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ChatRoom extends Equatable {
  final String id;
  final List<String> participants;
  final DateTime createdAt;
  final Map<String, dynamic> lastMessage;
  final Map<String, dynamic>? participantData;

  const ChatRoom({
    required this.id,
    required this.participants,
    required this.createdAt,
    required this.lastMessage,
    this.participantData,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'participants': participants,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastMessage': lastMessage,
      'participantData': participantData,
    };
  }

  factory ChatRoom.fromMap(Map<String, dynamic> map) {
    return ChatRoom(
      id: map['id'] ?? '',
      participants: List<String>.from(map['participants'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      lastMessage: Map<String, dynamic>.from(map['lastMessage'] ?? {}),
      participantData:
          map['participantData'] != null
              ? Map<String, dynamic>.from(map['participantData'])
              : null,
    );
  }

  ChatRoom copyWith({
    String? id,
    List<String>? participants,
    DateTime? createdAt,
    Map<String, dynamic>? lastMessage,
    Map<String, dynamic>? participantData,
  }) {
    return ChatRoom(
      id: id ?? this.id,
      participants: participants ?? this.participants,
      createdAt: createdAt ?? this.createdAt,
      lastMessage: lastMessage ?? this.lastMessage,
      participantData: participantData ?? this.participantData,
    );
  }

  @override
  List<Object?> get props => [id, participants, createdAt, lastMessage];
}
