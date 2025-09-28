import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/filters_storage_service.dart';

import '../repository/repository_interfaces.dart';
import '../network/dio_config.dart';
import '../network/api_client.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/domain/repositories/auth_repository.dart'
    as auth_domain;
import '../../features/orders/data/repositories/orders_repository_impl.dart';
import '../../features/orders/data/datasources/orders_remote_datasource.dart';
import '../../features/orders/domain/repositories/orders_repository.dart'
    as orders_domain;
import '../../features/orders/domain/usecases/get_orders_usecase.dart';
import '../../features/orders/domain/usecases/get_order_details_usecase.dart';
import '../../features/orders/domain/usecases/update_order_status_usecase.dart';
import '../../features/orders/domain/usecases/get_order_statuses_usecase.dart';
import '../../features/orders/domain/usecases/get_order_photos_usecase.dart';
import '../../features/orders/domain/usecases/upload_order_photo_usecase.dart';
import '../../features/orders/domain/usecases/upload_order_photos_usecase.dart';
import '../../features/orders/domain/usecases/delete_order_photo_usecase.dart';
import '../../features/orders/domain/usecases/create_courier_note_usecase.dart';
import '../../features/orders/domain/usecases/update_courier_note_usecase.dart';
import '../../features/orders/domain/usecases/delete_courier_note_usecase.dart';
import '../../features/orders/domain/usecases/sort_orders_usecase.dart';
import '../../features/orders/domain/usecases/get_order_comments_usecase.dart';
import '../../features/orders/domain/usecases/get_courier_comments_usecase.dart';
import '../../features/orders/domain/usecases/create_order_comment_usecase.dart';
import '../../features/orders/domain/usecases/update_order_comment_usecase.dart';
import '../../features/orders/domain/usecases/delete_order_comment_usecase.dart';
import '../../features/profile/data/repositories/profile_repository_impl.dart';
import '../../features/profile/domain/repositories/profile_repository.dart'
    as profile_domain;
import '../../features/profile/domain/usecases/get_profile_usecase.dart';
import '../../features/profile/domain/usecases/update_profile_usecase.dart';

/// Глобальный экземпляр GetIt для DI
final GetIt getIt = GetIt.instance;

/// Конфигурация Dependency Injection
Future<void> configureDependencies() async {
  // Регистрируем внешние зависимости
  getIt.registerLazySingleton<Dio>(() => DioConfig.createDio());
  getIt.registerLazySingleton<ApiClient>(() => ApiClient(getIt<Dio>()));
  getIt.registerLazySingleton<FlutterSecureStorage>(
    () => const FlutterSecureStorage(),
  );
  getIt.registerLazySingletonAsync<SharedPreferences>(
    () => SharedPreferences.getInstance(),
  );

  // Регистрируем datasources
  getIt.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );
  getIt.registerLazySingleton<OrdersRemoteDataSource>(
    () => OrdersRemoteDataSourceImpl(apiClient: getIt<ApiClient>()),
  );

  // Регистрируем репозитории как синглтоны
  getIt.registerLazySingleton<auth_domain.AuthRepository>(
    () => AuthRepositoryImpl(
      remoteDataSource: getIt<AuthRemoteDataSource>(),
      secureStorage: getIt<FlutterSecureStorage>(),
    ),
  );
  getIt.registerLazySingleton<orders_domain.OrdersRepository>(
    () =>
        OrdersRepositoryImpl(remoteDataSource: getIt<OrdersRemoteDataSource>()),
  );
  getIt.registerLazySingleton<profile_domain.ProfileRepository>(
    () => ProfileRepositoryImpl(apiClient: getIt<ApiClient>()),
  );

  // Регистрируем use cases
  getIt.registerLazySingleton<GetOrdersUseCase>(
    () => GetOrdersUseCase(
      ordersRepository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetOrderDetailsUseCase>(
    () => GetOrderDetailsUseCase(
      ordersRepository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateOrderStatusUseCase>(
    () => UpdateOrderStatusUseCase(
      ordersRepository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetOrderStatusesUseCase>(
    () => GetOrderStatusesUseCase(
      ordersRepository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetOrderPhotosUseCase>(
    () => GetOrderPhotosUseCase(
      ordersRepository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<UploadOrderPhotoUseCase>(
    () => UploadOrderPhotoUseCase(
      ordersRepository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<UploadOrderPhotosUseCase>(
    () => UploadOrderPhotosUseCase(
      repository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<DeleteOrderPhotoUseCase>(
    () => DeleteOrderPhotoUseCase(
      repository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<CreateCourierNoteUseCase>(
    () => CreateCourierNoteUseCase(
      ordersRepository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateCourierNoteUseCase>(
    () => UpdateCourierNoteUseCase(
      ordersRepository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<DeleteCourierNoteUseCase>(
    () => DeleteCourierNoteUseCase(
      ordersRepository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<SortOrdersUseCase>(() => SortOrdersUseCase());

  // Use cases для комментариев
  getIt.registerLazySingleton<GetOrderCommentsUseCase>(
    () => GetOrderCommentsUseCase(
      ordersRepository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetCourierCommentsUseCase>(
    () => GetCourierCommentsUseCase(
      ordersRepository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<CreateOrderCommentUseCase>(
    () => CreateOrderCommentUseCase(
      ordersRepository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateOrderCommentUseCase>(
    () => UpdateOrderCommentUseCase(
      ordersRepository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<DeleteOrderCommentUseCase>(
    () => DeleteOrderCommentUseCase(
      ordersRepository: getIt<orders_domain.OrdersRepository>(),
    ),
  );

  getIt.registerLazySingleton<GetProfileUseCase>(
    () => GetProfileUseCase(
      profileRepository: getIt<profile_domain.ProfileRepository>(),
    ),
  );

  getIt.registerLazySingleton<UpdateProfileUseCase>(
    () => UpdateProfileUseCase(
      profileRepository: getIt<profile_domain.ProfileRepository>(),
    ),
  );

  getIt.registerLazySingleton<NotificationsRepository>(
    () => throw UnimplementedError('NotificationsRepository not implemented'),
  );

  getIt.registerLazySingleton<ProfileRepository>(
    () => throw UnimplementedError('ProfileRepository not implemented'),
  );

  // Сервисы
  getIt.registerLazySingletonAsync<FiltersStorageService>(
    () async => FiltersStorageService(await getIt.getAsync<SharedPreferences>()),
  );
}
