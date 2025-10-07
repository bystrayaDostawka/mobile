import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../../domain/entities/order_entity.dart';

/// События для BLoC создания заказа
abstract class CreateOrderEvent extends Equatable {
  const CreateOrderEvent();

  @override
  List<Object?> get props => [];
}

/// Событие создания заказа
class CreateOrderRequestEvent extends CreateOrderEvent {
  final int bankId;
  final String product;
  final String name;
  final String surname;
  final String patronymic;
  final String phone;
  final String address;
  final DateTime deliveryDate;
  final String? deliveryTimeRange;
  final int? courierId;
  final String? note;

  const CreateOrderRequestEvent({
    required this.bankId,
    required this.product,
    required this.name,
    required this.surname,
    required this.patronymic,
    required this.phone,
    required this.address,
    required this.deliveryDate,
    this.deliveryTimeRange,
    this.courierId,
    this.note,
  });

  @override
  List<Object?> get props => [
        bankId,
        product,
        name,
        surname,
        patronymic,
        phone,
        address,
        deliveryDate,
        deliveryTimeRange,
        courierId,
        note,
      ];
}

/// Состояния BLoC создания заказа
abstract class CreateOrderState extends Equatable {
  const CreateOrderState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class CreateOrderInitial extends CreateOrderState {}

/// Состояние загрузки
class CreateOrderLoading extends CreateOrderState {}

/// Состояние успешного создания
class CreateOrderSuccess extends CreateOrderState {
  final OrderDetailsEntity order;

  const CreateOrderSuccess(this.order);

  @override
  List<Object?> get props => [order];
}

/// Состояние ошибки
class CreateOrderError extends CreateOrderState {
  final String message;

  const CreateOrderError(this.message);

  @override
  List<Object?> get props => [message];
}

/// Состояние с загруженными данными
class CreateOrderLoaded extends CreateOrderState {
  final List<BankModel> banks;
  final List<CourierModel> couriers;

  const CreateOrderLoaded({
    required this.banks,
    required this.couriers,
  });

  @override
  List<Object?> get props => [banks, couriers];
}

/// BLoC для создания заказа
class CreateOrderBloc extends Bloc<CreateOrderEvent, CreateOrderState> {
  final CreateOrderUseCase createOrderUseCase;

  CreateOrderBloc({
    required this.createOrderUseCase,
  }) : super(CreateOrderInitial()) {
    on<CreateOrderRequestEvent>(_onCreateOrder);
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    // Здесь можно загрузить список банков и курьеров
    // Пока что используем заглушки
    emit(const CreateOrderLoaded(
      banks: [],
      couriers: [],
    ));
  }

  Future<void> _onCreateOrder(
    CreateOrderRequestEvent event,
    Emitter<CreateOrderState> emit,
  ) async {
    emit(CreateOrderLoading());

    try {
      final order = await createOrderUseCase.call(
        CreateOrderParams(
          bankId: event.bankId,
          product: event.product,
          name: event.name,
          surname: event.surname,
          patronymic: event.patronymic,
          phone: event.phone,
          address: event.address,
          deliveryDate: event.deliveryDate,
          deliveryTimeRange: event.deliveryTimeRange,
          courierId: event.courierId,
          note: event.note,
        ),
      );

      emit(CreateOrderSuccess(order));
    } catch (e) {
      emit(CreateOrderError('Произошла ошибка: $e'));
    }
  }
}

/// Модели для банков и курьеров (временные заглушки)
class BankModel {
  final int id;
  final String name;

  const BankModel({
    required this.id,
    required this.name,
  });
}

class CourierModel {
  final int id;
  final String name;

  const CourierModel({
    required this.id,
    required this.name,
  });
}
