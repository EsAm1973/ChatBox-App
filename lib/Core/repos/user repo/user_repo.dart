import 'package:chatbox/Core/errors/firebase_failures.dart';
import 'package:chatbox/Features/auth/data/models/user_model.dart';
import 'package:dartz/dartz.dart';

abstract class UserRepo {
  Future<Either<Failure, Map<String, UserModel>>> getUsersData(
    List<String> uids,
  );
  Future<Either<Failure, UserModel>> getUserData(String uid);
  Future<Either<Failure, void>> updateUserProfile(UserModel user);
  Future<Either<Failure, void>> updateProfilePicture(
    String uid,
    String imageUrl,
  );
  Future<Either<Failure, void>> updateUserLastSeen(String uid);
  Future<Either<Failure, void>> updateUserOnlineStatus(
    String uid,
    bool isOnline,
  );
  Future<Either<Failure, void>> updateUserAbout(String uid, String about);
  Future<Either<Failure, void>> updateUserPhoneNumber(
    String uid,
    String phoneNumber,
  );
  Future<Either<Failure, void>> deleteUser(String uid);
  Stream<Either<Failure, UserModel>> getUserStream(String uid);
}
