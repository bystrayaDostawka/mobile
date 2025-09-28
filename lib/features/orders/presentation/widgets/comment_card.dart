import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/order_comment_entity.dart';

class CommentCard extends StatelessWidget {
  final OrderCommentEntity comment;
  final Function(bool) onToggleStatus;
  final VoidCallback? onTap; // Обработчик клика для перехода к заказу

  const CommentCard({
    super.key,
    required this.comment,
    required this.onToggleStatus,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacing12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: comment.isCompleted ? AppColors.success : AppColors.surfaceVariant,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(AppTheme.spacing16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Информация о заказе
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacing12,
              vertical: AppTheme.spacing8,
            ),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.receipt_long,
                  size: 16,
                  color: AppColors.primary,
                ),
                const SizedBox(width: AppTheme.spacing8),
                Expanded(
                  child: Text(
                    comment.order != null 
                        ? 'Заказ ${comment.order!.orderNumber}'
                        : 'Заказ #${comment.orderId}',
                    style: TextStyle(
                      fontSize: AppFonts.fontSize14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primary,
                    ),
                  ),
                ),
                if (comment.order != null)
                  Text(
                    comment.order!.bankName,
                    style: TextStyle(
                      fontSize: AppFonts.fontSize12,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppTheme.spacing12),
          
          // Заголовок с автором и временем
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          comment.user.name,
                          style: TextStyle(
                            fontSize: AppFonts.fontSize14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const SizedBox(width: AppTheme.spacing8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacing8,
                            vertical: AppTheme.spacing4,
                          ),
                          decoration: BoxDecoration(
                            color: _getRoleColor(comment.user.role).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _getRoleLabel(comment.user.role),
                            style: TextStyle(
                              fontSize: AppFonts.fontSize12,
                              color: _getRoleColor(comment.user.role),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacing4),
                    Text(
                      _formatDateTime(comment.createdAt),
                      style: TextStyle(
                        fontSize: AppFonts.fontSize12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacing12),
          
          // Текст комментария
          Text(
            comment.comment,
            style: TextStyle(
              fontSize: AppFonts.fontSize14,
              color: AppColors.textPrimary,
              height: 1.4,
            ),
          ),
          
          if (comment.isCompleted) ...[
            const SizedBox(height: AppTheme.spacing12),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacing8),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 16,
                  ),
                  const SizedBox(width: AppTheme.spacing8),
                  Text(
                    'Выполнено ${comment.completedAt != null ? _formatDateTime(comment.completedAt!) : ''}',
                    style: TextStyle(
                      fontSize: AppFonts.fontSize12,
                      color: AppColors.success,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
          
          const SizedBox(height: AppTheme.spacing12),
          
          // Чекбокс выполнения
          Row(
            children: [
              Checkbox(
                value: comment.isCompleted,
                onChanged: (value) {
                  if (value != null) {
                    onToggleStatus(value);
                  }
                },
                activeColor: AppColors.success,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                comment.isCompleted ? 'Выполнено' : 'Отметить как выполненное',
                style: TextStyle(
                  fontSize: AppFonts.fontSize14,
                  color: comment.isCompleted ? AppColors.success : AppColors.textSecondary,
                  fontWeight: comment.isCompleted ? FontWeight.w500 : FontWeight.normal,
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

  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'Админ';
      case 'manager':
        return 'Менеджер';
      case 'bank':
        return 'Банк';
      case 'courier':
        return 'Курьер';
      default:
        return role;
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'admin':
        return AppColors.error;
      case 'manager':
        return AppColors.primary;
      case 'bank':
        return AppColors.success;
      case 'courier':
        return AppColors.warning;
      default:
        return Colors.grey;
    }
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${dateTime.day}.${dateTime.month}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}ч назад';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}м назад';
    } else {
      return 'только что';
    }
  }
}
