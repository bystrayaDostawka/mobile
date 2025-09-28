import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/error/failures.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/order_status_entity.dart';
import '../../domain/usecases/get_order_details_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';
import '../../domain/usecases/get_order_statuses_usecase.dart';
import '../../domain/usecases/get_order_photos_usecase.dart';
import '../../domain/usecases/upload_order_photo_usecase.dart';
import '../../domain/usecases/upload_order_photos_usecase.dart';
import '../../domain/usecases/delete_order_photo_usecase.dart';
import '../../domain/usecases/create_courier_note_usecase.dart';
import '../../domain/usecases/update_courier_note_usecase.dart';
import '../../domain/usecases/delete_courier_note_usecase.dart';

/// События для OrderDetailsBloc
abstract class OrderDetailsEvent extends Equatable {
  const OrderDetailsEvent();

  @override
  List<Object?> get props => [];
}

/// Загрузка деталей заказа
class LoadOrderDetails extends OrderDetailsEvent {
  final int orderId;

  const LoadOrderDetails({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

/// Обновление деталей заказа
class RefreshOrderDetails extends OrderDetailsEvent {
  const RefreshOrderDetails();
}

/// Обновление статуса заказа
class UpdateOrderStatus extends OrderDetailsEvent {
  final int orderId;
  final int orderStatusId;
  final String? note;
  final DateTime? deliveryDate;

  const UpdateOrderStatus({
    required this.orderId,
    required this.orderStatusId,
    this.note,
    this.deliveryDate,
  });

  @override
  List<Object?> get props => [orderId, orderStatusId, note, deliveryDate];
}

/// Загрузка статусов заказов
class LoadOrderStatuses extends OrderDetailsEvent {
  const LoadOrderStatuses();
}

/// Загрузка фотографий заказа
class LoadOrderPhotos extends OrderDetailsEvent {
  final int orderId;

  const LoadOrderPhotos({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

/// Загрузка фотографии заказа
class UploadOrderPhoto extends OrderDetailsEvent {
  final int orderId;
  final String photoPath;

  const UploadOrderPhoto({required this.orderId, required this.photoPath});

  @override
  List<Object?> get props => [orderId, photoPath];
}

/// Загрузка нескольких фотографий заказа
class UploadOrderPhotos extends OrderDetailsEvent {
  final int orderId;
  final List<String> photoPaths;

  const UploadOrderPhotos({required this.orderId, required this.photoPaths});

  @override
  List<Object?> get props => [orderId, photoPaths];
}

/// Удаление фотографии заказа
class DeleteOrderPhoto extends OrderDetailsEvent {
  final int orderId;
  final int photoId;

  const DeleteOrderPhoto({required this.orderId, required this.photoId});

  @override
  List<Object?> get props => [orderId, photoId];
}

/// Создание заметки курьера
class CreateCourierNote extends OrderDetailsEvent {
  final int orderId;
  final String courierNote;

  const CreateCourierNote({required this.orderId, required this.courierNote});

  @override
  List<Object?> get props => [orderId, courierNote];
}

/// Обновление заметки курьера
class UpdateCourierNote extends OrderDetailsEvent {
  final int orderId;
  final String courierNote;

  const UpdateCourierNote({required this.orderId, required this.courierNote});

  @override
  List<Object?> get props => [orderId, courierNote];
}

/// Удаление заметки курьера
class DeleteCourierNote extends OrderDetailsEvent {
  final int orderId;

  const DeleteCourierNote({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

/// Состояния для OrderDetailsBloc
abstract class OrderDetailsState extends Equatable {
  const OrderDetailsState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class OrderDetailsInitial extends OrderDetailsState {
  const OrderDetailsInitial();
}

/// Загрузка деталей заказа
class OrderDetailsLoading extends OrderDetailsState {
  const OrderDetailsLoading();
}

/// Успешная загрузка деталей заказа
class OrderDetailsLoaded extends OrderDetailsState {
  final OrderDetailsEntity orderDetails;
  final List<OrderStatusEntity> statuses;

  const OrderDetailsLoaded({
    required this.orderDetails,
    this.statuses = const [],
  });

  @override
  List<Object?> get props => [orderDetails, statuses];
}

/// Обновление статуса заказа
class OrderDetailsUpdating extends OrderDetailsState {
  final OrderDetailsEntity orderDetails;
  final List<OrderStatusEntity> statuses;

  const OrderDetailsUpdating({
    required this.orderDetails,
    required this.statuses,
  });

  @override
  List<Object?> get props => [orderDetails, statuses];
}

/// Ошибка загрузки деталей заказа
class OrderDetailsError extends OrderDetailsState {
  final String message;

  const OrderDetailsError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// Успешное сохранение заметки курьера
class CourierNoteSaved extends OrderDetailsState {
  final OrderDetailsEntity orderDetails;
  final List<OrderStatusEntity> statuses;
  final String message;

  const CourierNoteSaved({
    required this.orderDetails,
    required this.statuses,
    required this.message,
  });

  @override
  List<Object?> get props => [orderDetails, statuses, message];
}

/// Загрузка фотографий заказа
class OrderPhotosLoading extends OrderDetailsState {
  final OrderDetailsEntity orderDetails;
  final List<OrderStatusEntity> statuses;

  const OrderPhotosLoading({
    required this.orderDetails,
    required this.statuses,
  });

  @override
  List<Object?> get props => [orderDetails, statuses];
}

/// Загрузка фотографии заказа
class OrderPhotoUploading extends OrderDetailsState {
  final OrderDetailsEntity orderDetails;
  final List<OrderStatusEntity> statuses;

  const OrderPhotoUploading({
    required this.orderDetails,
    required this.statuses,
  });

  @override
  List<Object?> get props => [orderDetails, statuses];
}

/// BLoC для управления деталями заказа
class OrderDetailsBloc extends Bloc<OrderDetailsEvent, OrderDetailsState> {
  OrderDetailsBloc({
    required this.getOrderDetailsUseCase,
    required this.updateOrderStatusUseCase,
    required this.getOrderStatusesUseCase,
    required this.getOrderPhotosUseCase,
    required this.uploadOrderPhotoUseCase,
    required this.uploadOrderPhotosUseCase,
    required this.deleteOrderPhotoUseCase,
    required this.createCourierNoteUseCase,
    required this.updateCourierNoteUseCase,
    required this.deleteCourierNoteUseCase,
  }) : super(const OrderDetailsInitial()) {
    on<LoadOrderDetails>(_onLoadOrderDetails);
    on<RefreshOrderDetails>(_onRefreshOrderDetails);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<LoadOrderStatuses>(_onLoadOrderStatuses);
    on<LoadOrderPhotos>(_onLoadOrderPhotos);
    on<UploadOrderPhoto>(_onUploadOrderPhoto);
    on<UploadOrderPhotos>(_onUploadOrderPhotos);
    on<DeleteOrderPhoto>(_onDeleteOrderPhoto);
    on<CreateCourierNote>(_onCreateCourierNote);
    on<UpdateCourierNote>(_onUpdateCourierNote);
    on<DeleteCourierNote>(_onDeleteCourierNote);
  }

  final GetOrderDetailsUseCase getOrderDetailsUseCase;
  final UpdateOrderStatusUseCase updateOrderStatusUseCase;
  final GetOrderStatusesUseCase getOrderStatusesUseCase;
  final GetOrderPhotosUseCase getOrderPhotosUseCase;
  final UploadOrderPhotoUseCase uploadOrderPhotoUseCase;
  final UploadOrderPhotosUseCase uploadOrderPhotosUseCase;
  final DeleteOrderPhotoUseCase deleteOrderPhotoUseCase;
  final CreateCourierNoteUseCase createCourierNoteUseCase;
  final UpdateCourierNoteUseCase updateCourierNoteUseCase;
  final DeleteCourierNoteUseCase deleteCourierNoteUseCase;

  /// Загрузка деталей заказа
  Future<void> _onLoadOrderDetails(
    LoadOrderDetails event,
    Emitter<OrderDetailsState> emit,
  ) async {
    print(
      '🔐 OrderDetailsBloc: Начинаем загрузку деталей заказа ${event.orderId}',
    );
    emit(const OrderDetailsLoading());

    try {
      final result = await getOrderDetailsUseCase.call(
        GetOrderDetailsParams(orderId: event.orderId),
      );

      if (result is Success<OrderDetailsEntity>) {
        print('🔐 OrderDetailsBloc: Получены детали заказа ${result.data.id}');

        // Загружаем статусы заказов
        final statusesResult = await getOrderStatusesUseCase.call();
        List<OrderStatusEntity> statuses = [];

        if (statusesResult is Success<List<OrderStatusEntity>>) {
          statuses = statusesResult.data;
        }

        emit(OrderDetailsLoaded(orderDetails: result.data, statuses: statuses));

        // Автоматически загружаем фотографии после успешной загрузки деталей
        add(LoadOrderPhotos(orderId: event.orderId));
      } else if (result is FailureResult<OrderDetailsEntity>) {
        print(
          '🔐 OrderDetailsBloc: Ошибка загрузки деталей заказа: ${result.failure}',
        );
        emit(
          const OrderDetailsError(message: 'Ошибка загрузки деталей заказа'),
        );
      }
    } catch (e) {
      print('🔐 OrderDetailsBloc: Исключение при загрузке деталей заказа: $e');
      emit(const OrderDetailsError(message: 'Ошибка загрузки деталей заказа'));
    }
  }

  /// Обновление деталей заказа
  Future<void> _onRefreshOrderDetails(
    RefreshOrderDetails event,
    Emitter<OrderDetailsState> emit,
  ) async {
    print('🔐 OrderDetailsBloc: Обновляем детали заказа');

    if (state is OrderDetailsLoaded) {
      final currentState = state as OrderDetailsLoaded;
      add(LoadOrderDetails(orderId: currentState.orderDetails.id));
    }
  }

  /// Обновление статуса заказа
  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<OrderDetailsState> emit,
  ) async {
    print('🔐 OrderDetailsBloc: Обновляем статус заказа ${event.orderId}');

    if (state is OrderDetailsLoaded) {
      final currentState = state as OrderDetailsLoaded;

      // Показываем состояние обновления
      emit(
        OrderDetailsUpdating(
          orderDetails: currentState.orderDetails,
          statuses: currentState.statuses,
        ),
      );

      try {
        final result = await updateOrderStatusUseCase.call(
          UpdateOrderStatusParams(
            orderId: event.orderId,
            orderStatusId: event.orderStatusId,
            note: event.note,
            deliveryDate: event.deliveryDate,
          ),
        );

        if (result is Success<OrderDetailsEntity>) {
          print('🔐 OrderDetailsBloc: Статус заказа обновлен');
          emit(
            OrderDetailsLoaded(
              orderDetails: result.data,
              statuses: currentState.statuses,
            ),
          );

          // Перезагружаем фотографии после обновления статуса
          add(LoadOrderPhotos(orderId: event.orderId));
        } else if (result is FailureResult<OrderDetailsEntity>) {
          print(
            '🔐 OrderDetailsBloc: Ошибка обновления статуса: ${result.failure}',
          );
          emit(OrderDetailsError(message: 'Ошибка обновления статуса заказа'));
        }
      } catch (e) {
        print('🔐 OrderDetailsBloc: Исключение при обновлении статуса: $e');
        emit(
          const OrderDetailsError(message: 'Ошибка обновления статуса заказа'),
        );
      }
    }
  }

  /// Загрузка статусов заказов
  Future<void> _onLoadOrderStatuses(
    LoadOrderStatuses event,
    Emitter<OrderDetailsState> emit,
  ) async {
    print('🔐 OrderDetailsBloc: Загружаем статусы заказов');

    try {
      final result = await getOrderStatusesUseCase.call();

      if (result is Success<List<OrderStatusEntity>>) {
        print('🔐 OrderDetailsBloc: Получены статусы заказов');

        if (state is OrderDetailsLoaded) {
          final currentState = state as OrderDetailsLoaded;
          emit(
            OrderDetailsLoaded(
              orderDetails: currentState.orderDetails,
              statuses: result.data,
            ),
          );
        }
      } else if (result is FailureResult<List<OrderStatusEntity>>) {
        print(
          '🔐 OrderDetailsBloc: Ошибка загрузки статусов: ${result.failure}',
        );
        emit(
          const OrderDetailsError(message: 'Ошибка загрузки статусов заказов'),
        );
      }
    } catch (e) {
      print('🔐 OrderDetailsBloc: Исключение при загрузке статусов: $e');
      emit(
        const OrderDetailsError(message: 'Ошибка загрузки статусов заказов'),
      );
    }
  }

  /// Загрузка фотографий заказа
  Future<void> _onLoadOrderPhotos(
    LoadOrderPhotos event,
    Emitter<OrderDetailsState> emit,
  ) async {
    print('🔐 OrderDetailsBloc: Загружаем фотографии заказа ${event.orderId}');

    // Если состояние OrderDetailsLoaded, обновляем фотографии
    if (state is OrderDetailsLoaded) {
      final currentState = state as OrderDetailsLoaded;

      emit(
        OrderPhotosLoading(
          orderDetails: currentState.orderDetails,
          statuses: currentState.statuses,
        ),
      );

      try {
        final result = await getOrderPhotosUseCase.call(
          GetOrderPhotosParams(orderId: event.orderId),
        );

        if (result is Success<List<PhotoEntity>>) {
          print('🔐 OrderDetailsBloc: Получены фотографии заказа');

          // Обновляем заказ с новыми фотографиями
          final updatedOrderDetails = OrderDetailsEntity(
            id: currentState.orderDetails.id,
            bankId: currentState.orderDetails.bankId,
            product: currentState.orderDetails.product,
            name: currentState.orderDetails.name,
            surname: currentState.orderDetails.surname,
            patronymic: currentState.orderDetails.patronymic,
            phone: currentState.orderDetails.phone,
            address: currentState.orderDetails.address,
            orderStatusId: currentState.orderDetails.orderStatusId,
            note: currentState.orderDetails.note,
            declinedReason: currentState.orderDetails.declinedReason,
            deliveryAt: currentState.orderDetails.deliveryAt,
            deliveredAt: currentState.orderDetails.deliveredAt,
            courierId: currentState.orderDetails.courierId,
            createdAt: currentState.orderDetails.createdAt,
            updatedAt: currentState.orderDetails.updatedAt,
            bankName: currentState.orderDetails.bankName,
            courierComment: currentState.orderDetails.courierComment,
            photos: result.data,
          );

          emit(
            OrderDetailsLoaded(
              orderDetails: updatedOrderDetails,
              statuses: currentState.statuses,
            ),
          );
        } else if (result is FailureResult<List<PhotoEntity>>) {
          print(
            '🔐 OrderDetailsBloc: Ошибка загрузки фотографий: ${result.failure}',
          );
          emit(OrderDetailsError(message: 'Ошибка загрузки фотографий'));
        }
      } catch (e) {
        print('🔐 OrderDetailsBloc: Исключение при загрузке фотографий: $e');
        emit(const OrderDetailsError(message: 'Ошибка загрузки фотографий'));
      }
    } else {
      // Если состояние не OrderDetailsLoaded, просто логируем
      print(
        '🔐 OrderDetailsBloc: Пропускаем загрузку фотографий - состояние не OrderDetailsLoaded: ${state.runtimeType}',
      );
    }
  }

  /// Загрузка фотографии заказа
  Future<void> _onUploadOrderPhoto(
    UploadOrderPhoto event,
    Emitter<OrderDetailsState> emit,
  ) async {
    print(
      '🔐 OrderDetailsBloc: Загружаем фотографию для заказа ${event.orderId}',
    );

    if (state is OrderDetailsLoaded) {
      final currentState = state as OrderDetailsLoaded;

      emit(
        OrderPhotoUploading(
          orderDetails: currentState.orderDetails,
          statuses: currentState.statuses,
        ),
      );

      try {
        final result = await uploadOrderPhotoUseCase.call(
          UploadOrderPhotoParams(
            orderId: event.orderId,
            photoPath: event.photoPath,
          ),
        );

        if (result is Success<PhotoEntity>) {
          print('🔐 OrderDetailsBloc: Фотография загружена успешно');

          // Добавляем новую фотографию к существующим
          final updatedPhotos = List<PhotoEntity>.from(
            currentState.orderDetails.photos,
          )..add(result.data);

          // Обновляем заказ с новой фотографией
          final updatedOrderDetails = OrderDetailsEntity(
            id: currentState.orderDetails.id,
            bankId: currentState.orderDetails.bankId,
            product: currentState.orderDetails.product,
            name: currentState.orderDetails.name,
            surname: currentState.orderDetails.surname,
            patronymic: currentState.orderDetails.patronymic,
            phone: currentState.orderDetails.phone,
            address: currentState.orderDetails.address,
            orderStatusId: currentState.orderDetails.orderStatusId,
            note: currentState.orderDetails.note,
            declinedReason: currentState.orderDetails.declinedReason,
            deliveryAt: currentState.orderDetails.deliveryAt,
            deliveredAt: currentState.orderDetails.deliveredAt,
            courierId: currentState.orderDetails.courierId,
            createdAt: currentState.orderDetails.createdAt,
            updatedAt: currentState.orderDetails.updatedAt,
            bankName: currentState.orderDetails.bankName,
            courierComment: currentState.orderDetails.courierComment,
            photos: updatedPhotos,
          );

          emit(
            OrderDetailsLoaded(
              orderDetails: updatedOrderDetails,
              statuses: currentState.statuses,
            ),
          );
        } else if (result is FailureResult<PhotoEntity>) {
          print(
            '🔐 OrderDetailsBloc: Ошибка загрузки фотографии: ${result.failure}',
          );
          final errorMessage = _getUserFriendlyErrorMessage(result.failure);
          emit(OrderDetailsError(message: errorMessage));
        }
      } catch (e) {
        print('🔐 OrderDetailsBloc: Исключение при загрузке фотографии: $e');
        emit(const OrderDetailsError(message: 'Ошибка загрузки фотографии'));
      }
    }
  }

  /// Загрузка нескольких фотографий заказа
  Future<void> _onUploadOrderPhotos(
    UploadOrderPhotos event,
    Emitter<OrderDetailsState> emit,
  ) async {
    print(
      '🔐 OrderDetailsBloc: Загружаем ${event.photoPaths.length} фотографий для заказа ${event.orderId}',
    );

    if (state is OrderDetailsLoaded) {
      final currentState = state as OrderDetailsLoaded;

      emit(
        OrderPhotoUploading(
          orderDetails: currentState.orderDetails,
          statuses: currentState.statuses,
        ),
      );

      try {
        final result = await uploadOrderPhotosUseCase.call(
          UploadOrderPhotosParams(
            orderId: event.orderId,
            photoPaths: event.photoPaths,
          ),
        );

        if (result is Success<List<PhotoEntity>>) {
          print(
            '🔐 OrderDetailsBloc: ${result.data.length} фотографий загружены успешно',
          );

          // Добавляем новые фотографии к существующим
          final updatedPhotos = List<PhotoEntity>.from(
            currentState.orderDetails.photos,
          )..addAll(result.data);

          // Обновляем заказ с новыми фотографиями
          final updatedOrderDetails = OrderDetailsEntity(
            id: currentState.orderDetails.id,
            bankId: currentState.orderDetails.bankId,
            product: currentState.orderDetails.product,
            name: currentState.orderDetails.name,
            surname: currentState.orderDetails.surname,
            patronymic: currentState.orderDetails.patronymic,
            phone: currentState.orderDetails.phone,
            address: currentState.orderDetails.address,
            orderStatusId: currentState.orderDetails.orderStatusId,
            note: currentState.orderDetails.note,
            declinedReason: currentState.orderDetails.declinedReason,
            deliveryAt: currentState.orderDetails.deliveryAt,
            deliveredAt: currentState.orderDetails.deliveredAt,
            courierId: currentState.orderDetails.courierId,
            createdAt: currentState.orderDetails.createdAt,
            updatedAt: currentState.orderDetails.updatedAt,
            bankName: currentState.orderDetails.bankName,
            courierComment: currentState.orderDetails.courierComment,
            photos: updatedPhotos,
          );

          emit(
            OrderDetailsLoaded(
              orderDetails: updatedOrderDetails,
              statuses: currentState.statuses,
            ),
          );
        } else if (result is FailureResult<List<PhotoEntity>>) {
          print(
            '🔐 OrderDetailsBloc: Ошибка загрузки фотографий: ${result.failure}',
          );
          final errorMessage = _getUserFriendlyErrorMessage(result.failure);
          emit(OrderDetailsError(message: errorMessage));
        }
      } catch (e) {
        print('🔐 OrderDetailsBloc: Исключение при загрузке фотографий: $e');
        emit(const OrderDetailsError(message: 'Ошибка загрузки фотографий'));
      }
    }
  }

  /// Удаление фотографии заказа
  Future<void> _onDeleteOrderPhoto(
    DeleteOrderPhoto event,
    Emitter<OrderDetailsState> emit,
  ) async {
    print(
      '🔐 OrderDetailsBloc: Удаляем фотографию ${event.photoId} для заказа ${event.orderId}',
    );

    if (state is OrderDetailsLoaded) {
      final currentState = state as OrderDetailsLoaded;

      try {
        final result = await deleteOrderPhotoUseCase.call(
          DeleteOrderPhotoParams(
            orderId: event.orderId,
            photoId: event.photoId,
          ),
        );

        if (result is Success<void>) {
          print('🔐 OrderDetailsBloc: Фотография удалена успешно');

          // Удаляем фотографию из списка
          final updatedPhotos = currentState.orderDetails.photos
              .where((photo) => photo.id != event.photoId)
              .toList();

          // Обновляем заказ без удаленной фотографии
          final updatedOrderDetails = OrderDetailsEntity(
            id: currentState.orderDetails.id,
            bankId: currentState.orderDetails.bankId,
            product: currentState.orderDetails.product,
            name: currentState.orderDetails.name,
            surname: currentState.orderDetails.surname,
            patronymic: currentState.orderDetails.patronymic,
            phone: currentState.orderDetails.phone,
            address: currentState.orderDetails.address,
            orderStatusId: currentState.orderDetails.orderStatusId,
            note: currentState.orderDetails.note,
            declinedReason: currentState.orderDetails.declinedReason,
            deliveryAt: currentState.orderDetails.deliveryAt,
            createdAt: currentState.orderDetails.createdAt,
            updatedAt: currentState.orderDetails.updatedAt,
            bankName: currentState.orderDetails.bankName,
            courierComment: currentState.orderDetails.courierComment,
            photos: updatedPhotos,
          );

          emit(
            OrderDetailsLoaded(
              orderDetails: updatedOrderDetails,
              statuses: currentState.statuses,
            ),
          );
        } else if (result is FailureResult<void>) {
          print(
            '🔐 OrderDetailsBloc: Ошибка удаления фотографии: ${result.failure}',
          );
          emit(OrderDetailsError(message: 'Ошибка удаления фотографии'));
        }
      } catch (e) {
        print('🔐 OrderDetailsBloc: Исключение при удалении фотографии: $e');
        emit(const OrderDetailsError(message: 'Ошибка удаления фотографии'));
      }
    }
  }

  /// Создание заметки курьера
  Future<void> _onCreateCourierNote(
    CreateCourierNote event,
    Emitter<OrderDetailsState> emit,
  ) async {
    print(
      '🔐 OrderDetailsBloc: Создаем заметку курьера для заказа ${event.orderId}',
    );

    if (state is OrderDetailsLoaded) {
      final currentState = state as OrderDetailsLoaded;

      try {
        final result = await createCourierNoteUseCase.call(
          CreateCourierNoteParams(
            orderId: event.orderId,
            courierNote: event.courierNote,
          ),
        );

        if (result is Success<Map<String, dynamic>>) {
          print('🔐 OrderDetailsBloc: Заметка курьера создана успешно');

          // Обновляем заказ с новой заметкой курьера
          final updatedOrderDetails = OrderDetailsEntity(
            id: currentState.orderDetails.id,
            bankId: currentState.orderDetails.bankId,
            product: currentState.orderDetails.product,
            name: currentState.orderDetails.name,
            surname: currentState.orderDetails.surname,
            patronymic: currentState.orderDetails.patronymic,
            phone: currentState.orderDetails.phone,
            address: currentState.orderDetails.address,
            orderStatusId: currentState.orderDetails.orderStatusId,
            note: currentState.orderDetails.note,
            declinedReason: currentState.orderDetails.declinedReason,
            deliveryAt: currentState.orderDetails.deliveryAt,
            deliveredAt: currentState.orderDetails.deliveredAt,
            courierId: currentState.orderDetails.courierId,
            createdAt: currentState.orderDetails.createdAt,
            updatedAt: currentState.orderDetails.updatedAt,
            bankName: currentState.orderDetails.bankName,
            courierComment: event.courierNote,
            photos: currentState.orderDetails.photos,
          );

          // Сначала показываем уведомление об успешном сохранении
          emit(
            CourierNoteSaved(
              orderDetails: updatedOrderDetails,
              statuses: currentState.statuses,
              message: 'Заметка успешно сохранена',
            ),
          );

          // Затем переходим в обычное состояние загрузки
          emit(
            OrderDetailsLoaded(
              orderDetails: updatedOrderDetails,
              statuses: currentState.statuses,
            ),
          );
        } else if (result is FailureResult<Map<String, dynamic>>) {
          print(
            '🔐 OrderDetailsBloc: Ошибка создания заметки курьера: ${result.failure}',
          );
          final errorMessage = _getUserFriendlyErrorMessage(result.failure);
          emit(OrderDetailsError(message: errorMessage));
        }
      } catch (e) {
        print(
          '🔐 OrderDetailsBloc: Исключение при создании заметки курьера: $e',
        );
        emit(
          const OrderDetailsError(message: 'Ошибка создания заметки курьера'),
        );
      }
    }
  }

  /// Обновление заметки курьера
  Future<void> _onUpdateCourierNote(
    UpdateCourierNote event,
    Emitter<OrderDetailsState> emit,
  ) async {
    print(
      '🔐 OrderDetailsBloc: Обновляем заметку курьера для заказа ${event.orderId}',
    );

    if (state is OrderDetailsLoaded) {
      final currentState = state as OrderDetailsLoaded;

      try {
        final result = await updateCourierNoteUseCase.call(
          UpdateCourierNoteParams(
            orderId: event.orderId,
            courierNote: event.courierNote,
          ),
        );

        if (result is Success<Map<String, dynamic>>) {
          print('🔐 OrderDetailsBloc: Заметка курьера обновлена успешно');

          // Обновляем заказ с обновленной заметкой курьера
          final updatedOrderDetails = OrderDetailsEntity(
            id: currentState.orderDetails.id,
            bankId: currentState.orderDetails.bankId,
            product: currentState.orderDetails.product,
            name: currentState.orderDetails.name,
            surname: currentState.orderDetails.surname,
            patronymic: currentState.orderDetails.patronymic,
            phone: currentState.orderDetails.phone,
            address: currentState.orderDetails.address,
            orderStatusId: currentState.orderDetails.orderStatusId,
            note: currentState.orderDetails.note,
            declinedReason: currentState.orderDetails.declinedReason,
            deliveryAt: currentState.orderDetails.deliveryAt,
            deliveredAt: currentState.orderDetails.deliveredAt,
            courierId: currentState.orderDetails.courierId,
            createdAt: currentState.orderDetails.createdAt,
            updatedAt: currentState.orderDetails.updatedAt,
            bankName: currentState.orderDetails.bankName,
            courierComment: event.courierNote,
            photos: currentState.orderDetails.photos,
          );

          // Сначала показываем уведомление об успешном обновлении
          emit(
            CourierNoteSaved(
              orderDetails: updatedOrderDetails,
              statuses: currentState.statuses,
              message: 'Заметка успешно обновлена',
            ),
          );

          // Затем переходим в обычное состояние загрузки
          emit(
            OrderDetailsLoaded(
              orderDetails: updatedOrderDetails,
              statuses: currentState.statuses,
            ),
          );
        } else if (result is FailureResult<Map<String, dynamic>>) {
          print(
            '🔐 OrderDetailsBloc: Ошибка обновления заметки курьера: ${result.failure}',
          );
          final errorMessage = _getUserFriendlyErrorMessage(result.failure);
          emit(OrderDetailsError(message: errorMessage));
        }
      } catch (e) {
        print(
          '🔐 OrderDetailsBloc: Исключение при обновлении заметки курьера: $e',
        );
        emit(
          const OrderDetailsError(message: 'Ошибка обновления заметки курьера'),
        );
      }
    }
  }

  /// Удаление заметки курьера
  Future<void> _onDeleteCourierNote(
    DeleteCourierNote event,
    Emitter<OrderDetailsState> emit,
  ) async {
    print(
      '🔐 OrderDetailsBloc: Удаляем заметку курьера для заказа ${event.orderId}',
    );

    if (state is OrderDetailsLoaded) {
      final currentState = state as OrderDetailsLoaded;

      try {
        final result = await deleteCourierNoteUseCase.call(
          DeleteCourierNoteParams(orderId: event.orderId),
        );

        if (result is Success<Map<String, dynamic>>) {
          print('🔐 OrderDetailsBloc: Заметка курьера удалена успешно');

          // Обновляем заказ, убирая заметку курьера
          final updatedOrderDetails = OrderDetailsEntity(
            id: currentState.orderDetails.id,
            bankId: currentState.orderDetails.bankId,
            product: currentState.orderDetails.product,
            name: currentState.orderDetails.name,
            surname: currentState.orderDetails.surname,
            patronymic: currentState.orderDetails.patronymic,
            phone: currentState.orderDetails.phone,
            address: currentState.orderDetails.address,
            orderStatusId: currentState.orderDetails.orderStatusId,
            note: currentState.orderDetails.note,
            declinedReason: currentState.orderDetails.declinedReason,
            deliveryAt: currentState.orderDetails.deliveryAt,
            deliveredAt: currentState.orderDetails.deliveredAt,
            courierId: currentState.orderDetails.courierId,
            createdAt: currentState.orderDetails.createdAt,
            updatedAt: currentState.orderDetails.updatedAt,
            bankName: currentState.orderDetails.bankName,
            courierComment: null,
            photos: currentState.orderDetails.photos,
          );

          // Сначала показываем уведомление об успешном удалении
          emit(
            CourierNoteSaved(
              orderDetails: updatedOrderDetails,
              statuses: currentState.statuses,
              message: 'Заметка успешно удалена',
            ),
          );

          // Затем переходим в обычное состояние загрузки
          emit(
            OrderDetailsLoaded(
              orderDetails: updatedOrderDetails,
              statuses: currentState.statuses,
            ),
          );
        } else if (result is FailureResult<Map<String, dynamic>>) {
          print(
            '🔐 OrderDetailsBloc: Ошибка удаления заметки курьера: ${result.failure}',
          );
          final errorMessage = _getUserFriendlyErrorMessage(result.failure);
          emit(OrderDetailsError(message: errorMessage));
        }
      } catch (e) {
        print(
          '🔐 OrderDetailsBloc: Исключение при удалении заметки курьера: $e',
        );
        emit(
          const OrderDetailsError(message: 'Ошибка удаления заметки курьера'),
        );
      }
    }
  }

  /// Преобразование технических ошибок в понятные сообщения для пользователя
  String _getUserFriendlyErrorMessage(Failure failure) {
    if (failure is ServerFailure) {
      final message = failure.message.toLowerCase();

      // Ошибки авторизации
      if (message.contains('unauthorized') ||
          message.contains('не авторизован')) {
        return 'Необходимо войти в систему заново';
      }

      // Ошибки доступа
      if (message.contains('forbidden') ||
          message.contains('доступ запрещен')) {
        return 'У вас нет прав для выполнения этого действия';
      }

      // Ошибки валидации
      if (message.contains('validation') ||
          message.contains('валидация') ||
          message.contains('422') ||
          message.contains('Ошибка валидации')) {
        return 'Проверьте правильность введенных данных';
      }

      // Ошибки конфликта
      if (message.contains('409') ||
          message.contains('конфликт') ||
          message.contains('conflict') ||
          message.contains('Конфликт')) {
        // Извлекаем конкретное сообщение об ошибке
        if (message.contains('Заметка курьера уже существует')) {
          return 'Заметка курьера уже существует';
        }
        return 'Данные уже существуют или конфликтуют';
      }

      // Ошибки сервера
      if (message.contains('500') || message.contains('внутренняя ошибка')) {
        return 'Временная ошибка сервера. Попробуйте позже';
      }

      // Ошибки сети
      if (message.contains('timeout') || message.contains('таймаут')) {
        return 'Превышено время ожидания. Проверьте подключение к интернету';
      }

      // Общая ошибка сервера
      return 'Ошибка сервера. Попробуйте позже';
    }

    if (failure is NetworkFailure) {
      return 'Проверьте подключение к интернету';
    }

    if (failure is AuthFailure) {
      return 'Ошибка авторизации. Войдите в систему заново';
    }

    // Общая ошибка
    return 'Произошла ошибка. Попробуйте позже';
  }
}
