import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/usecase/usecase.dart';
import '../../../../core/services/filters_storage_service.dart';
import '../../domain/entities/order_entity.dart';
import '../../domain/entities/sort_order.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/sort_orders_usecase.dart';

/// События для OrdersBloc
abstract class OrdersEvent extends Equatable {
  const OrdersEvent();

  @override
  List<Object?> get props => [];
}

/// Загрузка заявок
class LoadOrders extends OrdersEvent {
  const LoadOrders();
}

/// Обновление фильтров
class UpdateFilters extends OrdersEvent {
  final String? search;
  final int? orderStatusId;
  final List<int>? selectedStatusIds;
  final String? deliveryAt;
  final String? dateFrom;
  final String? dateTo;

  const UpdateFilters({
    this.search,
    this.orderStatusId,
    this.selectedStatusIds,
    this.deliveryAt,
    this.dateFrom,
    this.dateTo,
  });

  @override
  List<Object?> get props => [
    search,
    orderStatusId,
    selectedStatusIds,
    deliveryAt,
    dateFrom,
    dateTo,
  ];
}

/// Очистка фильтров
class ClearFilters extends OrdersEvent {
  const ClearFilters();
}

/// Сортировка заказов
class SortOrders extends OrdersEvent {
  final SortOrder sortOrder;

  const SortOrders({required this.sortOrder});

  @override
  List<Object?> get props => [sortOrder];
}

/// Состояния для OrdersBloc
abstract class OrdersState extends Equatable {
  const OrdersState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class OrdersInitial extends OrdersState {
  const OrdersInitial();
}

/// Загрузка заявок
class OrdersLoading extends OrdersState {
  const OrdersLoading();
}

/// Успешная загрузка заявок
class OrdersLoaded extends OrdersState {
  final List<OrderEntity> orders;
  final String? search;
  final int? orderStatusId;
  final List<int> selectedStatusIds;
  final String? deliveryAt;
  final String? dateFrom;
  final String? dateTo;
  final SortOrder sortOrder;

  const OrdersLoaded({
    required this.orders,
    this.search,
    this.orderStatusId,
    this.selectedStatusIds = const [],
    this.deliveryAt,
    this.dateFrom,
    this.dateTo,
    this.sortOrder = SortOrder.deliveryAtDesc,
  });

  @override
  List<Object?> get props => [
    orders,
    search,
    orderStatusId,
    selectedStatusIds,
    deliveryAt,
    dateFrom,
    dateTo,
    sortOrder,
  ];

