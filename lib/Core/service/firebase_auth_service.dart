import 'dart:developer';

import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  Future<User> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    User? user;
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      user = credential.user!;
      await user.updateDisplayName(displayName);
      await user.reload();
      user = FirebaseAuth.instance.currentUser!;
      return user;
    } on FirebaseAuthException catch (e) {
      log(
        "Exception in FirebaseAuthServices.createUserWithEmailAndPassword: $e",
      );

      // If we created a user but then failed, delete the user
      if (user != null) {
        try {
          await user.delete();
        } catch (deleteError) {
          log("Failed to delete user during rollback: $deleteError");
        }
      }

      throw FirebaseFailure.fromFirebaseAuthException(e);
    } catch (e) {
      log(
        "Exception in FirebaseAuthServices.createUserWithEmailAndPassword: $e",
      );

      // If we created a user but then failed, delete the user
      if (user != null) {
        try {
          await user.delete();
        } catch (deleteError) {
          log("Failed to delete user during rollback: $deleteError");
        }
      }

      throw FirebaseFailure(errorMessage: 'Failed to create user.');
    }
  }

  Future<void> deleteUser(String uid) async {
    try {
      // Note: This requires admin privileges or custom claims
      // For production, you might need to use a Cloud Function
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid == uid) {
        await user.delete();
      }
    } catch (e) {
      throw Exception('Failed to delete user: $e');
    }
  }

  Future<User> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = credential.user!;
      if (!user.emailVerified) {
        await user.sendEmailVerification();
        throw FirebaseFailure(
          errorMessage:
              'Please verify your email, We sent you a verification email.',
        );
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw FirebaseFailure.fromFirebaseAuthException(e);
    } catch (e) {
      log("Exception in FirebaseAuthServices.signInWithEmailAndPassword: $e");
      if (e is Failure) {
        // Preserve the specific failure message (e.g., email not verified)
        rethrow;
      }
      throw FirebaseFailure(errorMessage: 'Failed to sign in: $e');
    }
  }

  Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      log("Exception in FirebaseAuthServices.signOut: $e");
      throw FirebaseFailure(errorMessage: 'Failed to sign out.');
    }
  }
}
