/// Модель запроса для создания заказа
class CreateOrderRequest {
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

  CreateOrderRequest({
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

  Map<String, dynamic> toJson() {
    return {
      'bank_id': bankId,
      'product': product,
      'name': name,
      'surname': surname,
      'patronymic': patronymic,
      'phone': phone,
      'address': address,
      'delivery_at': _formatDeliveryDate(deliveryDate),
      if (deliveryTimeRange != null) 'delivery_time_range': deliveryTimeRange,
      if (courierId != null) 'courier_id': courierId,
      if (note != null) 'note': note,
    };
  }

  String _formatDeliveryDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }
}
