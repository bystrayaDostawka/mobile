import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/order_comment_entity.dart';
import '../../domain/usecases/get_order_comments_usecase.dart';
import '../../../../core/usecase/usecase.dart';

// Events
abstract class OrderCommentsCountEvent extends Equatable {
  const OrderCommentsCountEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrderCommentsCount extends OrderCommentsCountEvent {
  final int orderId;

  const LoadOrderCommentsCount({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

class RefreshOrderCommentsCount extends OrderCommentsCountEvent {
  final int orderId;

  const RefreshOrderCommentsCount({required this.orderId});

  @override
  List<Object?> get props => [orderId];
}

// States
abstract class OrderCommentsCountState extends Equatable {
  const OrderCommentsCountState();

  @override
  List<Object?> get props => [];
}

class OrderCommentsCountInitial extends OrderCommentsCountState {}

class OrderCommentsCountLoading extends OrderCommentsCountState {}

class OrderCommentsCountLoaded extends OrderCommentsCountState {
  final int pendingCount;

  const OrderCommentsCountLoaded({required this.pendingCount});

  @override
  List<Object?> get props => [pendingCount];
}

class OrderCommentsCountError extends OrderCommentsCountState {
  final String message;

  const OrderCommentsCountError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class OrderCommentsCountBloc extends Bloc<OrderCommentsCountEvent, OrderCommentsCountState> {
  final GetOrderCommentsUseCase getOrderCommentsUseCase;

  OrderCommentsCountBloc({
    required this.getOrderCommentsUseCase,
  }) : super(OrderCommentsCountInitial()) {
    on<LoadOrderCommentsCount>(_onLoadOrderCommentsCount);
    on<RefreshOrderCommentsCount>(_onRefreshOrderCommentsCount);
  }

  Future<void> _onLoadOrderCommentsCount(
    LoadOrderCommentsCount event,
    Emitter<OrderCommentsCountState> emit,
  ) async {
    emit(OrderCommentsCountLoading());
    final result = await getOrderCommentsUseCase.call(event.orderId);

    if (result is Success<List<OrderCommentEntity>>) {
      final pendingCount = result.data.where((comment) => !comment.isCompleted).length;
      emit(OrderCommentsCountLoaded(pendingCount: pendingCount));
    } else if (result is FailureResult<List<OrderCommentEntity>>) {
      emit(OrderCommentsCountError(message: result.failure.message));
    }
  }

  Future<void> _onRefreshOrderCommentsCount(
    RefreshOrderCommentsCount event,
    Emitter<OrderCommentsCountState> emit,
  ) async {
    final result = await getOrderCommentsUseCase.call(event.orderId);

    if (result is Success<List<OrderCommentEntity>>) {
      final pendingCount = result.data.where((comment) => !comment.isCompleted).length;
      emit(OrderCommentsCountLoaded(pendingCount: pendingCount));
    } else if (result is FailureResult<List<OrderCommentEntity>>) {
      emit(OrderCommentsCountError(message: result.failure.message));
    }
  }
}
