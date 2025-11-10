import 'package:chatbox/Core/repos/user%20repo/user_repo.dart';
import 'package:chatbox/Core/repos/user%20repo/user_repo_impl.dart';
import 'package:chatbox/Core/service/firebase_auth_service.dart';
import 'package:chatbox/Core/service/firestore_call_service.dart';
import 'package:chatbox/Core/service/firestore_chat_service.dart';
import 'package:chatbox/Core/service/firestore_user_service.dart';
import 'package:chatbox/Core/service/storage_service.dart';
import 'package:chatbox/Core/service/supabase_storage.dart';
import 'package:chatbox/Features/auth/data/repos/auth_repo.dart';
import 'package:chatbox/Features/auth/data/repos/auth_repo_implementation.dart';
import 'package:chatbox/Features/calling/data/repos/call_repo.dart';
import 'package:chatbox/Features/calling/data/repos/call_repo_impl.dart';
import 'package:chatbox/Features/chat/data/repos/chat_repo.dart';
import 'package:chatbox/Features/chat/data/repos/chat_repo_impl.dart';
import 'package:chatbox/Features/home/data/repos/user_search_repo.dart';
import 'package:chatbox/Features/home/data/repos/user_search_repo_impl.dart';
import 'package:get_it/get_it.dart';

final getIt = GetIt.instance;

void setupGetIt() {
  // Services
  getIt.registerSingleton<FirebaseAuthService>(FirebaseAuthService());
  getIt.registerSingleton<FirestoreUserService>(FirestoreUserService());
  getIt.registerSingleton<FirestoreChatService>(FirestoreChatService());
  getIt.registerSingleton<StorageService>(SupabaseStorageService());
  getIt.registerLazySingleton(() => FirestoreCallService());

  getIt.registerSingleton<UserRepo>(
    UserRepoImpl(firestoreUserService: getIt<FirestoreUserService>()),
  );

  getIt.registerSingleton<AuthRepo>(
    AuthRepoImplementation(
      getIt<FirebaseAuthService>(),
      getIt<StorageService>(),
      getIt<FirestoreUserService>(),
    ),
  );

  getIt.registerSingleton<SearchUserRepo>(
    UserSearchRepoImpl(firestore: getIt<FirestoreUserService>()),
  );

  getIt.registerLazySingleton<ChatRepo>(
    () => ChatRepoImpl(
      firestoreChatService: getIt<FirestoreChatService>(),
      storageService: getIt<StorageService>(),
    ),
  );

  getIt.registerLazySingleton<CallRepo>(
    () => CallRepoImpl(firestoreCallService: getIt<FirestoreCallService>()),
  );
}
