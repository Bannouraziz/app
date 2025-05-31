# Educational App Back-end

The Node.js back-end server for the Educational App platform.

## 🚀 Features

- RESTful API endpoints
- JWT Authentication
- MongoDB database integration
- Real-time updates with Socket.io
- File upload support
- Data validation
- Error handling middleware
- CORS support

## 🛠️ Tech Stack

- **Node.js**: Runtime environment
- **Express**: Web framework
- **MongoDB**: Database
- **Mongoose**: ODM
- **JWT**: Authentication
- **Socket.io**: Real-time communication
- **Multer**: File uploads
- **Bcrypt**: Password hashing
- **Cors**: Cross-origin resource sharing
- **Dotenv**: Environment variables

## 🏗️ Project Structure

```
src/
├── config/         # Configuration files
│   ├── database.js
│   └── server.js
├── controllers/    # Route controllers
│   ├── authController.js
│   ├── studentController.js
│   └── questionController.js
├── models/         # Database models
│   ├── User.js
│   ├── Student.js
│   └── Question.js
├── routes/         # API routes
│   ├── auth.js
│   ├── students.js
│   └── questions.js
├── services/       # Business logic
│   ├── authService.js
│   └── studentService.js
├── utils/          # Utility functions
│   ├── errorHandler.js
│   └── validators.js
└── app.js          # Application entry point
```

## 🚀 Getting Started

### Prerequisites

- Node.js (>=14.0.0)
- MongoDB
- npm or yarn

### Installation

1. Install dependencies:
```bash
npm install
```

2. Create a `.env` file in the root directory:
```env
PORT=3000
MONGODB_URI=your_mongodb_uri
JWT_SECRET=your_jwt_secret
NODE_ENV=development
```

3. Start the development server:
```bash
npm run dev
```

4. For production:
```bash
npm start
```

## 📚 API Documentation

### Authentication Endpoints

- `POST /api/auth/register` - Register a new user
- `POST /api/auth/login` - Login user
- `POST /api/auth/logout` - Logout user

### Student Endpoints

- `GET /api/students` - Get all students
- `GET /api/students/:id` - Get student by ID
- `POST /api/students` - Create new student
- `PUT /api/students/:id` - Update student
- `DELETE /api/students/:id` - Delete student

### Question Endpoints

- `GET /api/questions` - Get all questions
- `GET /api/questions/:id` - Get question by ID
- `POST /api/questions` - Create new question
- `PUT /api/questions/:id` - Update question
- `DELETE /api/questions/:id` - Delete question

## 🔧 Configuration

### Environment Variables

- `PORT`: Server port (default: 3000)
- `MONGODB_URI`: MongoDB connection string
- `JWT_SECRET`: Secret key for JWT
- `NODE_ENV`: Environment (development/production)

### Database Configuration

Update the MongoDB connection string in `.env`:
```env
MONGODB_URI=mongodb://localhost:27017/educational-app
```

## 📦 Dependencies

- express: ^4.17.1
- mongoose: ^6.0.0
- jsonwebtoken: ^8.5.1
- bcryptjs: ^2.4.3
- cors: ^2.8.5
- dotenv: ^10.0.0
- socket.io: ^4.0.0
- multer: ^1.4.3
- express-validator: ^6.12.1

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](../LICENSE) file for details. 