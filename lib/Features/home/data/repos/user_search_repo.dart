import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:dartz/dartz.dart';

abstract class SearchUserRepo {
  Future<Either<Failure, List<UserModel>>> searchUsers(String query);
}
