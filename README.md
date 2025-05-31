# Educational App Platform

A full-stack educational platform with a Flutter front-end and Node.js back-end, designed to provide an interactive learning experience for students.

## 🚀 Features

### Front-end (Flutter)
- Student progress tracking
- Interactive learning modules
- Real-time progress updates
- Offline support
- User authentication
- Responsive design

### Back-end (Node.js)
- RESTful API
- JWT Authentication
- MongoDB Database
- Real-time updates
- File upload support
- Data validation

## 🛠️ Tech Stack

### Front-end
- **Flutter**: UI framework
- **BLoC**: State management
- **GetIt**: Dependency injection
- **HTTP**: API communication
- **Shared Preferences**: Local storage
- **Connectivity Plus**: Network status monitoring

### Back-end
- **Node.js**: Runtime environment
- **Express**: Web framework
- **MongoDB**: Database
- **Mongoose**: ODM
- **JWT**: Authentication
- **Socket.io**: Real-time communication

## 🏗️ Project Structure

```
├── front-end/                # Flutter application
│   ├── lib/
│   │   ├── data/           # Data layer
│   │   ├── domain/         # Business logic layer
│   │   ├── presentation/   # UI layer
│   │   ├── helpers/        # Helper utilities
│   │   ├── services/       # Core services
│   │   └── widgets/        # Shared widgets
│   └── ...
│
└── back-end/                # Node.js server
    ├── src/
    │   ├── config/         # Configuration files
    │   ├── controllers/    # Route controllers
    │   ├── models/         # Database models
    │   ├── routes/         # API routes
    │   ├── services/       # Business logic
    │   └── utils/          # Utility functions
    └── ...
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (>=3.2.3)
- Dart SDK (>=3.0.0)
- Node.js (>=14.0.0)
- MongoDB
- Android Studio / VS Code
- Git

### Front-end Setup

1. Navigate to the front-end directory:
```bash
cd front-end
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Back-end Setup

1. Navigate to the back-end directory:
```bash
cd back-end
```

2. Install dependencies:
```bash
npm install
```

3. Create a `.env` file in the back-end directory with the following variables:
```env
PORT=3000
MONGODB_URI=your_mongodb_uri
JWT_SECRET=your_jwt_secret
```

4. Start the server:
```bash
npm start
```

## 🔧 Configuration

### Front-end
1. Update the API base URL in `front-end/lib/core/config/app_config.dart`
2. Configure your environment variables if needed

### Back-end
1. Update the environment variables in `back-end/.env`
2. Configure MongoDB connection
3. Set up JWT secret

## 📦 Dependencies

### Front-end
- flutter_bloc: ^8.1.3
- get_it: ^7.6.0
- http: ^1.1.0
- shared_preferences: ^2.2.2
- connectivity_plus: ^5.0.2
- equatable: ^2.0.5

### Back-end
- express: ^4.17.1
- mongoose: ^6.0.0
- jsonwebtoken: ^8.5.1
- bcryptjs: ^2.4.3
- cors: ^2.8.5
- dotenv: ^10.0.0

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.


## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Node.js community
- All contributors who have helped shape this project 
