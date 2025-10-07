// Add to your services
import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/auth/presentation/data/models/user_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        throw FirebaseFailure(errorMessage: 'User data not found in Firestore.');
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
  
  // Helper method to delete user-related data in other collections
  // Uncomment and implement if needed for your app
  /*
  Future<void> _deleteUserRelatedData(String uid) async {
    // Example: Delete user messages
    // final messagesQuery = await _firestore.collection('messages').where('userId', isEqualTo: uid).get();
    // for (var doc in messagesQuery.docs) {
    //   await doc.reference.delete();
    // }
    
    // Add more collection cleanups as needed
  }
  */

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
}