  /// Копирование состояния с новыми значениями
  OrdersLoaded copyWith({
    List<OrderEntity>? orders,
    String? search,
    int? orderStatusId,
    List<int>? selectedStatusIds,
    String? deliveryAt,
    String? dateFrom,
    String? dateTo,
    SortOrder? sortOrder,
  }) {
    return OrdersLoaded(
      orders: orders ?? this.orders,
      search: search ?? this.search,
      orderStatusId: orderStatusId ?? this.orderStatusId,
      selectedStatusIds: selectedStatusIds ?? this.selectedStatusIds,
      deliveryAt: deliveryAt ?? this.deliveryAt,
      dateFrom: dateFrom ?? this.dateFrom,
      dateTo: dateTo ?? this.dateTo,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}

/// Ошибка загрузки заявок
class OrdersError extends OrdersState {
  final String message;

  const OrdersError({required this.message});

  @override
  List<Object?> get props => [message];
}

/// BLoC для управления заявками
class OrdersBloc extends Bloc<OrdersEvent, OrdersState> {
  OrdersBloc({
    required this.getOrdersUseCase,
    required this.sortOrdersUseCase,
    required this.courierId,
    required this.filtersStorageService,
  }) : super(const OrdersInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<UpdateFilters>(_onUpdateFilters);
    on<ClearFilters>(_onClearFilters);
    on<SortOrders>(_onSortOrders);
  }

  final GetOrdersUseCase getOrdersUseCase;
  final SortOrdersUseCase sortOrdersUseCase;
  final int courierId;
  final FiltersStorageService filtersStorageService;

  /// Загрузка заявок
  Future<void> _onLoadOrders(
    LoadOrders event,
    Emitter<OrdersState> emit,
  ) async {
    print('🔐 OrdersBloc: Начинаем загрузку заявок');
    emit(const OrdersLoading());

    try {
      // Пытаемся загрузить сохраненные фильтры
      final savedFilters = filtersStorageService.loadFilters();
      
      GetOrdersParams params;
      if (savedFilters != null) {
        // Загружаем с сохраненными фильтрами
        params = GetOrdersParams(
          search: savedFilters['search'],
          orderStatusId: savedFilters['orderStatusId'],
          selectedStatusIds: savedFilters['selectedStatusIds'],
          dateFrom: savedFilters['dateFrom'],
          dateTo: savedFilters['dateTo'],
        );
        print('🔐 OrdersBloc: Загружаем с сохраненными фильтрами');
      } else {
        // Загружаем без фильтров
        params = const GetOrdersParams();
        print('🔐 OrdersBloc: Загружаем без фильтров');
      }

      final result = await getOrdersUseCase.call(params);

      if (result is Success<List<OrderEntity>>) {
        print('🔐 OrdersBloc: Получено ${result.data.length} заявок');

        // Сохраняем текущую сортировку при загрузке
        SortOrder currentSortOrder = SortOrder.deliveryAtDesc;
        if (state is OrdersLoaded) {
          currentSortOrder = (state as OrdersLoaded).sortOrder;
        }

        // Применяем текущую сортировку к загруженным данным
        final sortedOrders = await sortOrdersUseCase.call(
          SortOrdersParams(orders: result.data, sortOrder: currentSortOrder),
        );

        // Создаем состояние с сохраненными фильтрами
        if (savedFilters != null) {
          emit(
            OrdersLoaded(
              orders: sortedOrders,
              sortOrder: currentSortOrder,
              search: savedFilters['search'],
              orderStatusId: savedFilters['orderStatusId'],
              selectedStatusIds: savedFilters['selectedStatusIds'] ?? [],
              dateFrom: savedFilters['dateFrom'],
              dateTo: savedFilters['dateTo'],
            ),
          );
        } else {
          emit(OrdersLoaded(orders: sortedOrders, sortOrder: currentSortOrder));
        }
      } else if (result is FailureResult<List<OrderEntity>>) {
        print('🔐 OrdersBloc: Ошибка загрузки заявок: ${result.failure}');
        emit(OrdersError(message: 'Ошибка загрузки заявок'));
      }
    } catch (e) {
      print('🔐 OrdersBloc: Исключение при загрузке заявок: $e');
      emit(OrdersError(message: 'Ошибка загрузки заявок'));
    }
  }

  /// Обновление фильтров
  Future<void> _onUpdateFilters(
    UpdateFilters event,
    Emitter<OrdersState> emit,
  ) async {
    print('🔐 OrdersBloc: Обновляем фильтры');
    print('🔐 OrdersBloc: orderStatusId: ${event.orderStatusId}');
    print('🔐 OrdersBloc: selectedStatusIds: ${event.selectedStatusIds}');

    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;
      emit(
        currentState.copyWith(
          search: event.search,
          orderStatusId: event.orderStatusId,
          selectedStatusIds: event.selectedStatusIds,
          deliveryAt: event.deliveryAt,
          dateFrom: event.dateFrom,
          dateTo: event.dateTo,
        ),
      );
    }

    // Сохраняем фильтры
    await filtersStorageService.saveFilters(
      search: event.search,
      orderStatusId: event.orderStatusId,
      selectedStatusIds: event.selectedStatusIds,
      dateFrom: event.dateFrom,
      dateTo: event.dateTo,
    );

    // Перезагружаем заявки с новыми фильтрами
    emit(const OrdersLoading());

    try {
      final result = await getOrdersUseCase.call(
        GetOrdersParams(
          search: event.search,
          orderStatusId: event.orderStatusId,
          selectedStatusIds: event.selectedStatusIds,
          deliveryAt: event.deliveryAt,
          dateFrom: event.dateFrom,
          dateTo: event.dateTo,
        ),
      );

      if (result is Success<List<OrderEntity>>) {
        print(
          '🔐 OrdersBloc: Получено ${result.data.length} заявок с фильтрами',
        );
        // Сохраняем текущую сортировку при обновлении фильтров
        SortOrder currentSortOrder = SortOrder.deliveryAtDesc;
        if (state is OrdersLoaded) {
          currentSortOrder = (state as OrdersLoaded).sortOrder;
        }

        // Применяем текущую сортировку к отфильтрованным данным
        final sortedOrders = await sortOrdersUseCase.call(
          SortOrdersParams(orders: result.data, sortOrder: currentSortOrder),
        );

        emit(
          OrdersLoaded(
            orders: sortedOrders,
            search: event.search,
            orderStatusId: event.orderStatusId,
            selectedStatusIds: event.selectedStatusIds ?? [],
            deliveryAt: event.deliveryAt,
            dateFrom: event.dateFrom,
            dateTo: event.dateTo,
            sortOrder: currentSortOrder,
          ),
        );
      } else if (result is FailureResult<List<OrderEntity>>) {
        print(
          '🔐 OrdersBloc: Ошибка загрузки заявок с фильтрами: ${result.failure}',
        );
        emit(OrdersError(message: 'Ошибка загрузки заявок'));
      }
    } catch (e) {
      print('🔐 OrdersBloc: Исключение при загрузке заявок с фильтрами: $e');
      emit(OrdersError(message: 'Ошибка загрузки заявок'));
    }
  }

  /// Очистка фильтров
  Future<void> _onClearFilters(
    ClearFilters event,
    Emitter<OrdersState> emit,
  ) async {
    print('🔐 OrdersBloc: Очищаем фильтры');

    // Очищаем сохраненные фильтры
    await filtersStorageService.clearFilters();

    // Перезагружаем заявки без фильтров
    emit(const OrdersLoading());

    try {
      final result = await getOrdersUseCase.call(const GetOrdersParams());

      if (result is Success<List<OrderEntity>>) {
        print(
          '🔐 OrdersBloc: Получено ${result.data.length} заявок без фильтров',
        );

        // Сохраняем текущую сортировку при очистке фильтров
        SortOrder currentSortOrder = SortOrder.deliveryAtDesc;
        if (state is OrdersLoaded) {
          currentSortOrder = (state as OrdersLoaded).sortOrder;
        }

        // Применяем текущую сортировку к данным без фильтров
        final sortedOrders = await sortOrdersUseCase.call(
          SortOrdersParams(orders: result.data, sortOrder: currentSortOrder),
        );

        emit(OrdersLoaded(orders: sortedOrders, sortOrder: currentSortOrder));
      } else if (result is FailureResult<List<OrderEntity>>) {
        print('🔐 OrdersBloc: Ошибка загрузки заявок: ${result.failure}');
        emit(OrdersError(message: 'Ошибка загрузки заявок'));
      }
    } catch (e) {
      print('🔐 OrdersBloc: Исключение при загрузке заявок: $e');
      emit(OrdersError(message: 'Ошибка загрузки заявок'));
    }
  }

  /// Сортировка заказов
  Future<void> _onSortOrders(
    SortOrders event,
    Emitter<OrdersState> emit,
  ) async {
    print('🔐 OrdersBloc: Сортируем заказы по ${event.sortOrder}');

    if (state is OrdersLoaded) {
      final currentState = state as OrdersLoaded;

      try {
        final sortedOrders = await sortOrdersUseCase.call(
          SortOrdersParams(
            orders: currentState.orders,
            sortOrder: event.sortOrder,
          ),
        );

        emit(
          currentState.copyWith(
            orders: sortedOrders,
            sortOrder: event.sortOrder,
          ),
        );
      } catch (e) {
        print('🔐 OrdersBloc: Ошибка сортировки: $e');
        // В случае ошибки сортировки оставляем текущее состояние
      }
    }
  }
}
