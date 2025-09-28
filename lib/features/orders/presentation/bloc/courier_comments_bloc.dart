import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/order_comment_entity.dart';
import '../../domain/usecases/get_courier_comments_usecase.dart';
import '../../domain/usecases/update_order_comment_usecase.dart';
import '../../../../core/usecase/usecase.dart';

// Events
abstract class CourierCommentsEvent extends Equatable {
  const CourierCommentsEvent();

  @override
  List<Object?> get props => [];
}

class LoadCourierComments extends CourierCommentsEvent {
  const LoadCourierComments();
}

class RefreshCourierComments extends CourierCommentsEvent {
  const RefreshCourierComments();
}

class UpdateCommentStatus extends CourierCommentsEvent {
  final int orderId;
  final int commentId;
  final bool isCompleted;

  const UpdateCommentStatus(this.orderId, this.commentId, this.isCompleted);

  @override
  List<Object?> get props => [orderId, commentId, isCompleted];
}

// States
abstract class CourierCommentsState extends Equatable {
  const CourierCommentsState();

  @override
  List<Object?> get props => [];
}

class CourierCommentsInitial extends CourierCommentsState {}

class CourierCommentsLoading extends CourierCommentsState {}

class CourierCommentsLoaded extends CourierCommentsState {
  final List<OrderCommentEntity> comments;

  const CourierCommentsLoaded({required this.comments});

  @override
  List<Object?> get props => [comments];
}

class CourierCommentsError extends CourierCommentsState {
  final String message;

  const CourierCommentsError({required this.message});

  @override
  List<Object?> get props => [message];
}

class CourierCommentUpdated extends CourierCommentsState {
  final OrderCommentEntity comment;
  final String message;

  const CourierCommentUpdated({
    required this.comment,
    required this.message,
  });

  @override
  List<Object?> get props => [comment, message];
}

// Bloc
class CourierCommentsBloc extends Bloc<CourierCommentsEvent, CourierCommentsState> {
  final GetCourierCommentsUseCase getCourierCommentsUseCase;
  final UpdateOrderCommentUseCase updateOrderCommentUseCase;

  CourierCommentsBloc({
    required this.getCourierCommentsUseCase,
    required this.updateOrderCommentUseCase,
  }) : super(CourierCommentsInitial()) {
    on<LoadCourierComments>(_onLoadCourierComments);
    on<RefreshCourierComments>(_onRefreshCourierComments);
    on<UpdateCommentStatus>(_onUpdateCommentStatus);
  }

  Future<void> _onLoadCourierComments(
    LoadCourierComments event,
    Emitter<CourierCommentsState> emit,
  ) async {
    emit(CourierCommentsLoading());
    final result = await getCourierCommentsUseCase.call();

    if (result is Success<List<OrderCommentEntity>>) {
      emit(CourierCommentsLoaded(comments: result.data));
    } else if (result is FailureResult<List<OrderCommentEntity>>) {
      emit(CourierCommentsError(message: result.failure.message));
    }
  }

  Future<void> _onRefreshCourierComments(
    RefreshCourierComments event,
    Emitter<CourierCommentsState> emit,
  ) async {
    final result = await getCourierCommentsUseCase.call();

    if (result is Success<List<OrderCommentEntity>>) {
      emit(CourierCommentsLoaded(comments: result.data));
    } else if (result is FailureResult<List<OrderCommentEntity>>) {
      emit(CourierCommentsError(message: result.failure.message));
    }
  }

  Future<void> _onUpdateCommentStatus(
    UpdateCommentStatus event,
    Emitter<CourierCommentsState> emit,
  ) async {
    final result = await updateOrderCommentUseCase.call(
      UpdateOrderCommentParams(
        orderId: event.orderId,
        commentId: event.commentId,
        isCompleted: event.isCompleted,
      ),
    );

    if (result is Success<OrderCommentEntity>) {
      emit(CourierCommentUpdated(
        comment: result.data,
        message: event.isCompleted ? 'Комментарий отмечен как выполненный' : 'Комментарий отмечен как невыполненный',
      ));

      // Перезагружаем список комментариев
      add(const RefreshCourierComments());
    } else if (result is FailureResult<OrderCommentEntity>) {
      emit(CourierCommentsError(message: result.failure.message));
    }
  }
}
