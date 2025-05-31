# Educational App Front-end

The Flutter front-end application for the Educational App platform.

## 🚀 Features

- Clean Architecture (Data-Domain-Presentation)
- State Management with BLoC
- Offline Support
- Responsive Design
- Dark/Light Theme
- Form Validation
- Error Handling
- Loading States
- Navigation Management

## 🛠️ Tech Stack

- **Flutter**: UI Framework
- **Dart**: Programming Language
- **BLoC**: State Management
- **GetIt**: Dependency Injection
- **Dio**: HTTP Client
- **Shared Preferences**: Local Storage
- **Flutter Secure Storage**: Secure Storage
- **Flutter Bloc**: BLoC Implementation
- **Equatable**: Value Equality
- **Flutter Form Builder**: Form Management

## 🏗️ Project Structure

```
lib/
├── data/           # Data Layer
│   ├── datasources/
│   │   └── student_service.dart
│   ├── models/
│   │   └── student_model.dart
│   └── repositories/
│       └── student_repository_impl.dart
├── domain/         # Domain Layer
│   ├── entities/
│   │   └── student.dart
│   ├── repositories/
│   │   └── student_repository.dart
│   └── usecases/
│       └── get_students.dart
├── presentation/   # Presentation Layer
│   ├── blocs/
│   │   └── student/
│   │       ├── student_bloc.dart
│   │       ├── student_event.dart
│   │       └── student_state.dart
│   ├── pages/
│   │   ├── home_page.dart
│   │   └── student_page.dart
│   └── widgets/
│       ├── student_card.dart
│       └── loading_indicator.dart
├── helpers/        # Helper Classes
│   ├── constants.dart
│   └── utils.dart
└── main.dart       # Application Entry Point
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK (>=2.17.0)
- Android Studio / VS Code
- Android SDK / Xcode (for iOS)

### Installation

1. Install Flutter dependencies:
```bash
flutter pub get
```

2. Create a `.env` file in the root directory:
```env
API_URL=your_api_url
```

3. Run the app:
```bash
flutter run
```

## 📱 Screens

### Home Screen
- List of students
- Search functionality
- Add new student button
- Student details view

### Student Screen
- Student information
- Edit functionality
- Delete option
- Progress tracking

## 🔧 Configuration

### Environment Variables

- `API_URL`: Back-end API URL

### Theme Configuration

Update theme in `lib/helpers/constants.dart`:
```dart
class AppTheme {
  static ThemeData lightTheme = ThemeData(
    primarySwatch: Colors.blue,
    // ... other theme configurations
  );
}
```

## 📦 Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_bloc: ^8.1.3
  get_it: ^7.2.0
  dio: ^5.0.0
  shared_preferences: ^2.0.15
  flutter_secure_storage: ^8.0.0
  equatable: ^2.0.5
  flutter_form_builder: ^9.0.0
```

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details.
