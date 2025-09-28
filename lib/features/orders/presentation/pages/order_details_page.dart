import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_fonts.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../domain/usecases/get_order_details_usecase.dart';
import '../../domain/usecases/update_order_status_usecase.dart';
import '../../domain/usecases/get_order_statuses_usecase.dart';
import '../../domain/usecases/get_order_photos_usecase.dart';
import '../../domain/usecases/upload_order_photo_usecase.dart';
import '../../domain/usecases/upload_order_photos_usecase.dart';
import '../../domain/usecases/delete_order_photo_usecase.dart';
import '../../domain/usecases/create_courier_note_usecase.dart';
import '../../domain/usecases/update_courier_note_usecase.dart';
import '../../domain/usecases/delete_courier_note_usecase.dart';
import '../../domain/usecases/get_order_comments_usecase.dart';
import '../bloc/order_details_bloc.dart';
import '../bloc/order_comments_count_bloc.dart';
import '../widgets/order_details_content.dart';
import '../widgets/order_details/order_actions_bar.dart';
import '../widgets/badge_icon.dart';

/// Страница с деталями заказа
class OrderDetailsPage extends StatelessWidget {
  const OrderDetailsPage({super.key, required this.orderId});

  final int orderId;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => OrderDetailsBloc(
              getOrderDetailsUseCase: getIt<GetOrderDetailsUseCase>(),
              updateOrderStatusUseCase: getIt<UpdateOrderStatusUseCase>(),
              getOrderStatusesUseCase: getIt<GetOrderStatusesUseCase>(),
              getOrderPhotosUseCase: getIt<GetOrderPhotosUseCase>(),
              uploadOrderPhotoUseCase: getIt<UploadOrderPhotoUseCase>(),
              uploadOrderPhotosUseCase: getIt<UploadOrderPhotosUseCase>(),
              deleteOrderPhotoUseCase: getIt<DeleteOrderPhotoUseCase>(),
              createCourierNoteUseCase: getIt<CreateCourierNoteUseCase>(),
              updateCourierNoteUseCase: getIt<UpdateCourierNoteUseCase>(),
              deleteCourierNoteUseCase: getIt<DeleteCourierNoteUseCase>(),
            )..add(LoadOrderDetails(orderId: orderId)),
        ),
        BlocProvider(
          create: (context) => OrderCommentsCountBloc(
            getOrderCommentsUseCase: getIt<GetOrderCommentsUseCase>(),
          )..add(LoadOrderCommentsCount(orderId: orderId)),
        ),
      ],
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Детали заказа #$orderId'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              context.go(AppRoutes.orders);
            },
            tooltip: 'Назад к списку заявок',
          ),
          actions: [
            BlocBuilder<OrderCommentsCountBloc, OrderCommentsCountState>(
              builder: (context, state) {
                int pendingCount = 0;
                
                if (state is OrderCommentsCountLoaded) {
                  pendingCount = state.pendingCount;
                }
                
                return IconButton(
                  onPressed: () {
                    context.go(
                      AppRoutes.orderComments.replaceAll(':id', orderId.toString()),
                      extra: {'orderNumber': orderId.toString()},
                    );
                    // Обновляем счетчик при переходе на страницу комментариев
                    context.read<OrderCommentsCountBloc>().add(
                      RefreshOrderCommentsCount(orderId: orderId),
                    );
                  },
                  icon: BadgeIcon(
                    icon: Icons.comment_outlined,
                    count: pendingCount,
                  ),
                  tooltip: 'Комментарии',
                );
              },
            ),
          ],
        ),
        body: BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
          builder: (context, state) {
            if (state is OrderDetailsLoading) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              );
            } else if (state is OrderDetailsLoaded) {
              return OrderDetailsContent(
                orderDetails: state.orderDetails,
                statuses: state.statuses,
                orderDetailsBloc: context.read<OrderDetailsBloc>(),
              );
            } else if (state is OrderDetailsUpdating) {
              return OrderDetailsContent(
                orderDetails: state.orderDetails,
                statuses: state.statuses,
                orderDetailsBloc: context.read<OrderDetailsBloc>(),
              );
            } else if (state is OrderPhotoUploading) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: AppColors.primary),
                    SizedBox(height: 16),
                    Text(
                      'Загрузка фотографии...',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              );
            } else if (state is OrderDetailsError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 64, color: AppColors.error),
                    const SizedBox(height: 16),
                    Text(
                      state.message,
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: AppColors.error,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<OrderDetailsBloc>().add(
                          LoadOrderDetails(orderId: orderId),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.background,
                      ),
                      child: const Text('Повторить'),
                    ),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          },
        ),
        bottomNavigationBar: BlocBuilder<OrderDetailsBloc, OrderDetailsState>(
          builder: (context, state) {
            if (state is OrderDetailsLoaded) {
              return OrderActionsBar(
                orderDetails: state.orderDetails,
                statuses: state.statuses,
              );
            }
            return const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}
