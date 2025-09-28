import 'package:bystraya_dostawka/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/profile_response_model.dart';
import '../../data/model/update_profile_request_model.dart';
import '../bloc/profile_bloc.dart';

/// Виджет для редактирования только номера телефона
class PhoneEditWidget extends StatefulWidget {
  const PhoneEditWidget({
    super.key,
    required this.profile,
    required this.onSave,
    required this.onCancel,
  });

  final ProfileResponseModel profile;
  final VoidCallback onSave;
  final VoidCallback onCancel;

  @override
  State<PhoneEditWidget> createState() => _PhoneEditWidgetState();
}

class _PhoneEditWidgetState extends State<PhoneEditWidget> {
  late final TextEditingController _phoneController;
  final _formKey = GlobalKey<FormState>();

  /// Создает поле только для чтения
  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return TextField(
      readOnly: true,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.textSecondary),
        border: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        errorBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.transparent),
        ),
        filled: true,
        fillColor: AppColors.surface,
      ),
      controller: TextEditingController(text: value),
      style: AppTextStyles.h5.copyWith(color: AppColors.textSecondary),
    );
  }

  @override
  void initState() {
    super.initState();
    _phoneController = TextEditingController(text: widget.profile.phone ?? '');
  }

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void _handleSave() {
    if (_formKey.currentState?.validate() == true) {
      // Нормализуем номер телефона
      String normalizedPhone = _normalizePhoneNumber(
        _phoneController.text.trim(),
      );

      final request = UpdateProfileRequestModel(
        name: widget.profile.name, // Сохраняем оригинальное имя
        phone: normalizedPhone,
        note: widget.profile.note?.toString(), // Сохраняем оригинальную заметку
      );

      // Проверяем, есть ли изменения только в телефоне
      if (request.phone != widget.profile.phone) {
        context.read<ProfileBloc>().add(UpdateProfile(request: request));
        widget.onSave();
      } else {
        // Нет изменений, просто закрываем форму
        widget.onCancel();
      }
    }
  }

  /// Нормализует номер телефона к формату +7XXXXXXXXXX
  String _normalizePhoneNumber(String phone) {
    // Очищаем номер от пробелов, дефисов и скобок
    final cleanPhone = phone.replaceAll(RegExp(r'[\s\-\(\)]'), '');

    // Нормализуем номер
    if (cleanPhone.startsWith('8')) {
      return '+7${cleanPhone.substring(1)}';
    } else if (cleanPhone.startsWith('7')) {
      return '+$cleanPhone';
    } else if (cleanPhone.startsWith('+7')) {
      return cleanPhone;
    }

    return phone; // Возвращаем исходный номер, если не удалось нормализовать
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Редактирование телефона',
                      style: AppTextStyles.h5,
                    ),
                  ),
                  IconButton(
                    onPressed: widget.onCancel,
                    icon: const Icon(Icons.close),
                    tooltip: 'Отмена',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Поле Email (только для чтения)
              _buildReadOnlyField(
                label: 'Email',
                value: widget.profile.email ?? 'Не указано',
                icon: Icons.email,
              ),
              const SizedBox(height: 16),

              // Поле имени (только для чтения)
              _buildReadOnlyField(
                label: 'Имя',
                value: widget.profile.name ?? 'Не указано',
                icon: Icons.person,
              ),
              const SizedBox(height: 16),

              // Поле телефона (редактируемое)
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Телефон *',
                  prefixIcon: Icon(Icons.phone, color: AppColors.primary),
                  hintText: '+7 900 123 45 67',
                ),
                keyboardType: TextInputType.phone,
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-\(\)]')),
                ],
                validator: (value) {
                  if (value?.trim().isEmpty == true) {
                    return 'Телефон обязателен для заполнения';
                  }

                  // Очищаем номер от пробелов, дефисов и скобок
                  final cleanPhone = value!.replaceAll(
                    RegExp(r'[\s\-\(\)]'),
                    '',
                  );

                  // Проверяем, что номер начинается с +7 или 7 или 8
                  if (!cleanPhone.startsWith('+7') &&
                      !cleanPhone.startsWith('7') &&
                      !cleanPhone.startsWith('8')) {
                    return 'Номер должен начинаться с +7, 7 или 8';
                  }

                  // Нормализуем номер (приводим к формату +7XXXXXXXXXX)
                  String normalizedPhone = cleanPhone;
                  if (cleanPhone.startsWith('8')) {
                    normalizedPhone = '+7${cleanPhone.substring(1)}';
                  } else if (cleanPhone.startsWith('7')) {
                    normalizedPhone = '+$cleanPhone';
                  }

                  // Проверяем длину номера (должно быть ровно 12 символов: +7XXXXXXXXXX)
                  if (normalizedPhone.length != 12) {
                    return 'Неверная длина номера телефона';
                  }

                  // Проверяем, что после +7 идут только цифры
                  final phoneRegex = RegExp(r'^\+7[0-9]{10}$');
                  if (!phoneRegex.hasMatch(normalizedPhone)) {
                    return 'Неверный формат номера телефона';
                  }

                  // Проверяем, что первая цифра после +7 не равна 0 или 1
                  final firstDigit = normalizedPhone[2];
                  if (firstDigit == '0' || firstDigit == '1') {
                    return 'Первая цифра номера не может быть 0 или 1';
                  }

                  return null;
                },
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 16),

              // Поле роли (только для чтения)
              _buildReadOnlyField(
                label: 'Роль',
                value: 'Курьер',
                icon: Icons.work,
              ),
              const SizedBox(height: 16),

              // Поле статуса (только для чтения)
              _buildReadOnlyField(
                label: 'Статус',
                value: widget.profile.isActive == true
                    ? 'Активен'
                    : 'Неактивен',
                icon: Icons.check_circle,
              ),
              if (widget.profile.note != null) ...[
                const SizedBox(height: 16),
                _buildReadOnlyField(
                  label: 'Заметка',
                  value: widget.profile.note.toString(),
                  icon: Icons.note,
                ),
              ],
              const SizedBox(height: 24),

              // Кнопки действий
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: widget.onCancel,
                      child: const Text('Отмена'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _handleSave,
                      child: const Text('Сохранить'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
