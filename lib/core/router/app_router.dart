import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../shared/constants/app_constants.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/splash_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/orders/presentation/pages/orders_page.dart';
import '../../features/orders/presentation/pages/comments_page.dart';
import '../../features/orders/presentation/pages/order_comments_page.dart';
import '../../features/orders/presentation/pages/order_details_page.dart';
import '../../features/orders/presentation/bloc/order_comments_bloc.dart';
import '../../features/orders/presentation/bloc/courier_comments_bloc.dart';
import '../../features/orders/presentation/bloc/pending_tasks_count_bloc.dart';
import '../../features/orders/presentation/bloc/order_comments_count_bloc.dart';
import '../../features/orders/presentation/widgets/badge_icon.dart';
import '../../features/orders/domain/usecases/get_order_comments_usecase.dart';
import '../../features/orders/domain/usecases/get_courier_comments_usecase.dart';
import '../../features/orders/domain/usecases/update_order_comment_usecase.dart';
import '../../core/di/injection.dart';

/// Конфигурация роутера приложения
class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash,
    routes: [
      // Splash screen
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashPage(),
      ),

      // Auth routes
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.importKey,
        builder: (context, state) =>
            const Scaffold(body: Center(child: Text('Импорт ключа'))),
      ),

      // Main shell route with bottom navigation
      ShellRoute(
        builder: (context, state, child) =>
            ScaffoldWithBottomNavigation(child: child),
        routes: [
          // Orders tab
          GoRoute(
            path: AppRoutes.orders,
            builder: (context, state) => const OrdersPage(),
          ),

          // Comments tab
          GoRoute(
            path: AppRoutes.comments,
            builder: (context, state) => BlocProvider(
              create: (context) => CourierCommentsBloc(
                getCourierCommentsUseCase: getIt<GetCourierCommentsUseCase>(),
                updateOrderCommentUseCase: getIt<UpdateOrderCommentUseCase>(),
              ),
              child: const CommentsPage(),
            ),
          ),

          // Profile tab
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfilePage(),
          ),
        ],
      ),

      // Order details
      GoRoute(
        path: AppRoutes.orderDetails,
        builder: (context, state) {
          final orderId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          return OrderDetailsPage(orderId: orderId);
        },
      ),

      // Order comments
      GoRoute(
        path: AppRoutes.orderComments,
        builder: (context, state) {
          final orderId = int.tryParse(state.pathParameters['id'] ?? '') ?? 0;
          final extra = state.extra as Map<String, dynamic>?;
          final orderNumber = extra?['orderNumber']?.toString() ?? orderId.toString();
          return MultiBlocProvider(
            providers: [
              BlocProvider(
                create: (context) => OrderCommentsBloc(
                  getOrderCommentsUseCase: getIt<GetOrderCommentsUseCase>(),
                  updateOrderCommentUseCase: getIt<UpdateOrderCommentUseCase>(),
                ),
              ),
              BlocProvider(
                create: (context) => OrderCommentsCountBloc(
                  getOrderCommentsUseCase: getIt<GetOrderCommentsUseCase>(),
                ),
              ),
            ],
            child: OrderCommentsPage(
              orderId: orderId,
              orderNumber: orderNumber,
            ),
          );
        },
      ),
    ],

    // Обработка ошибок
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Страница не найдена',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Путь: ${state.uri}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go(AppRoutes.orders),
              child: const Text('На главную'),
            ),
          ],
        ),
      ),
    ),
  );
}

/// Виджет с нижней навигацией
class ScaffoldWithBottomNavigation extends StatefulWidget {
  const ScaffoldWithBottomNavigation({super.key, required this.child});

  final Widget child;

  @override
  State<ScaffoldWithBottomNavigation> createState() =>
      _ScaffoldWithBottomNavigationState();
}

class _ScaffoldWithBottomNavigationState
    extends State<ScaffoldWithBottomNavigation> {
  int get _currentIndex {
    final location = GoRouterState.of(context).uri.path;
    switch (location) {
      case '/orders':
        return 0;
      case '/comments':
        return 1;
      case '/profile':
        return 2;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PendingTasksCountBloc(
        getCourierCommentsUseCase: getIt<GetCourierCommentsUseCase>(),
      )..add(const LoadPendingTasksCount()),
      child: Scaffold(
        body: widget.child,
        bottomNavigationBar: BlocBuilder<PendingTasksCountBloc, PendingTasksCountState>(
          builder: (context, state) {
            int pendingCount = 0;
            
            if (state is PendingTasksCountLoaded) {
              pendingCount = state.pendingCount;
            }
            
            return BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) {
                // Навигация по вкладкам
                switch (index) {
                  case 0:
                    context.go(AppRoutes.orders);
                    break;
                  case 1:
                    context.go(AppRoutes.comments);
                    // Обновляем счетчик при переходе на страницу комментариев
                    context.read<PendingTasksCountBloc>().add(const RefreshPendingTasksCount());
                    break;
                  case 2:
                    context.go(AppRoutes.profile);
                    break;
                }
              },
              type: BottomNavigationBarType.fixed,
              items: [
                const BottomNavigationBarItem(icon: Icon(Icons.list), label: 'Заявки'),
                BottomNavigationBarItem(
                  icon: BadgeIcon(
                    icon: Icons.comment,
                    count: pendingCount,
                  ),
                  label: 'Комментарии',
                ),
                const BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Профиль'),
              ],
            );
          },
        ),
      ),
    );
  }
}
