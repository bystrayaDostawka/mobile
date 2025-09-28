# Соглашения по коду для проекта "Быстрая доставка"

## Naming Conventions

### Файлы и папки
- **snake_case** для файлов и папок: `auth_bloc.dart`, `order_repository.dart`
- **PascalCase** для классов: `AuthBloc`, `OrderRepository`
- **camelCase** для переменных и методов: `userRole`, `getOrders()`

### BLoC файлы
```
feature/
├── presentation/
│   ├── bloc/
│   │   ├── feature_bloc.dart
│   │   ├── feature_event.dart
│   │   └── feature_state.dart
│   ├── pages/
│   └── widgets/
```

### Репозитории
```
feature/
├── data/
│   ├── datasources/
│   │   ├── feature_remote_data_source.dart
│   │   └── feature_local_data_source.dart
│   ├── models/
│   │   └── feature_model.dart
│   └── repositories/
│       └── feature_repository_impl.dart
├── domain/
│   ├── entities/
│   │   └── feature_entity.dart
│   ├── repositories/
│   │   └── feature_repository.dart
│   └── usecases/
│       └── get_feature_usecase.dart
```

## Структура кода

### Импорты (порядок)
1. Dart SDK imports
2. Flutter imports
3. Third-party package imports
4. Local imports (относительные пути)

```dart
import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:dio/dio.dart';
import 'package:get_it/get_it.dart';

import '../../core/error/failures.dart';
import '../domain/entities/user.dart';
```

### Классы и методы

#### BLoC
```dart
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({required AuthRepository repository})
      : super(AuthInitial()) {
    on<LoginRequested>(_onLoginRequested);
    on<LogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onLoginRequested(
    LoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    // Implementation
  }
}
```

#### События
```dart
abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class LoginRequested extends AuthEvent {
  const LoginRequested({required this.privateKey});

  final String privateKey;

  @override
  List<Object?> get props => [privateKey];
}
```

#### Состояния
```dart
abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {}

class AuthLoading extends AuthState {}

class AuthSuccess extends AuthState {
  const AuthSuccess({required this.user});

  final User user;

  @override
  List<Object?> get props => [user];
}

class AuthFailure extends AuthState {
  const AuthFailure({required this.failure});

  final Failure failure;

  @override
  List<Object?> get props => [failure];
}
```

### Виджеты

#### StatelessWidget
```dart
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Вход')),
      body: BlocProvider(
        create: (context) => getIt<AuthBloc>(),
        child: const LoginForm(),
      ),
    );
  }
}
```

#### StatefulWidget
```dart
class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final _formKey = GlobalKey<FormState>();
  final _privateKeyController = TextEditingController();

  @override
  void dispose() {
    _privateKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          TextFormField(
            controller: _privateKeyController,
            decoration: const InputDecoration(
              labelText: 'Приватный ключ',
            ),
          ),
        ],
      ),
    );
  }
}
```

## Комментарии и документация

### Документация классов
```dart
/// Блок для управления авторизацией пользователя
/// 
/// Обрабатывает события входа, выхода и проверки авторизации.
/// Использует [AuthRepository] для взаимодействия с данными.
class AuthBloc extends Bloc<AuthEvent, AuthState> {
  // Implementation
}
```

### Комментарии методов
```dart
/// Авторизует пользователя с помощью приватного ключа
/// 
/// [privateKey] - приватный ключ для авторизации
/// Возвращает [Result<String>] с токеном авторизации или ошибкой
Future<Result<String>> authenticateWithPrivateKey(String privateKey) async {
  // Implementation
}
```

## Обработка ошибок

### Использование Failure
```dart
try {
  final result = await repository.getData();
  return Result.success(result);
} catch (e) {
  return Result.failure(ServerFailure(e.toString()));
}
```

### Показ ошибок пользователю
```dart
BlocListener<AuthBloc, AuthState>(
  listener: (context, state) {
    if (state is AuthFailure) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.failure.message),
          backgroundColor: Colors.red,
        ),
      );
    }
  },
  child: // widget
)
```

## Тестирование

### Структура тестов
```
test/
├── unit/
│   ├── features/
│   │   └── auth/
│   │       ├── bloc/
│   │       ├── usecases/
│   │       └── repositories/
│   └── core/
└── widget/
    └── features/
        └── auth/
            └── pages/
```

### Пример теста BLoC
```dart
group('AuthBloc', () {
  late AuthBloc authBloc;
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    authBloc = AuthBloc(repository: mockAuthRepository);
  });

  tearDown(() {
    authBloc.close();
  });

  test('initial state is AuthInitial', () {
    expect(authBloc.state, isA<AuthInitial>());
  });

  blocTest<AuthBloc, AuthState>(
    'emits [AuthLoading, AuthSuccess] when login is successful',
    build: () {
      when(mockAuthRepository.authenticateWithPrivateKey(any))
          .thenAnswer((_) async => Result.success('token'));
      return authBloc;
    },
    act: (bloc) => bloc.add(const LoginRequested(privateKey: 'key')),
    expect: () => [
      isA<AuthLoading>(),
      isA<AuthSuccess>(),
    ],
  );
});
```

## Git и коммиты

### Conventional Commits
- `feat:` - новая функциональность
- `fix:` - исправление ошибок
- `docs:` - документация
- `style:` - форматирование кода
- `refactor:` - рефакторинг
- `test:` - тесты
- `chore:` - обновления зависимостей, конфигурации

### Примеры коммитов
```
feat: add authentication with private key
fix: resolve QR scanner permission issue
docs: update API documentation
refactor: extract common widgets to shared folder
test: add unit tests for AuthBloc
```

## Производительность

### Оптимизация виджетов
- Используйте `const` конструкторы где возможно
- Избегайте ненужных перестроений с помощью `BlocBuilder`
- Используйте `BlocListener` для side effects

### Оптимизация изображений
- Сжимайте изображения перед загрузкой
- Используйте кэширование
- Ограничивайте размер файлов

## Безопасность

### Хранение данных
- Используйте `flutter_secure_storage` для чувствительных данных
- Не храните приватные ключи в обычном хранилище
- Валидируйте все входные данные

### Сетевая безопасность
- Используйте HTTPS для всех API запросов
- Валидируйте сертификаты
- Обрабатывайте ошибки сети
