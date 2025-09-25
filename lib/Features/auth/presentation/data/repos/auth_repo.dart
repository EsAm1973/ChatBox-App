import 'dart:io';

import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/auth/presentation/data/models/user_model.dart';
import 'package:dartz/dartz.dart';

abstract class AuthRepo {
  Future<Either<Failure, UserModel>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required File profilePic,
  });

  Future<Either<Failure, UserModel>> signInWithEmailAndPassword({
    required String email,
    required String password,
  });

  Future<Either<Failure, void>> signOut();

  Future<Either<Failure, UserModel>> getCurrentUserData();
}
