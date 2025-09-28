import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/order_comment_entity.dart';
import '../../domain/usecases/get_order_comments_usecase.dart';
import '../../domain/usecases/update_order_comment_usecase.dart';
import '../../../../core/usecase/usecase.dart';

// Events
abstract class OrderCommentsEvent extends Equatable {
  const OrderCommentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderComments extends OrderCommentsEvent {
  final int orderId;

  const LoadOrderComments(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class RefreshOrderComments extends OrderCommentsEvent {
  final int orderId;

  const RefreshOrderComments(this.orderId);

  @override
  List<Object?> get props => [orderId];
}

class UpdateCommentStatus extends OrderCommentsEvent {
  final int orderId;
  final int commentId;
  final bool isCompleted;

  const UpdateCommentStatus(this.orderId, this.commentId, this.isCompleted);

  @override
  List<Object?> get props => [orderId, commentId, isCompleted];
}


// States
abstract class OrderCommentsState extends Equatable {
  const OrderCommentsState();

  @override
  List<Object?> get props => [];
}

class OrderCommentsInitial extends OrderCommentsState {}

class OrderCommentsLoading extends OrderCommentsState {}

class OrderCommentsLoaded extends OrderCommentsState {
  final List<OrderCommentEntity> comments;

  const OrderCommentsLoaded({required this.comments});

  @override
  List<Object?> get props => [comments];
}

class OrderCommentsError extends OrderCommentsState {
  final String message;

  const OrderCommentsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class OrderCommentUpdated extends OrderCommentsState {
  final OrderCommentEntity comment;
  final String message;

  const OrderCommentUpdated({
    required this.comment,
    required this.message,
  });

  @override
  List<Object?> get props => [comment, message];
}


// Bloc
class OrderCommentsBloc extends Bloc<OrderCommentsEvent, OrderCommentsState> {
  final GetOrderCommentsUseCase getOrderCommentsUseCase;
  final UpdateOrderCommentUseCase updateOrderCommentUseCase;

  OrderCommentsBloc({
    required this.getOrderCommentsUseCase,
    required this.updateOrderCommentUseCase,
  }) : super(OrderCommentsInitial()) {
    on<LoadOrderComments>(_onLoadOrderComments);
    on<RefreshOrderComments>(_onRefreshOrderComments);
    on<UpdateCommentStatus>(_onUpdateCommentStatus);
  }

  Future<void> _onLoadOrderComments(
    LoadOrderComments event,
    Emitter<OrderCommentsState> emit,
  ) async {
    emit(OrderCommentsLoading());

    final result = await getOrderCommentsUseCase.call(event.orderId);

    if (result is Success<List<OrderCommentEntity>>) {
      emit(OrderCommentsLoaded(comments: result.data));
    } else if (result is FailureResult<List<OrderCommentEntity>>) {
      emit(OrderCommentsError(message: result.failure.message));
    }
  }

  Future<void> _onRefreshOrderComments(
    RefreshOrderComments event,
    Emitter<OrderCommentsState> emit,
  ) async {
    final result = await getOrderCommentsUseCase.call(event.orderId);

    if (result is Success<List<OrderCommentEntity>>) {
      emit(OrderCommentsLoaded(comments: result.data));
    } else if (result is FailureResult<List<OrderCommentEntity>>) {
      emit(OrderCommentsError(message: result.failure.message));
    }
  }

  Future<void> _onUpdateCommentStatus(
    UpdateCommentStatus event,
    Emitter<OrderCommentsState> emit,
  ) async {
    final result = await updateOrderCommentUseCase.call(
      UpdateOrderCommentParams(
        orderId: event.orderId,
        commentId: event.commentId,
        isCompleted: event.isCompleted,
      ),
    );

    if (result is Success<OrderCommentEntity>) {
      emit(OrderCommentUpdated(
        comment: result.data,
        message: event.isCompleted ? 'Отмечено как выполненное' : 'Отмечено как невыполненное',
      ));

      // Перезагружаем список комментариев
      add(LoadOrderComments(event.orderId));
    } else if (result is FailureResult<OrderCommentEntity>) {
      emit(OrderCommentsError(message: result.failure.message));
    }
  }

}
