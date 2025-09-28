import 'package:bystraya_dostawka/core/theme/app_fonts.dart';
import 'package:flutter/material.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/model/profile_response_model.dart';
import 'phone_edit_widget.dart';

/// Виджет для отображения информации о пользователе
class ProfileInfoWidget extends StatefulWidget {
  const ProfileInfoWidget({super.key, required this.profile});

  final ProfileResponseModel profile;

  @override
  State<ProfileInfoWidget> createState() => _ProfileInfoWidgetState();
}

class _ProfileInfoWidgetState extends State<ProfileInfoWidget> {
  bool _isEditing = false;

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
        prefixIcon: Icon(icon, color: AppColors.primary),
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
      ),
      controller: TextEditingController(text: value),
      style: AppTextStyles.h5,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isEditing) {
      return PhoneEditWidget(
        profile: widget.profile,
        onSave: () {
          setState(() {
            _isEditing = false;
          });
        },
        onCancel: () {
          setState(() {
            _isEditing = false;
          });
        },
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    'Информация о пользователе',
                    style: AppTextStyles.h5,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  tooltip: 'Редактировать телефон',
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField(
              icon: Icons.person,
              label: 'Имя',
              value: widget.profile.name ?? 'Не указано',
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField(
              icon: Icons.email,
              label: 'Email',
              value: widget.profile.email ?? 'Не указано',
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField(
              icon: Icons.phone,
              label: 'Телефон',
              value: widget.profile.phone ?? 'Не указано',
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField(
              icon: Icons.work,
              label: 'Роль',
              value: 'Курьер',
            ),
            const SizedBox(height: 16),
            _buildReadOnlyField(
              icon: Icons.check_circle,
              label: 'Статус',
              value: widget.profile.isActive == true ? 'Активен' : 'Неактивен',
            ),
            if (widget.profile.note != null) ...[
              const SizedBox(height: 16),
              _buildReadOnlyField(
                icon: Icons.note,
                label: 'Заметка',
                value: widget.profile.note.toString(),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
