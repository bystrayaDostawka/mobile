import 'package:bystraya_dostawka/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/constants/app_constants.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/domain/repositories/auth_repository.dart' as auth_domain;
import '../../domain/usecases/get_profile_usecase.dart';
import '../../domain/usecases/update_profile_usecase.dart';
import '../bloc/profile_bloc.dart';
import '../widgets/profile_info_widget.dart';
import '../widgets/profile_state_widgets.dart';

/// Страница профиля пользователя
class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProfileBloc>(
          create: (context) => ProfileBloc(
            getProfileUseCase: getIt<GetProfileUseCase>(),
            updateProfileUseCase: getIt<UpdateProfileUseCase>(),
          )..add(const LoadProfile()),
        ),
        BlocProvider<AuthBloc>(
          create: (context) =>
              AuthBloc(authRepository: getIt<auth_domain.AuthRepository>()),
        ),
      ],
      child: const _ProfilePageView(),
    );
  }
}

class _ProfilePageView extends StatelessWidget {
  const _ProfilePageView();

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthInitial) {
          // Показываем уведомление об успешном выходе
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Вы успешно вышли из системы'),
              backgroundColor: AppColors.success,
            ),
          );
          // Переход на страницу логина
          context.go(AppRoutes.login);
        } else if (state is AuthFailure) {
          print('🎯 ProfilePage: Ошибка выхода: ${state.message}');
          // Показываем ошибку
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: AppColors.error,
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Профиль'), centerTitle: true),
        body: BlocListener<ProfileBloc, ProfileState>(
          listener: (context, state) {
            if (state is ProfileUpdated) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Профиль успешно обновлен'),
                  backgroundColor: AppColors.success,
                ),
              );
            } else if (state is ProfileError) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error,
                ),
              );
            }
          },
          child: BlocBuilder<ProfileBloc, ProfileState>(
            builder: (context, state) {
              // Показываем индикатор загрузки на весь экран
              if (state is ProfileLoading) {
                return const Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(color: AppColors.primary),
                      SizedBox(height: 16),
                      Text(
                        'Загрузка профиля...',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                );
              }

              return SingleChildScrollView(
                child: Padding(
                  padding: AppTheme.edgeInsets,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: AppTheme.spacing16,
                    children: [
                      _buildProfileContent(context, state),
                      Container(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _handleLogout(context),
                          icon: const Icon(Icons.logout),
                          label: const Text('Выйти из системы'),
                        ),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            AppConstants.appName,
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          SizedBox(width: AppTheme.spacing16),
                          Text(
                            '${AppConstants.appVersion}',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, ProfileState state) {
    switch (state.runtimeType) {
      case ProfileUpdating:
        return const ProfileLoadingWidget();
      case ProfileError:
        final errorState = state as ProfileError;
        return ProfileErrorWidget(
          message: errorState.message,
          onRetry: () =>
              context.read<ProfileBloc>().add(const RefreshProfile()),
        );
      case ProfileLoaded:
        final loadedState = state as ProfileLoaded;
        return ProfileInfoWidget(profile: loadedState.profile);
      case ProfileUpdated:
        final updatedState = state as ProfileUpdated;
        return ProfileInfoWidget(profile: updatedState.profile);
      default:
        return const SizedBox.shrink();
    }
  }

  void _handleLogout(BuildContext context) {
    // Показываем диалог подтверждения
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Выход из системы'),
        content: const Text('Вы уверены, что хотите выйти?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              context.read<AuthBloc>().add(const LogoutRequested());
            },
            child: const Text('Выйти'),
          ),
        ],
      ),
    );
  }
}
