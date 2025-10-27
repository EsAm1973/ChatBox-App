import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Core/repos/user%20repo/user_repo.dart';
import 'package:chatbox/Core/service/firestore_user_service.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:dartz/dartz.dart';

class UserRepoImpl implements UserRepo {
  final FirestoreUserService firestoreUserService;

  UserRepoImpl({required this.firestoreUserService});

  @override
  Future<Either<Failure, Map<String, UserModel>>> getUsersData(
    List<String> uids,
  ) async {
    try {
      final users = await firestoreUserService.getUsersByIds(uids);
      return Right(users);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to fetch users data: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, UserModel>> getUserData(String uid) async {
    try {
      final user = await firestoreUserService.getUser(uid);
      if (user != null) {
        return Right(user);
      } else {
        return Left(FirebaseFailure(errorMessage: 'User not found'));
      }
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to fetch user data: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateUserProfile(UserModel user) async {
    try {
      await firestoreUserService.updateUserProfile(user);
      return const Right(null);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to update user profile: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateProfilePicture(
    String uid,
    String imageUrl,
  ) async {
    try {
      await firestoreUserService.updateProfilePicture(uid, imageUrl);
      return const Right(null);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to update profile picture: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateUserLastSeen(String uid) async {
    try {
      await firestoreUserService.updateUserLastSeen(uid);
      return const Right(null);
    } on FirebaseFailure {
      return const Right(null);
    } catch (e) {
      return const Right(null);
    }
  }

  @override
  Future<Either<Failure, void>> updateUserOnlineStatus(
    String uid,
    bool isOnline,
  ) async {
    try {
      await firestoreUserService.updateUserOnlineStatus(uid, isOnline);
      return const Right(null);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to update online status: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> updateUserAbout(
    String uid,
    String about,
  ) async {
    try {
      await firestoreUserService.updateUserAbout(uid, about);
      return const Right(null);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to update about: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> updateUserPhoneNumber(
    String uid,
    String phoneNumber,
  ) async {
    try {
      await firestoreUserService.updateUserPhoneNumber(uid, phoneNumber);
      return const Right(null);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(
        FirebaseFailure(errorMessage: 'Failed to update phone number: $e'),
      );
    }
  }

  @override
  Future<Either<Failure, void>> deleteUser(String uid) async {
    try {
      await firestoreUserService.deleteUser(uid);
      return const Right(null);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to delete user: $e'));
    }
  }

  @override
  Stream<Either<Failure, UserModel>> getUserStream(String uid) {
    return firestoreUserService
        .getUserStream(uid)
        .map((user) => Right<Failure, UserModel>(user))
        .handleError((error) {
          if (error is FirebaseFailure) {
            return Left<Failure, UserModel>(error);
          } else {
            return Left<Failure, UserModel>(
              FirebaseFailure(errorMessage: 'Stream error: $error'),
            );
          }
        });
  }
}
