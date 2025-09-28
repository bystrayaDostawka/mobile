import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/constants/app_constants.dart';
import '../bloc/order_comments_bloc.dart';
import '../bloc/order_comments_count_bloc.dart';
import '../widgets/comment_card.dart';

class OrderCommentsPage extends StatefulWidget {
  final int orderId;
  final String orderNumber;

  const OrderCommentsPage({
    super.key,
    required this.orderId,
    required this.orderNumber,
  });

  @override
  State<OrderCommentsPage> createState() => _OrderCommentsPageState();
}

class _OrderCommentsPageState extends State<OrderCommentsPage> {
  @override
  void initState() {
    super.initState();
    context.read<OrderCommentsBloc>().add(LoadOrderComments(widget.orderId));
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Обновляем счетчик комментариев после того, как все провайдеры инициализированы
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<OrderCommentsCountBloc>().add(
          RefreshOrderCommentsCount(orderId: widget.orderId),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Комментарии к заказу #${widget.orderNumber}'),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(AppRoutes.orderDetails.replaceAll(':id', widget.orderId.toString())),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          context.read<OrderCommentsBloc>().add(RefreshOrderComments(widget.orderId));
          // Обновляем счетчик комментариев
          if (context.mounted) {
            context.read<OrderCommentsCountBloc>().add(
              RefreshOrderCommentsCount(orderId: widget.orderId),
            );
          }
        },
        child: BlocBuilder<OrderCommentsBloc, OrderCommentsState>(
                builder: (context, state) {
                  if (state is OrderCommentsLoading) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (state is OrderCommentsLoaded) {
                    if (state.comments.isEmpty) {
                      return _buildEmptyState();
                    }
                    return ListView.builder(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(AppTheme.spacing16),
                      itemCount: state.comments.length,
                      itemBuilder: (context, index) {
                        final comment = state.comments[index];
                        return CommentCard(
                          comment: comment,
                          onToggleStatus: (isCompleted) {
                            context.read<OrderCommentsBloc>().add(
                              UpdateCommentStatus(
                                widget.orderId,
                                comment.id,
                                isCompleted,
                              ),
                            );
                            // Обновляем счетчик комментариев
                            if (context.mounted) {
                              context.read<OrderCommentsCountBloc>().add(
                                RefreshOrderCommentsCount(orderId: widget.orderId),
                              );
                            }
                          },
                        );
                      },
                    );
                  } else if (state is OrderCommentsError) {
                    return _buildErrorState(state.message);
                  }
                  return const SizedBox.shrink();
                },
        ),
      ),
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
                color: Colors.grey,
              ),
              const SizedBox(height: AppTheme.spacing16),
              Text(
                'Комментариев пока нет',
                style: TextStyle(
                  fontSize: AppFonts.fontSize16,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: AppTheme.spacing8),
              Text(
                'Потяните вниз для обновления',
                style: TextStyle(
                  fontSize: AppFonts.fontSize14,
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
          Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: AppTheme.spacing16),
          Text(
            'Ошибка загрузки комментариев',
            style: TextStyle(
              fontSize: AppFonts.fontSize16,
              color: AppColors.error,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacing8),
          Text(
            message,
            style: TextStyle(
              fontSize: AppFonts.fontSize14,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacing16),
          ElevatedButton(
            onPressed: () {
              context.read<OrderCommentsBloc>().add(LoadOrderComments(widget.orderId));
            },
            child: const Text('Повторить'),
          ),
        ],
      ),
    );
  }

}
