import 'package:bystraya_dostawka/core/theme/app_colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/injection.dart';
import '../../../../core/usecase/usecase.dart';
import '../../../../core/services/filters_storage_service.dart';
import '../../../auth/domain/repositories/auth_repository.dart' as auth_domain;
import '../../../profile/domain/entities/user_entity.dart';
import '../../domain/usecases/get_orders_usecase.dart';
import '../../domain/usecases/sort_orders_usecase.dart';
import '../../domain/entities/sort_order.dart';
import '../bloc/orders_bloc.dart';
import '../widgets/orders_list_widget.dart';
import '../widgets/orders_filters_modal.dart';

class OrdersPage extends StatefulWidget {
  const OrdersPage({super.key});

  @override
  State<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends State<OrdersPage> {
  OrdersBloc? _ordersBloc;
  int? _courierId;
  SortOrder _currentSortOrder = SortOrder.deliveryAtDesc;

  @override
  void initState() {
    super.initState();
    _initializeBloc();
  }

  Future<void> _initializeBloc() async {
    final authRepo = getIt<auth_domain.AuthRepository>();
    final result = await authRepo.getCurrentUser();
    
    if (result is Success<UserEntity>) {
      final user = result.data;
      _courierId = user.id;
      print('🔧 OrdersPage: ID курьера из профиля: $_courierId');

      _ordersBloc = OrdersBloc(
        getOrdersUseCase: getIt<GetOrdersUseCase>(),
        sortOrdersUseCase: getIt<SortOrdersUseCase>(),
        courierId: _courierId!,
        filtersStorageService: await getIt.getAsync<FiltersStorageService>(),
      );
      _ordersBloc!.add(const LoadOrders());
      setState(() {});
    } else if (result is FailureResult<UserEntity>) {
      print(
        '❌ OrdersPage: Ошибка получения профиля пользователя: ${result.failure.message}',
      );
    }
  }

  @override
  void dispose() {
    _ordersBloc?.close();
    super.dispose();
  }

  void _showFiltersModal(BuildContext context) {
    if (_ordersBloc == null) return;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => BlocProvider.value(
        value: _ordersBloc!,
        child: const OrdersFiltersModal(),
      ),
    );
  }

  void _showSortDropdown(BuildContext context) {
    showMenu<SortOrder>(
      context: context,
      position: RelativeRect.fromLTRB(
        MediaQuery.of(context).size.width - 200,
        100,
        0,
        0,
      ),
      items: SortOrder.values.map((sortOrder) {
        return PopupMenuItem<SortOrder>(
          value: sortOrder,
          child: Row(
            children: [
              Icon(
                sortOrder.icon,
                size: 20,
                color: _currentSortOrder == sortOrder
                    ? AppColors.textPrimary
                    : AppColors.textHint,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  sortOrder.displayName,
                  style: TextStyle(
                    color: _currentSortOrder == sortOrder
                        ? AppColors.textPrimary
                        : AppColors.textHint,

                    fontWeight: _currentSortOrder == sortOrder
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    ).then((selectedSortOrder) {
      if (selectedSortOrder != null && selectedSortOrder != _currentSortOrder) {
        setState(() {
          _currentSortOrder = selectedSortOrder;
        });
        _ordersBloc?.add(SortOrders(sortOrder: _currentSortOrder));
      }
    });
  }

  IconData _getSortIcon() {
    return _currentSortOrder.icon;
  }

  @override
  Widget build(BuildContext context) {
    if (_courierId == null || _ordersBloc == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return BlocProvider.value(
      value: _ordersBloc!,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Заявки'),
          centerTitle: true,
          actions: [
            BlocBuilder<OrdersBloc, OrdersState>(
              builder: (context, state) {
                bool hasActiveFilters = false;
                int activeFiltersCount = 0;
                
                if (state is OrdersLoaded) {
                  // Подсчитываем активные фильтры
                  if (state.selectedStatusIds.isNotEmpty) {
                    // Считаем множественные статусы как один фильтр
                    activeFiltersCount++;
                  } else if (state.orderStatusId != null) {
                    // Или одиночный статус (для обратной совместимости)
                    activeFiltersCount++;
                  }
                  
                  if (state.dateFrom != null || state.dateTo != null) {
                    activeFiltersCount++;
                  }
                  
                  if (state.search != null && state.search!.isNotEmpty) {
                    activeFiltersCount++;
                  }
                  
                  hasActiveFilters = activeFiltersCount > 0;
                }
                
                return Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Кнопка фильтра
                    IconButton(
                      icon: Icon(
                        Icons.filter_list,
                        color: hasActiveFilters ? AppColors.primary : null,
                      ),
                      style: IconButton.styleFrom(
                        backgroundColor: hasActiveFilters 
                            ? AppColors.primary.withOpacity(0.1) 
                            : null,
                      ),
                      onPressed: () {
                        _showFiltersModal(context);
                      },
                    ),
                    
                    // Кнопка очистить все (показывается только при активных фильтрах)
                    if (hasActiveFilters)
                      IconButton(
                        icon: const Icon(Icons.close),
                        color: AppColors.textSecondary,
                        onPressed: () {
                          context.read<OrdersBloc>().add(const ClearFilters());
                        },
                        tooltip: 'Очистить все фильтры',
                      ),
                  ],
                );
              },
            ),
            BlocBuilder<OrdersBloc, OrdersState>(
              builder: (context, state) {
                // Проверяем, есть ли активная сортировка (не по умолчанию)
                bool hasActiveSort = _currentSortOrder != SortOrder.deliveryAtDesc;
                
                return IconButton(
                  icon: Icon(_getSortIcon()),
                  style: IconButton.styleFrom(
                    backgroundColor: hasActiveSort 
                        ? AppColors.primary.withOpacity(0.1) 
                        : null,
                  ),
                  color: hasActiveSort ? AppColors.primary : null,
                  onPressed: () => _showSortDropdown(context),
                  tooltip: 'Сортировка заказов',
                );
              },
            ),
          ],
        ),
        body: const OrdersListWidget(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            _ordersBloc?.add(const LoadOrders());
          },
          child: const Icon(Icons.refresh),
        ),
      ),
    );
  }
}

