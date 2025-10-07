import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../shared/widgets/time_slot_selector.dart';
import '../../../../shared/widgets/date_picker_field.dart';
import '../../domain/usecases/create_order_usecase.dart';
import '../bloc/create_order_bloc.dart';

/// Страница создания нового заказа
class CreateOrderPage extends StatelessWidget {
  const CreateOrderPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CreateOrderBloc(
        createOrderUseCase: getIt<CreateOrderUseCase>(),
      ),
      child: const _CreateOrderView(),
    );
  }
}

class _CreateOrderView extends StatefulWidget {
  const _CreateOrderView({Key? key}) : super(key: key);

  @override
  State<_CreateOrderView> createState() => _CreateOrderViewState();
}

class _CreateOrderViewState extends State<_CreateOrderView> {
  final _formKey = GlobalKey<FormState>();
  final _productController = TextEditingController();
  final _nameController = TextEditingController();
  final _surnameController = TextEditingController();
  final _patronymicController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _noteController = TextEditingController();

  DateTime? _deliveryDate;
  String? _selectedTimeRange;
  int? _selectedBankId;
  int? _selectedCourierId;

  @override
  void dispose() {
    _productController.dispose();
    _nameController.dispose();
    _surnameController.dispose();
    _patronymicController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Создать заказ'),
        actions: [
          BlocBuilder<CreateOrderBloc, CreateOrderState>(
            builder: (context, state) {
              return IconButton(
                icon: state is CreateOrderLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save),
                onPressed: state is CreateOrderLoading
                    ? null
                    : _createOrder,
              );
            },
          ),
        ],
      ),
      body: BlocListener<CreateOrderBloc, CreateOrderState>(
        listener: (context, state) {
          if (state is CreateOrderSuccess) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Заказ успешно создан'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.of(context).pop(true);
          } else if (state is CreateOrderError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Ошибка: ${state.message}'),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Банк
                _buildBankSelector(),
                const SizedBox(height: 16),

                // Продукт
                _buildTextField(
                  controller: _productController,
                  label: 'Продукт',
                  validator: (value) => value?.isEmpty == true ? 'Введите продукт' : null,
                ),
                const SizedBox(height: 16),

                // ФИО
                Row(
                  children: [
                    Expanded(
                      child: _buildTextField(
                        controller: _surnameController,
                        label: 'Фамилия',
                        validator: (value) => value?.isEmpty == true ? 'Введите фамилию' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        controller: _nameController,
                        label: 'Имя',
                        validator: (value) => value?.isEmpty == true ? 'Введите имя' : null,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildTextField(
                        controller: _patronymicController,
                        label: 'Отчество',
                        validator: (value) => value?.isEmpty == true ? 'Введите отчество' : null,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Телефон
                _buildTextField(
                  controller: _phoneController,
                  label: 'Телефон',
                  keyboardType: TextInputType.phone,
                  validator: (value) => value?.isEmpty == true ? 'Введите телефон' : null,
                ),
                const SizedBox(height: 16),

                // Адрес
                _buildTextField(
                  controller: _addressController,
                  label: 'Адрес',
                  maxLines: 3,
                  validator: (value) => value?.isEmpty == true ? 'Введите адрес' : null,
                ),
                const SizedBox(height: 16),

                // Дата доставки
                DatePickerField(
                  label: 'Дата доставки',
                  selectedDate: _deliveryDate,
                  onDateSelected: (date) {
                    setState(() {
                      _deliveryDate = date;
                    });
                  },
                  validator: (value) => _deliveryDate == null ? 'Выберите дату доставки' : null,
                ),
                const SizedBox(height: 16),

                // Временные слоты
                TimeSlotSelector(
                  selectedTimeRange: _selectedTimeRange,
                  onTimeRangeSelected: (timeRange) {
                    setState(() {
                      _selectedTimeRange = timeRange;
                    });
                  },
                ),
                const SizedBox(height: 16),

                // Отображение выбранного времени
                SelectedDeliveryTimeDisplay(
                  deliveryDate: _deliveryDate,
                  timeRange: _selectedTimeRange,
                ),
                const SizedBox(height: 16),

                // Курьер (опционально)
                _buildCourierSelector(),
                const SizedBox(height: 16),

                // Комментарий
                _buildTextField(
                  controller: _noteController,
                  label: 'Комментарий',
                  maxLines: 3,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      keyboardType: keyboardType,
      maxLines: maxLines,
      validator: validator,
    );
  }

  Widget _buildBankSelector() {
    return BlocBuilder<CreateOrderBloc, CreateOrderState>(
      builder: (context, state) {
        if (state is CreateOrderLoaded) {
          return DropdownButtonFormField<int>(
            value: _selectedBankId,
            decoration: const InputDecoration(
              labelText: 'Банк',
              border: OutlineInputBorder(),
            ),
            items: state.banks.map((bank) {
              return DropdownMenuItem<int>(
                value: bank.id,
                child: Text(bank.name),
              );
            }).toList(),
            onChanged: (value) {
              setState(() {
                _selectedBankId = value;
              });
            },
            validator: (value) => value == null ? 'Выберите банк' : null,
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }

  Widget _buildCourierSelector() {
    return BlocBuilder<CreateOrderBloc, CreateOrderState>(
      builder: (context, state) {
        if (state is CreateOrderLoaded) {
          return DropdownButtonFormField<int>(
            value: _selectedCourierId,
            decoration: const InputDecoration(
              labelText: 'Курьер (опционально)',
              border: OutlineInputBorder(),
            ),
            items: [
              const DropdownMenuItem<int>(
                value: null,
                child: Text('Без курьера'),
              ),
              ...state.couriers.map((courier) {
                return DropdownMenuItem<int>(
                  value: courier.id,
                  child: Text(courier.name),
                );
              }),
            ],
            onChanged: (value) {
              setState(() {
                _selectedCourierId = value;
              });
            },
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  void _createOrder() {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedBankId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите банк'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_deliveryDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Выберите дату доставки'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    context.read<CreateOrderBloc>().add(
      CreateOrderRequestEvent(
        bankId: _selectedBankId!,
        product: _productController.text,
        name: _nameController.text,
        surname: _surnameController.text,
        patronymic: _patronymicController.text,
        phone: _phoneController.text,
        address: _addressController.text,
        deliveryDate: _deliveryDate!,
        deliveryTimeRange: _selectedTimeRange,
        courierId: _selectedCourierId,
        note: _noteController.text.isEmpty ? null : _noteController.text,
      ),
    );
  }
}
