// Add to your services
import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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

  Future<Map<String, UserModel>> getUsersByIds(List<String> userIds) async {
    if (userIds.isEmpty) return {};

    final uniqueIds = userIds.toSet().toList();
    final usersMap = <String, UserModel>{};

    try {
      // نستخدم query where in لجلب جميع المستخدمين في طلب واحد
      final snapshot =
          await _firestore
              .collection('users')
              .where(FieldPath.documentId, whereIn: uniqueIds)
              .get();

      for (final doc in snapshot.docs) {
        usersMap[doc.id] = UserModel.fromMap({'uid': doc.id, ...doc.data()});
      }

      // نملأ المستخدمين غير الموجودين بقيم افتراضية
      for (final userId in uniqueIds) {
        if (!usersMap.containsKey(userId)) {
          usersMap[userId] = UserModel(
            uid: userId,
            name: 'User',
            email: '',
            profilePic: '',
            isOnline: false,
            createdAt: DateTime.now(),
            lastSeen: DateTime.now(),
          );
        }
      }

      return usersMap;
    } catch (e) {
      print('Error getting users batch: $e');
      // في حالة الخطأ، نرجع مستخدمين افتراضيين
      for (final userId in uniqueIds) {
        usersMap[userId] = UserModel(
          uid: userId,
          name: 'User',
          email: '',
          profilePic: '',
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
}
