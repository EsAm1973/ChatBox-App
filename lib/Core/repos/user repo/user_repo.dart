import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:dartz/dartz.dart';

abstract class UserRepo {
  Future<Either<Failure, UserModel>> getUserData(String uid);
  Future<Either<Failure, Map<String, UserModel>>> getUsersData(
    List<String> uids,
  );
}
