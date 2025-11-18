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
      if (user == null) {
        throw FirebaseFailure(errorMessage: 'User not authenticated');
      }

      // Delete user data from Firestore in a batch
      final batch = _firestore.batch();
      
      // Delete user document
      batch.delete(_firestore.collection(_usersCollection).doc(uid));
      
      // Delete user settings document
      batch.delete(_firestore.collection(_settingsCollection).doc(uid));
      
      // TODO: Delete other user-related data (messages, calls, etc.)
      
      await batch.commit();

      // Delete auth user
      await user.delete();
    } on FirebaseException catch (e) {
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