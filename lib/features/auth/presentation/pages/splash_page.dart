import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../shared/constants/app_constants.dart';
import '../bloc/auth_bloc.dart';

/// Страница загрузки с проверкой авторизации
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  Widget build(BuildContext context) {
    // Используем глобальный AuthBloc вместо создания нового
    print('🔧 SplashPage: Используем глобальный AuthBloc');

    // Проверяем авторизацию после создания BLoC
    WidgetsBinding.instance.addPostFrameCallback((_) {
      print('🚀 SplashPage: Проверяем статус авторизации');
      context.read<AuthBloc>().add(const CheckAuthStatus());
    });

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        print('🎯 SplashPage: Получено состояние: $state');
        if (state is AuthSuccess) {
          print(
            '🎯 SplashPage: Пользователь авторизован, переходим на главную',
          );
          context.go(AppRoutes.orders);
        } else if (state is AuthInitial) {
          print(
            '🎯 SplashPage: Пользователь не авторизован, переходим на логин',
          );
          context.go(AppRoutes.login);
        }
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Логотип
              const Icon(
                Icons.local_shipping,
                size: 80,
                color: AppColors.primary,
              ),
              const SizedBox(height: 24),

              // Название приложения
              Text(
                AppConstants.appName,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),

              // Индикатор загрузки
              const CircularProgressIndicator(color: AppColors.primary),
              const SizedBox(height: 16),

              // Текст загрузки
              Text(
                'Проверка авторизации...',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
