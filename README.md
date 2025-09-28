# Быстрая доставка

Мобильное приложение для управления доставкой для курьеров.

## Описание

Приложение "Быстрая доставка" предназначено для автоматизации процесса доставки с использованием приватных ключей для авторизации и QR-кодов для идентификации заявок.

### Основные возможности
- **Авторизация с приватным ключом** - безопасная авторизация через импорт приватного ключа
- **Управление заявками** - просмотр, обновление статусов и отправка фото
- **Push-уведомления** - уведомления о новых заявках и обновлениях
- **Офлайн режим** - работа без интернета с синхронизацией при подключении

### Функциональность курьера

- Просмотр назначенных заявок
- Обновление статусов заявок
- Фотографирование доставки
- Просмотр уведомлений
- Управление профилем

## Технический стек

- **Framework**: Flutter 3.8+
- **State Management**: BLoC (flutter_bloc)
- **Dependency Injection**: GetIt + Injectable
- **Routing**: Go Router
- **Network**: Dio + Retrofit
- **Storage**: SharedPreferences + Flutter Secure Storage
- **QR Scanner**: qr_code_scanner
- **Notifications**: Firebase Messaging
- **Testing**: flutter_test + bloc_test

## Архитектура

Приложение построено на принципах Clean Architecture с использованием BLoC паттерна:

```
lib/
├── core/                    # Базовые абстракции
│   ├── di/                  # Dependency Injection
│   ├── error/               # Обработка ошибок
│   ├── usecase/             # UseCase абстракции
│   ├── network/             # Сетевой слой
│   ├── storage/             # Хранилище
│   ├── theme/               # Тема приложения
│   └── router/              # Роутинг
├── features/                # Функциональные модули
│   ├── auth/                # Авторизация
│   ├── orders/              # Заявки
│   ├── scanner/             # QR сканер
│   ├── notifications/       # Уведомления
│   ├── profile/             # Профиль
│   └── admin/               # Админ панель
└── shared/                  # Общие компоненты
    ├── widgets/             # Переиспользуемые виджеты
    ├── constants/           # Константы
    ├── utils/               # Утилиты
    └── extensions/          # Расширения
```

## Установка и запуск

### Требования

- Flutter 3.8+
- Dart 3.0+
- Android Studio / VS Code
- Android SDK (API 26+)
- iOS 13+ (для iOS разработки)

### Установка зависимостей

```bash
flutter pub get
```

### Запуск приложения

```bash
# Debug режим
flutter run

# Release режим
flutter run --release
```

### Генерация кода

```bash
# Генерация DI кода
flutter packages pub run build_runner build

# Генерация с удалением старых файлов
flutter packages pub run build_runner build --delete-conflicting-outputs
```

## Конфигурация

### Переменные окружения

Создайте файл `.env` в корне проекта:

```env
API_BASE_URL=https://admin.bystrayadostavka.ru
API_VERSION=/api/v1
FIREBASE_PROJECT_ID=your-project-id
```

### Firebase настройка

1. Создайте проект в Firebase Console
2. Добавьте Android и iOS приложения
3. Скачайте конфигурационные файлы:
   - `google-services.json` для Android
   - `GoogleService-Info.plist` для iOS
4. Разместите файлы в соответствующих папках

## Тестирование

### Запуск тестов

```bash
# Все тесты
flutter test

# Unit тесты
flutter test test/unit/

# Widget тесты
flutter test test/widget/

# Интеграционные тесты
flutter test test/integration/
```

### Покрытие кода

```bash
flutter test --coverage
genhtml coverage/lcov.info -o coverage/html
```

## Сборка

### Android

```bash
# APK
flutter build apk --release

# App Bundle
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

## Развертывание

### Android

1. Создайте keystore для подписи
2. Настройте `android/app/build.gradle`
3. Загрузите в Google Play Console

### iOS

1. Настройте сертификаты в Apple Developer Console
2. Создайте App Store Connect запись
3. Загрузите через Xcode или Fastlane

## Безопасность

### Хранение данных

- Приватные ключи хранятся в Flutter Secure Storage
- Токены авторизации шифруются
- Все API запросы используют HTTPS

### Разрешения

Приложение запрашивает следующие разрешения:

- **Камера** - для сканирования QR-кодов и фотографирования
- **Интернет** - для API запросов
- **Уведомления** - для push-уведомлений
- **Хранилище** - для кэширования данных

## Поддержка

### Версии ОС

- **Android**: API 26+ (Android 8.0+)
- **iOS**: iOS 13.0+

### Устройства

- **Минимальная ширина экрана**: 320dp
- **Рекомендуемая ширина экрана**: 360dp+
- **Поддержка планшетов**: Да

## Лицензия

Проект разработан для внутреннего использования компании "Быстрая доставка".

## Команда разработки

- **Архитектор**: [Ваше имя]
- **Разработчики**: [Команда разработки]
- **Дизайнер**: [Дизайнер]

## История версий

### v1.0.0 (Этап 0)
- Базовая архитектура BLoC
- Dependency Injection
- Роутинг с go_router
- Тема приложения
- Базовые абстракции

### Планируемые версии

#### v1.1.0 (Этап 1)
- Авторизация с приватным ключом
- QR-сканер
- Управление заявками
- Push-уведомления
- Ролевая система

#### v1.2.0 (Этап 2)
- Офлайн режим
- Синхронизация данных
- Расширенная аналитика
- Оптимизация производительности
