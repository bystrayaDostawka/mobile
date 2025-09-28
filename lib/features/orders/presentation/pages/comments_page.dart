import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/constants/app_constants.dart';
import '../bloc/courier_comments_bloc.dart';
import '../bloc/pending_tasks_count_bloc.dart';
import '../widgets/comment_card.dart';
import '../enums/comment_filter_status.dart';

class CommentsPage extends StatefulWidget {
  const CommentsPage({super.key});

  @override
  State<CommentsPage> createState() => _CommentsPageState();
}

class _CommentsPageState extends State<CommentsPage> {
  CommentFilterStatus _selectedFilter = CommentFilterStatus.all;

  @override
  void initState() {
    super.initState();
    context.read<CourierCommentsBloc>().add(const LoadCourierComments());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Обновляем счетчик невыполненных задач после того, как все провайдеры инициализированы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<PendingTasksCountBloc>().add(const RefreshPendingTasksCount());
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: BlocBuilder<CourierCommentsBloc, CourierCommentsState>(
          builder: (context, state) {
            if (state is CourierCommentsLoaded) {
              final filteredComments = _filterComments(state.comments);
              final totalComments = state.comments.length;
              
              String title = 'Мои комментарии';
              if (_selectedFilter != CommentFilterStatus.all) {
                title = '${filteredComments.length} из $totalComments';
              }
              
              return Text(title);
            }
            return const Text('Мои комментарии');
          },
        ),
        centerTitle: true,
        actions: [
          Stack(
            children: [
              IconButton(
                icon: Icon(
                  Icons.filter_list,
                  color: _selectedFilter != CommentFilterStatus.all ? AppColors.primary : null,
                ),
                onPressed: _showFilterModal,
                tooltip: 'Фильтр комментариев',
              ),
              if (_selectedFilter != CommentFilterStatus.all)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<CourierCommentsBloc>().add(const RefreshCourierComments());
          // Обновляем счетчик невыполненных задач
          if (context.mounted) {
            context.read<PendingTasksCountBloc>().add(const RefreshPendingTasksCount());
          }
        },
        child: BlocBuilder<CourierCommentsBloc, CourierCommentsState>(
          builder: (context, state) {
            if (state is CourierCommentsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is CourierCommentsLoaded) {
              if (state.comments.isEmpty) {
                return _buildEmptyState();
              }
              
              // Фильтруем комментарии по выбранному статусу
              final filteredComments = _filterComments(state.comments);
              
              if (filteredComments.isEmpty) {
                return _buildEmptyFilterState();
              }
              
              return _buildCommentsList(filteredComments);
            } else if (state is CourierCommentsError) {
              return _buildErrorState(state.message);
            }
            return _buildEmptyState();
          },
        ),
      ),
    );
  }

  Widget _buildCommentsList(List<dynamic> comments) {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: comments.length,
      itemBuilder: (context, index) {
        final comment = comments[index];
        return CommentCard(
          comment: comment,
          onToggleStatus: (isCompleted) {
            // Используем orderId который всегда доступен
            context.read<CourierCommentsBloc>().add(
              UpdateCommentStatus(
                comment.orderId,
                comment.id,
                isCompleted,
              ),
            );
            // Обновляем счетчик невыполненных задач
            if (context.mounted) {
              context.read<PendingTasksCountBloc>().add(const RefreshPendingTasksCount());
            }
          },
          onTap: () {
            // Переходим к деталям заказа при клике на комментарий
            // Используем order.id если доступен, иначе orderId
            final orderId = comment.order?.id ?? comment.orderId;
            context.go(AppRoutes.orderDetails.replaceAll(':id', orderId.toString()));
          },
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Container(
        height: MediaQuery.of(context).size.height - 
                MediaQuery.of(context).padding.top - 
                kToolbarHeight,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.comment_outlined,
                size: 64,
                color: Colors.grey.shade400,
              ),
              const SizedBox(height: 16),
              Text(
                'Комментариев пока нет',
                style: TextStyle(
                  fontSize: AppFonts.fontSize18,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Комментарии появятся здесь, когда\nадминистратор добавит их к вашим заказам',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppFonts.fontSize14,
                  color: Colors.grey.shade500,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Потяните вниз для обновления',
                style: TextStyle(
                  fontSize: AppFonts.fontSize12,
                  color: Colors.grey.shade400,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: Colors.red,
          ),
          const SizedBox(height: 16),
          Text(
            'Ошибка загрузки комментариев',
            style: TextStyle(
              fontSize: AppFonts.fontSize16,
              color: Colors.red,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            message,
            style: TextStyle(
              fontSize: AppFonts.fontSize14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              context.read<CourierCommentsBloc>().add(const LoadCourierComments());
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

  /// Показать модальное окно с фильтрами
  void _showFilterModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Заголовок
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, color: AppColors.primary),
                  const SizedBox(width: 12),
                  const Text(
                    'Фильтр комментариев',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
            ),
            
            // Опции фильтра
            ...CommentFilterStatus.values.map((status) => ListTile(
              leading: Radio<CommentFilterStatus>(
                value: status,
                groupValue: _selectedFilter,
                onChanged: (value) {
                  setState(() {
                    _selectedFilter = value!;
                  });
                  Navigator.pop(context);
                },
                activeColor: AppColors.primary,
              ),
              title: Text(
                status.displayName,
                style: TextStyle(
                  color: _selectedFilter == status 
                      ? AppColors.primary 
                      : AppColors.textPrimary,
                  fontWeight: _selectedFilter == status 
                      ? FontWeight.w600 
                      : FontWeight.normal,
                ),
              ),
              onTap: () {
                setState(() {
                  _selectedFilter = status;
                });
                Navigator.pop(context);
              },
            )),
            
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Фильтровать комментарии по выбранному статусу
  List<dynamic> _filterComments(List<dynamic> comments) {
    switch (_selectedFilter) {
      case CommentFilterStatus.completed:
        return comments.where((comment) => comment.isCompleted).toList();
      case CommentFilterStatus.pending:
        return comments.where((comment) => !comment.isCompleted).toList();
      case CommentFilterStatus.all:
        return comments;
    }
  }

  /// Построить состояние "пустой фильтр"
  Widget _buildEmptyFilterState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            _getFilterIcon(),
            size: 64,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text(
            _getEmptyFilterMessage(),
            style: TextStyle(
              fontSize: AppFonts.fontSize16,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Попробуйте выбрать другой фильтр',
            style: TextStyle(
              fontSize: AppFonts.fontSize14,
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton.icon(
            onPressed: () {
              setState(() {
                _selectedFilter = CommentFilterStatus.all;
              });
            },
            icon: const Icon(Icons.clear),
            label: const Text('Сбросить фильтр'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Получить иконку для фильтра
  IconData _getFilterIcon() {
    switch (_selectedFilter) {
      case CommentFilterStatus.completed:
        return Icons.check_circle_outline;
      case CommentFilterStatus.pending:
        return Icons.pending_outlined;
      case CommentFilterStatus.all:
        return Icons.comment_outlined;
    }
  }

  /// Получить сообщение для пустого фильтра
  String _getEmptyFilterMessage() {
    switch (_selectedFilter) {
      case CommentFilterStatus.completed:
        return 'Нет выполненных комментариев';
      case CommentFilterStatus.pending:
        return 'Нет невыполненных комментариев';
      case CommentFilterStatus.all:
        return 'Комментариев пока нет';
    }
  }

}
