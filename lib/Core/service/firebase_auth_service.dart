import 'dart:developer';

import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_facebook_auth/flutter_facebook_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

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

      // Send email verification immediately after creating user
      await user.sendEmailVerification();

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
      final user = FirebaseAuth.instance.currentUser;
      if (user != null && user.uid == uid) {
        await user.delete();
        return;
      }
      throw FirebaseFailure(
        errorMessage:
            'Cannot delete account: User not authenticated or UID mismatch',
      );
    } on FirebaseAuthException catch (e) {
      log("Exception in FirebaseAuthServices.deleteUser: $e");
      throw FirebaseFailure.fromFirebaseAuthException(e);
    } catch (e) {
      log("Exception in FirebaseAuthServices.deleteUser: $e");
      throw FirebaseFailure(errorMessage: 'Failed to delete user: $e');
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
        // Only resend verification email if it's been more than 5 minutes since last sent
        // This prevents spamming the user with verification emails
        final metadata = user.metadata;
        final now = DateTime.now();
        final lastSignInTime = metadata.lastSignInTime;

        if (lastSignInTime == null ||
            now.difference(lastSignInTime).inMinutes > 5) {
          await user.sendEmailVerification();
        }

        throw FirebaseFailure(
          errorMessage:
              'Please verify your email. We sent you a verification email.',
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

  // Send verification email to a specific email address
  Future<void> sendEmailVerification({required String email}) async {
    try {
      // Check if user is signed in with this email
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.email == email) {
        // User is already signed in with this email
        await currentUser.sendEmailVerification();
      } else {
        // User is not signed in or signed in with different email
        throw FirebaseFailure(
          errorMessage: 'You must be signed in to request email verification.',
        );
      }
    } on FirebaseAuthException catch (e) {
      log("Exception in FirebaseAuthServices.sendEmailVerification: $e");
      throw FirebaseFailure.fromFirebaseAuthException(e);
    } catch (e) {
      log("Exception in FirebaseAuthServices.sendEmailVerification: $e");
      if (e is Failure) {
        rethrow;
      }
      throw FirebaseFailure(
        errorMessage: 'Failed to send verification email: $e',
      );
    }
  }

  // Check if a user's email is verified
  Future<bool> isEmailVerified({required String email}) async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser != null && currentUser.email == email) {
        // Reload user to get the latest email verification status
        await currentUser.reload();
        return FirebaseAuth.instance.currentUser!.emailVerified;
      } else {
        throw FirebaseFailure(
          errorMessage:
              'You must be signed in to check email verification status.',
        );
      }
    } catch (e) {
      log("Exception in FirebaseAuthServices.isEmailVerified: $e");
      if (e is Failure) {
        rethrow;
      }
      throw FirebaseFailure(
        errorMessage: 'Failed to check email verification status: $e',
      );
    }
  }

  Future<User> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

    // Obtain the auth details from the request
    final GoogleSignInAuthentication? googleAuth =
        await googleUser?.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth?.accessToken,
      idToken: googleAuth?.idToken,
    );

    // Once signed in, return the UserCredential
    return (await FirebaseAuth.instance.signInWithCredential(credential)).user!;
  }

  Future<User> signInWithFacebook() async {
    // Trigger the sign-in flow
    final LoginResult loginResult = await FacebookAuth.instance.login();

    // Create a credential from the access token
    final OAuthCredential facebookAuthCredential =
        FacebookAuthProvider.credential(loginResult.accessToken!.tokenString);

    // Once signed in, return the UserCredential
    return (await FirebaseAuth.instance.signInWithCredential(
      facebookAuthCredential,
    )).user!;
  }

  Future<void> sendPasswordResetEmail({required String email}) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      log("Exception in FirebaseAuthServices.sendPasswordResetEmail: $e");
      throw FirebaseFailure.fromFirebaseAuthException(e);
    } catch (e) {
      log("Exception in FirebaseAuthServices.sendPasswordResetEmail: $e");
      throw FirebaseFailure(
        errorMessage: 'Failed to send password reset email.',
      );
    }
  }
}
