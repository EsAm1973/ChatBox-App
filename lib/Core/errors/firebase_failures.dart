import 'package:firebase_auth/firebase_auth.dart';

abstract class Failure {
  final String errorMessage;
  Failure({required this.errorMessage});
}

class FirebaseFailure extends Failure {
  FirebaseFailure({required super.errorMessage});

  // Handle Authentication Exceptions
  factory FirebaseFailure.fromFirebaseAuthException(
    FirebaseAuthException exception,
  ) {
    switch (exception.code) {
      case 'invalid-email':
        return FirebaseFailure(errorMessage: 'Invalid email address format');
      case 'user-disabled':
        return FirebaseFailure(
          errorMessage: 'This user account has been disabled',
        );
      case 'user-not-found':
        return FirebaseFailure(errorMessage: 'No user found with this email');
      case 'wrong-password':
        return FirebaseFailure(errorMessage: 'Incorrect password');
      case 'email-already-in-use':
        return FirebaseFailure(
          errorMessage: 'This email is already registered',
        );
      case 'operation-not-allowed':
        return FirebaseFailure(
          errorMessage: 'Email/password accounts are not enabled',
        );
      case 'weak-password':
        return FirebaseFailure(errorMessage: 'Password is too weak');
      case 'too-many-requests':
        return FirebaseFailure(
          errorMessage: 'Too many requests. Try again later',
        );
      case 'network-request-failed':
        return FirebaseFailure(
          errorMessage: 'Network error. Please check your connection',
        );
      default:
        return FirebaseFailure(
          errorMessage: 'Authentication error: ${exception.message}',
        );
    }
  }

  // Handle Firestore Exceptions
  factory FirebaseFailure.fromFirestoreException(FirebaseException exception) {
    switch (exception.code) {
      case 'permission-denied':
        return FirebaseFailure(
          errorMessage: 'You don\'t have permission to access this data',
        );
      case 'not-found':
        return FirebaseFailure(errorMessage: 'Requested document not found');
      case 'already-exists':
        return FirebaseFailure(errorMessage: 'Document already exists');
      case 'resource-exhausted':
        return FirebaseFailure(
          errorMessage: 'Resource exhausted. Try again later',
        );
      case 'unavailable':
        return FirebaseFailure(
          errorMessage: 'Service is temporarily unavailable',
        );
      default:
        return FirebaseFailure(
          errorMessage: 'Firestore error: ${exception.message}',
        );
    }
  }

  // Generic Firebase exception handler
  factory FirebaseFailure.fromException(dynamic exception) {
    if (exception is FirebaseAuthException) {
      return FirebaseFailure.fromFirebaseAuthException(exception);
    } else if (exception is FirebaseException) {
      // Check if it's a Firestore or Storage exception based on the error code patterns
      if (exception.code.contains('firestore')) {
        return FirebaseFailure.fromFirestoreException(exception);
      } else {
        return FirebaseFailure(
          errorMessage: 'Firebase error: ${exception.message}',
        );
      }
    } else {
      return FirebaseFailure(errorMessage: 'An unexpected error occurred');
    }
  }
}
