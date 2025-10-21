import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Core/repos/user%20repo/user_repo.dart';
import 'package:chatbox/Core/service/firestore_service.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:dartz/dartz.dart';

class UserRepoImpl implements UserRepo {
  final FirestoreService firestoreService;

  UserRepoImpl({required this.firestoreService});
  @override
  Future<Either<Failure, UserModel>> getUserData(String uid) async {
    try {
      final user = await firestoreService.getUser(uid);
      if (user == null) {
        return Left(FirebaseFailure(errorMessage: 'User data not found.'));
      }
      return Right(user);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to fetch user data.'));
    }
  }

  @override
  Future<Either<Failure, Map<String, UserModel>>> getUsersData(
    List<String> uids,
  ) async {
    try {
      final users = await firestoreService.getUsersByIds(uids);
      return Right(users);
    } on FirebaseFailure catch (e) {
      return Left(e);
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to fetch user data.'));
    }
  }
}
