import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/usecase/usecase.dart';
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../../data/model/profile_response_model.dart';
import '../../data/model/update_profile_request_model.dart';

/// События для ProfileBloc
abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

/// Загрузка профиля пользователя
class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

/// Обновление профиля пользователя
class RefreshProfile extends ProfileEvent {
  const RefreshProfile();
}

/// Обновление данных профиля
class UpdateProfile extends ProfileEvent {
  const UpdateProfile({required this.request});

  final UpdateProfileRequestModel request;

  @override
  List<Object?> get props => [request];
}

/// Состояния для ProfileBloc
abstract class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

/// Начальное состояние
class ProfileInitial extends ProfileState {
  const ProfileInitial();
}

/// Состояние загрузки
class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

/// Состояние успешной загрузки
class ProfileLoaded extends ProfileState {
  const ProfileLoaded({required this.profile});

  final ProfileResponseModel profile;

  @override
  List<Object?> get props => [profile];
}

/// Состояние ошибки
class ProfileError extends ProfileState {
  const ProfileError({required this.message});

  final String message;

  @override
  List<Object?> get props => [message];
}

/// Состояние обновления профиля
class ProfileUpdating extends ProfileState {
  const ProfileUpdating();
}

/// Состояние успешного обновления профиля
class ProfileUpdated extends ProfileState {
  const ProfileUpdated({required this.profile});

  final ProfileResponseModel profile;

  @override
  List<Object?> get props => [profile];
}

/// BLoC для управления профилем пользователя
class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required this.getProfileUseCase,
    required this.updateProfileUseCase,
  }) : super(const ProfileInitial()) {
    on<LoadProfile>(_onLoadProfile);
    on<RefreshProfile>(_onRefreshProfile);
    on<UpdateProfile>(_onUpdateProfile);
  }

  final GetProfileUseCase getProfileUseCase;
  final UpdateProfileUseCase updateProfileUseCase;

  /// Загрузка профиля
  Future<void> _onLoadProfile(
    LoadProfile event,
    Emitter<ProfileState> emit,
  ) async {
    print('👤 ProfileBloc: Начинаем загрузку профиля');
    emit(const ProfileLoading());

    try {
      final result = await getProfileUseCase.call(NoParams());

      if (result is Success<ProfileResponseModel>) {
        print('✅ ProfileBloc: Профиль загружен успешно');
        emit(ProfileLoaded(profile: result.data));
      } else if (result is FailureResult<ProfileResponseModel>) {
        print('❌ ProfileBloc: Ошибка загрузки профиля: ${result.failure}');
        emit(ProfileError(message: result.failure.message));
      }
    } catch (e) {
      print('❌ ProfileBloc: Исключение при загрузке профиля: $e');
      emit(ProfileError(message: 'Ошибка загрузки профиля: $e'));
    }
  }

  /// Обновление профиля
  Future<void> _onRefreshProfile(
    RefreshProfile event,
    Emitter<ProfileState> emit,
  ) async {
    print('🔄 ProfileBloc: Обновляем профиль');
    await _onLoadProfile(const LoadProfile(), emit);
  }

  /// Обновление данных профиля
  Future<void> _onUpdateProfile(
    UpdateProfile event,
    Emitter<ProfileState> emit,
  ) async {
    print('✏️ ProfileBloc: Начинаем обновление данных профиля');
    emit(const ProfileUpdating());

    try {
      final result = await updateProfileUseCase.call(event.request);

      if (result is Success<ProfileResponseModel>) {
        print('✅ ProfileBloc: Профиль успешно обновлен');
        emit(ProfileUpdated(profile: result.data));

        // После успешного обновления загружаем актуальные данные профиля
        await _onLoadProfile(const LoadProfile(), emit);
      } else if (result is FailureResult<ProfileResponseModel>) {
        print('❌ ProfileBloc: Ошибка обновления профиля: ${result.failure}');
        emit(ProfileError(message: result.failure.message));
      }
    } catch (e) {
      print('❌ ProfileBloc: Исключение при обновлении профиля: $e');
      emit(ProfileError(message: 'Ошибка обновления профиля: $e'));
    }
  }
}
