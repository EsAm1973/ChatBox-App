import 'dart:io';

import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Core/service/firebase_auth_service.dart';
import 'package:chatbox/Core/service/firestore_service.dart';
import 'package:chatbox/Core/service/storage_service.dart';
import 'package:chatbox/Features/auth/presentation/data/models/user_model.dart';
import 'package:chatbox/Features/auth/presentation/data/repos/auth_repo.dart';
import 'package:dartz/dartz.dart';

class AuthRepoImplementation implements AuthRepo {
  final FirebaseAuthService firebaseAuthServices;
  final StorageService storageService;
  final FirestoreService firestoreService;

  AuthRepoImplementation(
    this.firebaseAuthServices,
    this.storageService,
    this.firestoreService,
  );

  @override
  Future<Either<Failure, UserModel>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required File profilePic,
  }) async {
    try {
      // 1. First upload the image to Supabase
      final imageUrl = await storageService.uploadFile(
        profilePic,
        'user-image',
      );

      // 2. Create user in Firebase Auth
      final user = await firebaseAuthServices.createUserWithEmailAndPassword(
        email: email,
        password: password,
        displayName: name,
      );

      // 3. Create UserModel with the image URL
      final userModel = UserModel(
        uid: user.uid,
        name: name,
        email: email,
        profilePic: imageUrl,
        phoneNumber: '',
        about: 'Hey there! I am using ChatBox',
        isOnline: true,
        createdAt: DateTime.now(),
        lastSeen: DateTime.now(),
      );

      // 4. Save user to Firestore
      await firestoreService.saveUser(userModel);

      return Right(userModel);
    } on Failure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'An unexpected error occurred: $e'),
      );
    }
  }
}
