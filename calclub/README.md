# 🏃‍♂️ The Cal Club
**Flutter + Node.js + MongoDB**

## 📌 Internship Assignment Submission

This project is a cross-platform Health & Fitness mobile application built using Flutter, integrated with Google Health Connect (Android) and Apple HealthKit (iOS), with a Node.js + MongoDB backend.

The application demonstrates clean architecture, BLoC state management, background health data sync, and RESTful backend integration.

---

## 📱 Project Overview

The app allows users to:
- Fetch daily step count and workout data
- View health metrics in a clean UI
- Sync health data to a backend server
- Store and retrieve data from MongoDB
- Perform background synchronization on Android and iOS

---

## 🧱 Tech Stack

### Frontend
- Flutter
- Dart
- BLoC (State Management)
- Health Package
- Google Health Connect (Android)
- Apple HealthKit (iOS)

### Backend
- Node.js
- Express.js
- MongoDB
- Mongoose

---

## 🗂️ Project Structure

### Flutter Application
```
health_fitness_app/
├── lib/
│   ├── core/services/
│   ├── data/models/
│   ├── data/repositories/
│   ├── domain/entities/
│   ├── domain/repositories/
│   ├── logic/
│   ├── presentation/screens/
│   └── main.dart
├── android/
└── ios/
```

### Backend
```
backend/
├── models/
├── routes/
├── server.js
├── package.json
└── .env
```

---

## ⚙️ Setup Instructions

### 1. Flutter Setup

```bash
cd calclub
flutter pub get
```

Update backend URL:
```
lib/data/repositories/health_repository_impl.dart
```

```dart
static const String backendUrl = 'http://YOUR_IP_ADDRESS:3000';
```

- Android Emulator: `http://10.0.2.2:3000`
- iOS Simulator: `http://localhost:3000`
- Physical Device: `http://<your-ip>:3000`

---

### 2. Backend Setup

```bash
cd backend
npm install
```

Create `.env` file:
```env
PORT=3000
MONGODB_URI=mongodb://localhost:27017/health_fitness_db
```

Start server:
```bash
npm run dev
# or
npm start
```

---

## 🚀 Running the Application

```bash
flutter devices
flutter run
```

---

## 🧪 Testing

- Grant health permissions on first launch
- Add sample data using Google Fit / Apple Health
- Refresh data in the app
- Use sync button to send data to backend

Test backend:
```bash
curl http://localhost:3000/api/health/steps/user_123
```

---

## ✅ Features Implemented

- Daily step tracking
- Workout history
- Backend data sync
- Background sync support
- Clean Architecture
- BLoC state management
- RESTful APIs

---

## 🏗️ Architecture Overview

- **Domain Layer**: Business logic & entities
- **Data Layer**: API & platform integrations
- **Logic Layer**: BLoC (Events, States)
- **Presentation Layer**: UI & Screens

---

## 🔐 Security Notes

For production use:
- Implement authentication (JWT)
- Use HTTPS
- Secure MongoDB credentials
- Add request validation

---

## 🚀 Future Enhancements

- Charts and analytics
- User authentication
- Offline caching
- Reports and insights
- Notifications

---

## 📌 Conclusion

This project demonstrates end-to-end Flutter and backend development, health data integration, and scalable architecture, making it suitable for an internship-level technical assignment.

---

**Submitted by:**  
**Harshil Khandelwal**  
_Pre-Final Year CSE Student_
