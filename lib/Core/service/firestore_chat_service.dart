import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Generates a unique chat room ID based on user IDs to ensure a one-to-one relationship
  String _generateChatRoomId(String user1, String user2) {
    final sortedIds = [user1, user2]..sort();
    return 'chat_${sortedIds[0]}_${sortedIds[1]}';
  }

  /// Creates a new chat room if it doesn't exist and returns the chat ID
  Future<String> createChatRoomIfNotExists(String user1, String user2) async {
    final chatId = _generateChatRoomId(user1, user2);
    final chatDoc = await _firestore.collection('chat_rooms').doc(chatId).get();

    if (!chatDoc.exists) {
      await _firestore.collection('chat_rooms').doc(chatId).set({
        'participants': [user1, user2],
        'createdAt': FieldValue.serverTimestamp(),
        'unreadCounts': {user1: 0, user2: 0},
      });
    }

    return chatId;
  }

  /// Sends a message to the specified chat room and updates last message
  Future<void> sendMessage(MessageModel message) async {
    final chatId = _generateChatRoomId(message.senderId, message.receiverId);
    final batch = _firestore.batch();

    // استخدام server timestamp للرسالة
    final messageData = message.toMap(useServerTimestamp: true);

    // Add message to messages subcollection
    final messageRef = _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .doc(message.id);
    batch.set(messageRef, messageData);

    // تحديث الـ chat room باستخدام FieldValue.increment الذري
    batch.update(_firestore.collection('chat_rooms').doc(chatId), {
      'lastMessage': messageData,
      'lastMessageTime': FieldValue.serverTimestamp(),
      'unreadCounts.${message.receiverId}': FieldValue.increment(1),
    });

    await batch.commit();
  }

  /// Returns a stream of messages for a specific chat room, ordered by timestamp
  Stream<List<MessageModel>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map((doc) => MessageModel.fromMap(doc.data()))
                  .toList(),
        );
  }

  /// Fetches all chat rooms where the user is a participant
  Stream<List<ChatRoomModel>> getUserChatsStream(String userId) {
    return _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: userId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map(
          (snapshot) =>
              snapshot.docs
                  .map(
                    (doc) =>
                        ChatRoomModel.fromMap({'id': doc.id, ...doc.data()}),
                  )
                  .toList(),
        );
  }

  /// Marks messages as seen for a specific chat and user
  Future<void> markMessagesAsSeen(String chatId, String userId) async {
    final batch = _firestore.batch();

    // Mark all unread messages as read for this user
    final messagesSnapshot =
        await _firestore
            .collection('chat_rooms')
            .doc(chatId)
            .collection('messages')
            .where('receiverId', isEqualTo: userId)
            .where('isRead', isEqualTo: false)
            .get();

    for (final doc in messagesSnapshot.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    // Reset unread count for this user in chat room
    final chatRoomRef = _firestore.collection('chat_rooms').doc(chatId);
    batch.update(chatRoomRef, {'unreadCounts.$userId': 0});

    await batch.commit();
  }
}
