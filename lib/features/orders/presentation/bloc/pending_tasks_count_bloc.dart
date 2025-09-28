import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

import '../../domain/entities/order_comment_entity.dart';
import '../../domain/usecases/get_courier_comments_usecase.dart';
import '../../../../core/usecase/usecase.dart';

// Events
abstract class PendingTasksCountEvent extends Equatable {
  const PendingTasksCountEvent();

  @override
  List<Object?> get props => [];
}

class LoadPendingTasksCount extends PendingTasksCountEvent {
  const LoadPendingTasksCount();
}

class RefreshPendingTasksCount extends PendingTasksCountEvent {
  const RefreshPendingTasksCount();
}

// States
abstract class PendingTasksCountState extends Equatable {
  const PendingTasksCountState();

  @override
  List<Object?> get props => [];
}

class PendingTasksCountInitial extends PendingTasksCountState {}

class PendingTasksCountLoading extends PendingTasksCountState {}

class PendingTasksCountLoaded extends PendingTasksCountState {
  final int pendingCount;

  const PendingTasksCountLoaded({required this.pendingCount});

  @override
  List<Object?> get props => [pendingCount];
}

class PendingTasksCountError extends PendingTasksCountState {
  final String message;

  const PendingTasksCountError({required this.message});

  @override
  List<Object?> get props => [message];
}

// Bloc
class PendingTasksCountBloc extends Bloc<PendingTasksCountEvent, PendingTasksCountState> {
  final GetCourierCommentsUseCase getCourierCommentsUseCase;

  PendingTasksCountBloc({
    required this.getCourierCommentsUseCase,
  }) : super(PendingTasksCountInitial()) {
    on<LoadPendingTasksCount>(_onLoadPendingTasksCount);
    on<RefreshPendingTasksCount>(_onRefreshPendingTasksCount);
  }

  Future<void> _onLoadPendingTasksCount(
    LoadPendingTasksCount event,
    Emitter<PendingTasksCountState> emit,
  ) async {
    emit(PendingTasksCountLoading());
    final result = await getCourierCommentsUseCase.call();

    if (result is Success<List<OrderCommentEntity>>) {
      final pendingCount = result.data.where((comment) => !comment.isCompleted).length;
      emit(PendingTasksCountLoaded(pendingCount: pendingCount));
    } else if (result is FailureResult<List<OrderCommentEntity>>) {
      emit(PendingTasksCountError(message: result.failure.message));
    }
  }

  Future<void> _onRefreshPendingTasksCount(
    RefreshPendingTasksCount event,
    Emitter<PendingTasksCountState> emit,
  ) async {
    final result = await getCourierCommentsUseCase.call();

    if (result is Success<List<OrderCommentEntity>>) {
      final pendingCount = result.data.where((comment) => !comment.isCompleted).length;
      emit(PendingTasksCountLoaded(pendingCount: pendingCount));
    } else if (result is FailureResult<List<OrderCommentEntity>>) {
      emit(PendingTasksCountError(message: result.failure.message));
    }
  }
}
