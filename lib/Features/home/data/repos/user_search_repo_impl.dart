import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Core/service/firestore_user_service.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:chatbox/Features/home/data/repos/user_search_repo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';

class UserSearchRepoImpl implements SearchUserRepo {
  final FirestoreUserService firestore;

  UserSearchRepoImpl({required this.firestore});

  @override
  Future<Either<Failure, List<UserModel>>> searchUsers(
    String searchQuery,
  ) async {
    try {
      final results = await firestore.searchUsersByEmail(searchQuery);
      return Right(results);
    } on FirebaseException catch (e) {
      return Left(FirebaseFailure.fromFirestoreException(e));
    } catch (e) {
      return Left(FirebaseFailure(errorMessage: 'Failed to search users: $e'));
    }
  }
}
