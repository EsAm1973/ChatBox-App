import 'dart:developer';

import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseAuthService {
  Future<User> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);
      var user = credential.user!;
      await user.updateDisplayName(displayName);
      await user.reload();
      user = FirebaseAuth.instance.currentUser!;
      return user;
    } on FirebaseAuthException catch (e) {
      log(
        "Exception in FirebaseAuthServices.createUserWithEmailAndPassword: $e",
      );
      throw FirebaseFailure.fromFirebaseAuthException(e);
    } catch (e) {
      log(
        "Exception in FirebaseAuthServices.createUserWithEmailAndPassword: $e",
      );
      throw FirebaseFailure(errorMessage: 'Failed to create user.');
    }
  }
}
