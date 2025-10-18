// Add to your services
import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/chat/data/models/chat_room.dart';
import 'package:chatbox/Features/chat/data/models/message.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> saveUser(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).set(user.toMap());
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to save user data.');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      // Get user data first to verify it exists
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        throw FirebaseFailure(
          errorMessage: 'User data not found in Firestore.',
        );
      }

      // Delete the user document
      await _firestore.collection('users').doc(uid).delete();

      // Delete any other user-related data in other collections if needed
      // For example, if you have user messages, settings, etc.
      // await _deleteUserRelatedData(uid);
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to delete user data: $e');
    }
  }

  Future<UserModel?> getUser(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to fetch user data.');
    }
  }

  Future<UserModel?> getUserByEmail(String email) async {
    try {
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('email', isEqualTo: email)
              .limit(1)
              .get();

      if (querySnapshot.docs.isNotEmpty) {
        return UserModel.fromMap(querySnapshot.docs.first.data());
      }
      return null;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(
        errorMessage: 'Failed to fetch user data by email.',
      );
    }
  }

  Future<List<UserModel>> searchUsersByEmail(String searchQuery) async {
    try {
      // Convert to lowercase for case-insensitive search
      String query = searchQuery.toLowerCase();
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('email', isGreaterThanOrEqualTo: query)
              .where('email', isLessThanOrEqualTo: '$query\uf8ff')
              .limit(10) // Limits results for efficiency:cite[7]
              .get();

      // Convert documents to UserModel objects, filtering out any nulls
      return querySnapshot.docs
          .map((doc) => UserModel.fromMap(doc.data()))
          .where(
            (user) =>
                user.uid.isNotEmpty &&
                user.uid != FirebaseAuth.instance.currentUser?.uid,
          )
          .toList();
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to search users.');
    }
  }

  Future<String> getOrCreateChatRoom(String otherUserId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final participants = [currentUserId, otherUserId]..sort();
      final chatRoomId = participants.join('_');

      final chatRoomRef = _firestore.collection('chat_rooms').doc(chatRoomId);
      final doc = await chatRoomRef.get();

      if (!doc.exists) {
        await chatRoomRef.set({
          'id': chatRoomId,
          'participants': participants,
          'createdAt': FieldValue.serverTimestamp(),
          'lastMessage': {},
          'participantData': {
            currentUserId: await _getUserBasicInfo(currentUserId),
            otherUserId: await _getUserBasicInfo(otherUserId),
          },
        });
      }

      return chatRoomId;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to get or create chat room.');
    }
  }

  Future<Unit> sendMessage({
    required String chatRoomId,
    required String text,
    required String receiverId,
  }) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final messageId =
          _firestore
              .collection('chat_rooms')
              .doc(chatRoomId)
              .collection('messages')
              .doc()
              .id;

      final messageData = {
        'id': messageId,
        'chatRoomId': chatRoomId,
        'senderId': currentUserId,
        'text': text,
        'timestamp': FieldValue.serverTimestamp(),
        'isRead': false,
        'type': 'text',
      };

      final batch = _firestore.batch();

      // حفظ الرسالة
      batch.set(
        _firestore
            .collection('chat_rooms')
            .doc(chatRoomId)
            .collection('messages')
            .doc(messageId),
        messageData,
      );

      // تحديث آخر رسالة في غرفة المحادثة
      batch.update(_firestore.collection('chat_rooms').doc(chatRoomId), {
        'lastMessage': {
          'text': text,
          'senderId': currentUserId,
          'timestamp': FieldValue.serverTimestamp(),
          'isRead': false,
        },
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return unit;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to send message.');
    }
  }

  Stream<Object> getMessagesStream(String chatRoomId) {
    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots()
        .map((snapshot) {
          try {
            final messages =
                snapshot.docs
                    .map((doc) => Message.fromMap(doc.data()))
                    .toList();
            return messages;
          } catch (e) {
            throw FirebaseFailure(
              errorMessage: 'Failed to get messages stream.',
            );
          }
        })
        .handleError((error) {
          if (error is FirebaseException) {
            throw FirebaseFailure.fromFirestoreException(error);
          }
          throw FirebaseFailure(errorMessage: 'Failed to get messages stream.');
        });
  }

  Stream<List<ChatRoom>> getChatRoomsStream() {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      return _firestore
          .collection('chat_rooms')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastUpdated', descending: true)
          .snapshots()
          .asyncMap((snapshot) async {
            final chatRooms = <ChatRoom>[];

            for (final doc in snapshot.docs) {
              try {
                final chatRoomData = doc.data();
                final chatRoom = ChatRoom.fromMap(chatRoomData);

                // تحسين الأداء: جلب بيانات المشاركين فقط إذا كانت ناقصة
                Map<String, dynamic>? updatedParticipantData;
                if (chatRoom.participantData == null ||
                    chatRoom.participantData!.isEmpty) {
                  updatedParticipantData = await _getUpdatedParticipantData(
                    chatRoom.participants,
                  );
                }

                final updatedChatRoom = chatRoom.copyWith(
                  participantData:
                      updatedParticipantData ?? chatRoom.participantData,
                );

                chatRooms.add(updatedChatRoom);
              } catch (e) {
                print('Error parsing chat room ${doc.id}: $e');
                continue;
              }
            }

            return chatRooms;
          })
          .handleError((error) {
            if (error is FirebaseException) {
              // معالجة خاصة لأخطاء الفهرس
              if (error.code == 'failed-precondition') {
                print('Firestore index needs to be created: ${error.message}');
                // يمكنك إضافة منطق لإعلام المستخدم أو استخدام بديل
              }
              throw FirebaseFailure.fromFirestoreException(error);
            }
            throw FirebaseFailure(
              errorMessage: 'Failed to get chat rooms stream.',
            );
          });
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to get chat rooms stream.');
    }
  }

  Stream<List<ChatRoom>> getChatRoomsStreamFallback() {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      return _firestore
          .collection('chat_rooms')
          .where('participants', arrayContains: currentUserId)
          .snapshots() // بدون orderBy مؤقتاً
          .asyncMap((snapshot) async {
            final chatRooms = <ChatRoom>[];

            for (final doc in snapshot.docs) {
              try {
                final chatRoomData = doc.data();
                final chatRoom = ChatRoom.fromMap(chatRoomData);
                chatRooms.add(chatRoom);
              } catch (e) {
                print('Error parsing chat room ${doc.id}: $e');
                continue;
              }
            }

            // ترتيب محلياً
            chatRooms.sort((a, b) {
              final aTime = a.lastMessage['timestamp'] as Timestamp?;
              final bTime = b.lastMessage['timestamp'] as Timestamp?;

              if (aTime == null || bTime == null) return 0;
              return bTime.compareTo(aTime); // ترتيب تنازلي
            });

            return chatRooms;
          })
          .handleError((error) {
            if (error is FirebaseException) {
              throw FirebaseFailure.fromFirestoreException(error);
            }
            throw FirebaseFailure(
              errorMessage: 'Failed to get chat rooms stream.',
            );
          });
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to get chat rooms stream.');
    }
  }

  Future<Unit> markMessagesAsRead(String chatRoomId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      final messages =
          await _firestore
              .collection('chat_rooms')
              .doc(chatRoomId)
              .collection('messages')
              .where('senderId', isNotEqualTo: currentUserId)
              .where('isRead', isEqualTo: false)
              .get();

      final batch = _firestore.batch();

      for (final doc in messages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();
      return unit;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to mark messages as read.');
    }
  }

  Future<Map<String, dynamic>> _getUserBasicInfo(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        final userData = userDoc.data()!;
        return {
          'name': userData['name'],
          'profilePic': userData['profilePic'],
          'email': userData['email'],
        };
      }
      return {'name': 'Unknown User', 'profilePic': '', 'email': ''};
    } catch (e) {
      return {'name': 'Unknown User', 'profilePic': '', 'email': ''};
    }
  }

  Stream<List<ChatRoom>> getChatRoomsWithFilters({
    DateTime? since,
    int limit = 50,
  }) {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;
      var query = _firestore
          .collection('chat_rooms')
          .where('participants', arrayContains: currentUserId)
          .orderBy('lastUpdated', descending: true)
          .limit(limit);

      // إضافة فلتر التاريخ إذا كان موجود
      if (since != null) {
        query = query.where('lastUpdated', isGreaterThanOrEqualTo: since);
      }

      return query
          .snapshots()
          .asyncMap((snapshot) async {
            final chatRooms = <ChatRoom>[];

            for (final doc in snapshot.docs) {
              try {
                final chatRoomData = doc.data();
                final chatRoom = ChatRoom.fromMap(chatRoomData);

                // جلب معلومات محدثة عن المشاركين
                final updatedParticipantData = await _getUpdatedParticipantData(
                  chatRoom.participants,
                );
                final updatedChatRoom = chatRoom.copyWith(
                  participantData: updatedParticipantData,
                );

                chatRooms.add(updatedChatRoom);
              } catch (e) {
                print('Error parsing chat room ${doc.id}: $e');
                continue;
              }
            }

            return chatRooms;
          })
          .handleError((error) {
            if (error is FirebaseException) {
              throw FirebaseFailure.fromFirestoreException(error);
            }
            throw FirebaseFailure(
              errorMessage: 'Failed to get chat rooms stream.',
            );
          });
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to get chat rooms stream.');
    }
  }

  // جلب محادثة محددة
  Future<ChatRoom?> getChatRoom(String chatRoomId) async {
    try {
      final doc =
          await _firestore.collection('chat_rooms').doc(chatRoomId).get();

      if (doc.exists) {
        final chatRoom = ChatRoom.fromMap(doc.data()!);

        // جلب معلومات محدثة عن المشاركين
        final updatedParticipantData = await _getUpdatedParticipantData(
          chatRoom.participants,
        );
        final updatedChatRoom = chatRoom.copyWith(
          participantData: updatedParticipantData,
        );

        return updatedChatRoom;
      }

      return null;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to get chat room: $e');
    }
  }

  // تحديث آخر رؤية للمحادثة
  Future<void> updateChatRoomLastSeen(String chatRoomId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      await _firestore.collection('chat_rooms').doc(chatRoomId).update({
        'lastSeenBy.$currentUserId': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(
        errorMessage: 'Failed to update chat room last seen: $e',
      );
    }
  }

  // حذف محادثة
  Future<void> deleteChatRoom(String chatRoomId) async {
    try {
      final batch = _firestore.batch();

      // حذف جميع الرسائل أولاً
      final messagesSnapshot =
          await _firestore
              .collection('chat_rooms')
              .doc(chatRoomId)
              .collection('messages')
              .get();

      for (final doc in messagesSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // ثم حذف غرفة المحادثة
      batch.delete(_firestore.collection('chat_rooms').doc(chatRoomId));

      await batch.commit();
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to delete chat room: $e');
    }
  }

  Future<Map<String, dynamic>> _getUpdatedParticipantData(
    List<String> participantIds,
  ) async {
    final participantData = <String, dynamic>{};

    for (final participantId in participantIds) {
      try {
        final userDoc =
            await _firestore.collection('users').doc(participantId).get();
        if (userDoc.exists) {
          final userData = userDoc.data()!;
          participantData[participantId] = {
            'name': userData['name'],
            'profilePic': userData['profilePic'],
            'email': userData['email'],
            'isOnline': userData['isOnline'] ?? false,
            'lastSeen': userData['lastSeen'],
          };
        }
      } catch (e) {
        participantData[participantId] = {
          'name': 'Unknown User',
          'profilePic': '',
          'email': '',
          'isOnline': false,
          'lastSeen': DateTime.now().millisecondsSinceEpoch,
        };
      }
    }

    return participantData;
  }

  // جلب عدد الرسائل غير المقروءة في محادثة
  Future<int> getUnreadMessagesCount(String chatRoomId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      final unreadMessages =
          await _firestore
              .collection('chat_rooms')
              .doc(chatRoomId)
              .collection('messages')
              .where('senderId', isNotEqualTo: currentUserId)
              .where('isRead', isEqualTo: false)
              .get();

      return unreadMessages.size;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(
        errorMessage: 'Failed to get unread messages count: $e',
      );
    }
  }

  // تحديث كل الرسائل كمقروءة في محادثة
  Future<void> markAllMessagesAsRead(String chatRoomId) async {
    try {
      final currentUserId = FirebaseAuth.instance.currentUser!.uid;

      final unreadMessages =
          await _firestore
              .collection('chat_rooms')
              .doc(chatRoomId)
              .collection('messages')
              .where('senderId', isNotEqualTo: currentUserId)
              .where('isRead', isEqualTo: false)
              .get();

      final batch = _firestore.batch();

      for (final doc in unreadMessages.docs) {
        batch.update(doc.reference, {'isRead': true});
      }

      await batch.commit();

      // تحديث آخر رسالة كمقروءة أيضاً
      await _firestore.collection('chat_rooms').doc(chatRoomId).update({
        'lastMessage.isRead': true,
      });
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(
        errorMessage: 'Failed to mark all messages as read: $e',
      );
    }
  }
}
