import 'package:chatbox/Core/service/firebase_auth_service.dart';
import 'package:chatbox/Core/service/firestore_service.dart';
import 'package:chatbox/Core/service/storage_service.dart';
import 'package:chatbox/Core/service/supabase_storage.dart';
import 'package:chatbox/Features/auth/data/repos/auth_repo.dart';
import 'package:chatbox/Features/auth/data/repos/auth_repo_implementation.dart';
import 'package:chatbox/Features/home/data/repos/home_repo.dart';
import 'package:chatbox/Features/home/data/repos/home_repo_impl.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  getIt.registerSingleton<FirestoreService>(FirestoreService());
  getIt.registerSingleton<StorageService>(SupabaseStorageService());
  getIt.registerSingleton<AuthRepo>(
    AuthRepoImplementation(
      getIt<FirebaseAuthService>(),
      getIt<StorageService>(),
      getIt<FirestoreService>(),
    ),
  );

  getIt.registerSingleton<HomeRepo>(
    HomeRepoImpl(firestore: getIt<FirestoreService>()),
  );
}
