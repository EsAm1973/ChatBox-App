import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreUserService {
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
      final userDoc = await _firestore.collection('users').doc(uid).get();
      if (!userDoc.exists) {
        throw FirebaseFailure(
          errorMessage: 'User data not found in Firestore.',
        );
      }
      await _firestore.collection('users').doc(uid).delete();
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

  Future<Map<String, UserModel>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    final uniqueIds = userIds.toSet().toList();
    final usersMap = <String, UserModel>{};

    try {
      final snapshot =
          await _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: uniqueIds)
              .get();

      for (final doc in snapshot.docs) {
        usersMap[doc.id] = UserModel.fromMap({'uid': doc.id, ...doc.data()});
      }

      for (final userId in uniqueIds) {
        if (!usersMap.containsKey(userId)) {
          usersMap[userId] = UserModel(
            uid: userId,
            name: 'User',
            email: '',
            profilePic: 'default_profile_pic_url',
            isOnline: false,
            createdAt: DateTime.now(),
            lastSeen: DateTime.now(),
          );
        }
      }

      return usersMap;
    } catch (e) {
      print('Error getting users batch: $e');
      for (final userId in uniqueIds) {
        usersMap[userId] = UserModel(
          uid: userId,
          name: 'User',
          email: '',
          profilePic: 'default_profile_pic_url',
          isOnline: false,
          createdAt: DateTime.now(),
          lastSeen: DateTime.now(),
        );
      }
      return usersMap;
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
      String query = searchQuery.toLowerCase();
      final querySnapshot =
          await _firestore
              .collection('users')
              .where('email', isGreaterThanOrEqualTo: query)
              .where('email', isLessThanOrEqualTo: '$query\uf8ff')
              .limit(10)
              .get();

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

  Future<void> updateUserProfile(UserModel user) async {
    try {
      await _firestore.collection('users').doc(user.uid).update(user.toMap());
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update user profile.');
    }
  }

  Future<void> updateProfilePicture(String uid, String imageUrl) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'profilePic': imageUrl,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update profile picture.');
    }
  }

  Future<void> updateUserLastSeen(String uid) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } on FirebaseException catch (e) {
      print('Error updating last seen: $e');
    } catch (e) {
      print('Error updating last seen: $e');
    }
  }

  Future<void> updateUserOnlineStatus(String uid, bool isOnline) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'isOnline': isOnline,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update online status.');
    }
  }

  Future<void> updateUserAbout(String uid, String about) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'about': about,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update about.');
    }
  }

  Future<void> updateUserPhoneNumber(String uid, String phoneNumber) async {
    try {
      await _firestore.collection('users').doc(uid).update({
        'phoneNumber': phoneNumber,
        'lastSeen': DateTime.now().millisecondsSinceEpoch,
      });
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update phone number.');
    }
  }

  Stream<UserModel> getUserStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
          if (!snapshot.exists) {
            throw FirebaseFailure(errorMessage: 'User document does not exist');
          }
          return UserModel.fromMap(snapshot.data()!);
        })
        .handleError((error) {
          if (error is FirebaseFailure) {
            throw error;
          } else if (error is FirebaseException) {
            throw FirebaseFailure.fromFirestoreException(error);
          } else {
            throw FirebaseFailure(errorMessage: 'Stream error: $error');
          }
        });
  }
}
