import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_fonts.dart';

/// Виджет для ввода комментария курьера
class CourierCommentWidget extends StatefulWidget {
  const CourierCommentWidget({
    super.key,
    this.initialComment,
    this.onCommentChanged,
    this.onSaveComment,
    this.onDeleteComment,
    this.readOnly = false,
    this.hintText = 'Добавить заметку...',
    this.showSaveButton = false,
  });

  final String? initialComment;
  final ValueChanged<String>? onCommentChanged;
  final VoidCallback? onSaveComment;
  final VoidCallback? onDeleteComment;
  final bool readOnly;
  final String hintText;
  final bool showSaveButton;

  @override
  State<CourierCommentWidget> createState() => _CourierCommentWidgetState();
}

class _CourierCommentWidgetState extends State<CourierCommentWidget> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialComment ?? '');
    _focusNode = FocusNode();
  }

  @override
  void didUpdateWidget(CourierCommentWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Обновляем контроллер при изменении initialComment
    if (oldWidget.initialComment != widget.initialComment) {
      _controller.text = widget.initialComment ?? '';
      setState(() {
        _hasChanges = false;
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.message_outlined, size: 16, color: AppColors.textHint),
            const SizedBox(width: 8),
            Text(
              'Комментарий',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            const Spacer(),
            // Показываем кнопку "Удалить" если есть заметка
            if (widget.initialComment != null &&
                widget.initialComment!.isNotEmpty &&
                widget.onDeleteComment != null)
              TextButton(
                onPressed: widget.onDeleteComment,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.error,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Удалить'),
              )
            // Показываем кнопку "Сохранить" если нет заметки и есть изменения
            else if (widget.showSaveButton &&
                !widget.readOnly &&
                _hasChanges &&
                widget.onSaveComment != null)
              TextButton(
                onPressed: widget.onSaveComment,
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text('Сохранить'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _controller,
          focusNode: _focusNode,
          readOnly:
              widget.readOnly ||
              (widget.initialComment != null &&
                  widget.initialComment!.isNotEmpty),
          maxLines: 3,
          maxLength: 500,
          textCapitalization: TextCapitalization.sentences,
          decoration: InputDecoration(
            hintText: widget.readOnly && _controller.text.isEmpty
                ? 'Заметка не добавлена'
                : widget.hintText,
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textHint,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.border, width: 1),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: widget.readOnly ? AppColors.border : AppColors.border,
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor:
                (widget.readOnly ||
                    (widget.initialComment != null &&
                        widget.initialComment!.isNotEmpty))
                ? AppColors.surfaceVariant
                : AppColors.surface,
            contentPadding: const EdgeInsets.all(12),
            counterStyle: AppTextStyles.caption.copyWith(
              color: AppColors.textHint,
            ),
          ),
          style: AppTextStyles.bodyMedium,
          onChanged: (value) {
            setState(() {
              _hasChanges = value != (widget.initialComment ?? '');
            });
            widget.onCommentChanged?.call(value);
          },
        ),
      ],
    );
  }
}
