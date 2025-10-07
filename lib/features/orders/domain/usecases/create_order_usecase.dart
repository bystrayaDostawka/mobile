import '../../../../core/usecase/usecase.dart';
import '../entities/order_entity.dart';
import '../repositories/orders_repository.dart';

/// Usecase для создания заказа
class CreateOrderUseCase implements UseCase<OrderDetailsEntity, CreateOrderParams> {
  final OrdersRepository repository;

  CreateOrderUseCase(this.repository);

  @override
  Future<OrderDetailsEntity> call(CreateOrderParams params) async {
    final result = await repository.createOrder(
      bankId: params.bankId,
      product: params.product,
      name: params.name,
      surname: params.surname,
      patronymic: params.patronymic,
      phone: params.phone,
      address: params.address,
      deliveryDate: params.deliveryDate,
      deliveryTimeRange: params.deliveryTimeRange,
      courierId: params.courierId,
      note: params.note,
    );

    if (result.isSuccess) {
      return result.data!;
    } else {
      throw Exception(result.failure!.message);
    }
  }
}

/// Параметры для создания заказа
class CreateOrderParams {
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

  CreateOrderParams({
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
}
