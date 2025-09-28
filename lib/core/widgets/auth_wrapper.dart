import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../services/auth_service.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../shared/constants/app_constants.dart';

/// Виджет для отслеживания состояния авторизации и автоматического перехода
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key, required this.child});

  final Widget child;

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  late StreamSubscription<bool> _authSubscription;

  @override
  void initState() {
    super.initState();
    _setupAuthListener();
  }

  void _setupAuthListener() {
    _authSubscription = authService.authStateStream.listen((isAuthenticated) {
      if (!isAuthenticated && mounted) {
        // Уведомляем AuthBloc об истечении токена
        if (context.mounted) {
          context.read<AuthBloc>().add(const TokenExpired());
        }

        // Переходим на страницу логина
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && context.mounted) {
            context.go(AppRoutes.login);
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
