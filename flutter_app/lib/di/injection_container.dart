import 'package:get_it/get_it.dart';
import '../core/network/api_client.dart';
import '../core/network/auth_interceptor.dart';
import '../core/storage/secure_storage.dart';
import '../core/utils/s3_upload_util.dart';
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import '../features/wardrobe/data/datasources/wardrobe_remote_datasource.dart';
import '../features/wardrobe/data/repositories/wardrobe_repository_impl.dart';
import '../features/wardrobe/presentation/bloc/wardrobe_bloc.dart';
import '../features/wardrobe/presentation/bloc/upload_bloc.dart';
import '../features/outfit/data/datasources/outfit_remote_datasource.dart';
import '../features/outfit/data/repositories/outfit_repository_impl.dart';
import '../features/outfit/presentation/bloc/outfit_bloc.dart';
import '../features/tryon/data/datasources/tryon_remote_datasource.dart';
import '../features/tryon/data/repositories/tryon_repository_impl.dart';
import '../features/tryon/presentation/bloc/tryon_bloc.dart';

final sl = GetIt.instance;

Future<void> initDependencies() async {
  // Core
  sl.registerLazySingleton<SecureStorage>(() => SecureStorage());

  sl.registerLazySingleton<AuthInterceptor>(
    () => AuthInterceptor(storage: sl()),
  );

  sl.registerLazySingleton<ApiClient>(
    () => ApiClient(authInterceptor: sl()),
  );

  sl.registerLazySingleton<S3UploadUtil>(
    () => S3UploadUtil(apiClient: sl()),
  );

  // Auth
  sl.registerLazySingleton<AuthRemoteDatasource>(
    () => AuthRemoteDatasource(apiClient: sl()),
  );
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      remoteDatasource: sl(),
      secureStorage: sl(),
    ),
  );
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl()),
  );

  // Wardrobe
  sl.registerLazySingleton<WardrobeRemoteDatasource>(
    () => WardrobeRemoteDatasource(apiClient: sl()),
  );
  sl.registerLazySingleton<WardrobeRepository>(
    () => WardrobeRepository(remoteDatasource: sl()),
  );
  sl.registerFactory<WardrobeBloc>(
    () => WardrobeBloc(repository: sl()),
  );
  sl.registerFactory<UploadBloc>(
    () => UploadBloc(uploadUtil: sl()),
  );

  // Outfit
  sl.registerLazySingleton<OutfitRemoteDatasource>(
    () => OutfitRemoteDatasource(apiClient: sl()),
  );
  sl.registerLazySingleton<OutfitRepository>(
    () => OutfitRepository(remoteDatasource: sl()),
  );
  sl.registerFactory<OutfitBloc>(
    () => OutfitBloc(repository: sl()),
  );

  // Try-On
  sl.registerLazySingleton<TryOnRemoteDatasource>(
    () => TryOnRemoteDatasource(apiClient: sl()),
  );
  sl.registerLazySingleton<TryOnRepository>(
    () => TryOnRepository(remoteDatasource: sl()),
  );
  sl.registerFactory<TryOnBloc>(
    () => TryOnBloc(repository: sl(), uploadUtil: sl()),
  );
}
