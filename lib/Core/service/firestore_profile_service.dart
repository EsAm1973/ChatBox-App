import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/profile/data/models/profile_settings_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreProfileService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collection references
  static const String _usersCollection = 'users';
  static const String _settingsCollection = 'userSettings';

  /// Get user data from Firestore
  Future<UserModel?> getUserData(String uid) async {
    try {
      final doc = await _firestore.collection(_usersCollection).doc(uid).get();
      if (doc.exists) {
        return UserModel.fromMap(doc.data()!);
      }
      return null;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to get user data: $e');
    }
  }

  /// Get user settings from Firestore
  Future<ProfileSettingsModel?> getUserSettings(String uid) async {
    try {
      final doc = await _firestore.collection(_settingsCollection).doc(uid).get();
      if (doc.exists) {
        return ProfileSettingsModel.fromMap(doc.data()!);
      }
      return null;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to get user settings: $e');
    }
  }

  /// Update user name
  Future<UserModel> updateUserName(String uid, String name) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'name': name,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Return updated user data
      final updatedUser = await getUserData(uid);
      if (updatedUser == null) {
        throw FirebaseFailure(errorMessage: 'User not found after update');
      }
      return updatedUser;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update name: $e');
    }
  }

  /// Update user email
  Future<UserModel> updateUserEmail(String uid, String email) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        throw FirebaseFailure(errorMessage: 'User not authenticated');
      }

      // Update email in Firebase Auth (if supported)
      try {
        await user.verifyBeforeUpdateEmail(email);
      } catch (authError) {
        // If direct update fails, we'll still update Firestore
        print('Auth update failed: $authError, updating Firestore only');
      }

      // Update email in Firestore
      await _firestore.collection(_usersCollection).doc(uid).update({
        'email': email,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Return updated user data
      final updatedUser = await getUserData(uid);
      if (updatedUser == null) {
        throw FirebaseFailure(errorMessage: 'User not found after update');
      }
      return updatedUser;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update email: $e');
    }
  }

  /// Update user phone number
  Future<UserModel> updateUserPhoneNumber(String uid, String phoneNumber) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'phoneNumber': phoneNumber,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Return updated user data
      final updatedUser = await getUserData(uid);
      if (updatedUser == null) {
        throw FirebaseFailure(errorMessage: 'User not found after update');
      }
      return updatedUser;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update phone number: $e');
    }
  }

  /// Update user about/bio
  Future<UserModel> updateUserAbout(String uid, String about) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'about': about,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Return updated user data
      final updatedUser = await getUserData(uid);
      if (updatedUser == null) {
        throw FirebaseFailure(errorMessage: 'User not found after update');
      }
      return updatedUser;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update about: $e');
    }
  }

  /// Update profile picture
  Future<UserModel> updateProfilePicture(String uid, String imageUrl) async {
    try {
      await _firestore.collection(_usersCollection).doc(uid).update({
        'profilePic': imageUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Return updated user data
      final updatedUser = await getUserData(uid);
      if (updatedUser == null) {
        throw FirebaseFailure(errorMessage: 'User not found after update');
      }
      return updatedUser;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update profile picture: $e');
    }
  }

  /// Update privacy settings
  Future<ProfileSettingsModel> updatePrivacySettings({
    required String uid,
    bool? lastSeenVisible,
    bool? profilePictureVisible,
    bool? onlineStatusVisible,
  }) async {
    try {
      Map<String, dynamic> updateData = {
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (lastSeenVisible != null) {
        updateData['lastSeenVisible'] = lastSeenVisible;
      }
      if (profilePictureVisible != null) {
        updateData['profilePictureVisible'] = profilePictureVisible;
      }
      if (onlineStatusVisible != null) {
        updateData['onlineStatusVisible'] = onlineStatusVisible;
      }

      await _firestore
          .collection(_settingsCollection)
          .doc(uid)
          .set(updateData, SetOptions(merge: true));

      // Return updated settings
      final updatedSettings = await getUserSettings(uid);
      if (updatedSettings == null) {
        throw FirebaseFailure(errorMessage: 'Settings not found after update');
      }
      return updatedSettings;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update privacy settings: $e');
    }
  }

  /// Update notification settings
  Future<ProfileSettingsModel> updateNotificationSettings({
    required String uid,
    required bool enabled,
  }) async {
    try {
      await _firestore.collection(_settingsCollection).doc(uid).set({
        'notificationsEnabled': enabled,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Return updated settings
      final updatedSettings = await getUserSettings(uid);
      if (updatedSettings == null) {
        throw FirebaseFailure(errorMessage: 'Settings not found after update');
      }
      return updatedSettings;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update notification settings: $e');
    }
  }

  /// Update theme preference
  Future<ProfileSettingsModel> updateThemePreference({
    required String uid,
    required bool darkTheme,
  }) async {
    try {
      await _firestore.collection(_settingsCollection).doc(uid).set({
        'darkTheme': darkTheme,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Return updated settings
      final updatedSettings = await getUserSettings(uid);
      if (updatedSettings == null) {
        throw FirebaseFailure(errorMessage: 'Settings not found after update');
      }
      return updatedSettings;
    } on FirebaseException catch (e) {
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to update theme preference: $e');
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } on FirebaseAuthException catch (e) {
      throw FirebaseFailure.fromFirebaseAuthException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to logout: $e');
    }
  }

  /// Delete user account
  Future<void> deleteAccount(String uid) async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null || user.uid != uid) {
        throw FirebaseFailure(
            errorMessage: 'User not authenticated or UID mismatch');
      }

      // 1. Anonymize user data in Firestore and delete settings
      final userRef = _firestore.collection(_usersCollection).doc(uid);
      final settingsRef = _firestore.collection(_settingsCollection).doc(uid);
      final batch = _firestore.batch();

      // Anonymize the main user document
      batch.update(userRef, {
        'name': 'Deleted Account',
        'email': 'deleted.$uid@chatbox.com', // Unique, non-functional email
        'profilePic': 'assets/deleted_user_icon.svg', // Placeholder asset
        'isDeleted': true,
        'isOnline': false,
        'phoneNumber': null,
        'about': null,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Delete the associated settings document
      batch.delete(settingsRef);

      // Note: We are not iterating through chat_rooms.
      // The UI will handle displaying deleted users based on the `isDeleted` flag.
      // This is more scalable than updating every conversation.

      await batch.commit();

      // 2. Delete the user from Firebase Authentication
      await user.delete();
    } on FirebaseException catch (e) {
      // If the user needs to re-authenticate, this specific error should be handled.
      if (e.code == 'requires-recent-login') {
        throw FirebaseFailure(
            errorMessage:
                'This is a sensitive operation and requires recent authentication. Please log out and log back in before trying again.');
      }
      throw FirebaseFailure.fromFirestoreException(e);
    } catch (e) {
      throw FirebaseFailure(errorMessage: 'Failed to delete account: $e');
    }
  }

  /// Get user stream for real-time updates
  Stream<UserModel?> getUserStream(String uid) {
    return _firestore.collection(_usersCollection).doc(uid).snapshots().map(
      (doc) {
        if (!doc.exists) return null;
        return UserModel.fromMap(doc.data()!);
      },
    );
  }

  /// Get user settings stream for real-time updates
  Stream<ProfileSettingsModel?> getUserSettingsStream(String uid) {
    return _firestore.collection(_settingsCollection).doc(uid).snapshots().map(
      (doc) {
        if (!doc.exists) return null;
        return ProfileSettingsModel.fromMap(doc.data()!);
      },
    );
  }
}