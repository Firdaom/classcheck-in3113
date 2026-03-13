# Class Check-in App

A Flutter mobile application for student class check-in and learning reflection with GPS location tracking, QR code scanning, and local data persistence.

## Project Description

This application helps universities track student attendance and learning participation by requiring students to:

1. **Check-in Before Class**: Scan QR code, capture GPS location, and record mood + expected topics
2. **Check-out After Class**: Complete second QR scan, record location, and provide learning summary
3. **Track History**: View all attendance records with mood scores and learning notes
4. **Manage Profile**: Update student information and view account details

The app uses local storage for MVP (SharedPreferences) with support for Firebase integration.

## Features

- ✅ User authentication (Sign Up / Login)
- ✅ GPS location tracking
- ✅ QR code scanning (with test mode fallback)
- ✅ Pre-class reflection (mood, topic tracking)
- ✅ Post-class feedback submission
- ✅ Attendance history with filtering
- ✅ Student profile management
- ✅ Local data persistence (SharedPreferences)
- ✅ GoRouter navigation
- ✅ Bottom navigation (Home, History, Profile)

## Tech Stack

- **Framework**: Flutter 3.38.9
- **Language**: Dart 3.10.8
- **State Management**: ChangeNotifier
- **Routing**: GoRouter 14.2.0
- **Local Storage**: SharedPreferences 2.5.3
- **QR Scanning**: mobile_scanner 7.1.2
- **Location**: geolocator 14.0.2
- **Formatting**: intl 0.20.2, google_fonts 6.3.2

## Setup Instructions

### Prerequisites

- Flutter SDK: 3.38.8+
- Dart SDK: 3.10.8+
- Android SDK (for Android development)
- Xcode (for iOS development)

### Installation Steps

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd classcheck-in
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure platform permissions**

   **Android** (`android/app/src/main/AndroidManifest.xml`):
   ```xml
   <uses-permission android:name="android.permission.CAMERA" />
   <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
   <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
   ```

   **iOS** (`ios/Runner/Info.plist`):
   ```xml
   <key>NSCameraUsageDescription</key>
   <string>We need camera access to scan QR codes</string>
   <key>NSLocationWhenInUseUsageDescription</key>
   <string>We need location access for class attendance verification</string>
   ```

4. **Initialize the app**
   ```bash
   flutter clean
   flutter pub get
   ```

## How to Run the App

### Development

1. **Start the app in debug mode**
   ```bash
   flutter run
   ```

2. **Run on specific device**
   ```bash
   flutter devices                    # List available devices
   flutter run -d <device-id>         # Run on specific device
   ```

3. **Release build**
   ```bash
   flutter run --release
   ```

### Testing

1. **Run tests**
   ```bash
   flutter test
   ```

2. **Run analysis**
   ```bash
   flutter analyze
   ```

### Test Mode

For development without GPS/camera constraints:
- Set `_isTestMode = true` in `session_form_screen.dart`
- Auto-fills QR code: `TEST-QR-{timestamp}`
- Allows submission without camera access

## Usage Guide

### First Time Setup

1. **Sign Up**
   - Enter email and password
   - Enter student ID (e.g., STU-240031)
   - Tap "Sign Up"

2. **Login**
   - Use registered email and password
   - Tap "Login"

### Using the App

1. **Home Screen (Dashboard)**
   - Select current class from dropdown
   - Tap "Check-in" to start the session
   - Tap "Finish class" after session ends
   - View latest attendance record

2. **Check-in Flow**
   - Allow location access when prompted
   - Scan class QR code (or use test QR in test mode)
   - Select mood (1-5 scale)
   - Enter previous class topic
   - Enter expected topic for today
   - Submit form

3. **Check-out / Finish Class Flow**
   - Scan class QR code again
   - Allow location access if prompted
   - Enter what you learned today
   - Provide feedback about the class (optional)
   - Submit form

4. **History Tab**
   - View all check-in records with moods and topics
   - View all class completion records
   - See learning summaries and feedback

5. **Profile Tab**
   - View student ID and email
   - Edit Profile button (coming soon)
   - Logout button with confirmation

## Data Storage

### Local Storage (SharedPreferences)

All data is stored locally with the following keys:

```
user_email                  // User's email
user_password              // User's password (encrypted recommended for production)
student_id                 // Student ID
attendance_student_id      // ID for attendance records
attendance_sessions_v1     // JSON array of all sessions
```

### Data Schema

Each attendance session contains:

```json
{
  "classId": "CSC101",
  "className": "Mobile App Development",
  "sessionDate": "2026-03-13",
  "checkIn": {
    "timestamp": "2026-03-13T08:00:00Z",
    "qrCode": "CSC101-QR-2026-13",
    "latitude": 13.7563,
    "longitude": 100.5018,
    "moodScore": 4,
    "previousTopic": "Flutter Widgets",
    "expectedTopic": "State Management"
  },
  "finish": {
    "timestamp": "2026-03-13T09:30:00Z",
    "qrCode": "CSC101-QR-2026-13",
    "latitude": 13.7563,
    "longitude": 100.5018,
    "learnedToday": "Learned about Provider and ChangeNotifier",
    "feedback": "Great explanation from instructor"
  },
  "syncState": "localOnly"
}
```

## Firebase Configuration (For Future Integration)

### Setup Steps

1. **Create Firebase Project**
   - Visit [Firebase Console](https://console.firebase.google.com/)
   - Create new project named `classcheck-in`
   - Add Android and iOS apps

2. **Install Firebase Packages**
   ```bash
   flutter pub add firebase_core
   flutter pub add cloud_firestore
   flutter pub add firebase_auth
   flutter pub add firebase_storage
   ```

3. **Initialize Firebase in main.dart**
   ```dart
   import 'package:firebase_core/firebase_core.dart';
   
   void main() async {
     WidgetsFlutterBinding.ensureInitialized();
     await Firebase.initializeApp();
     // ... rest of initialization
   }
   ```

4. **Create Firestore Collections**
   ```
   users/
   │   ├── {userId}/
   │   │   ├── email: string
   │   │   ├── studentId: string
   │   │   ├── createdAt: timestamp
   │   │   └── updatedAt: timestamp
   
   attendance_sessions/
   │   ├── {sessionId}/
   │   │   ├── userId: string
   │   │   ├── classId: string
   │   │   ├── className: string
   │   │   ├── sessionDate: date
   │   │   ├── checkIn: map
   │   │   ├── finish: map (optional, populated after class)
   │   │   └── syncState: string (localOnly|synced|failed)
   ```

5. **Set Firestore Security Rules**
   ```javascript
   rules_version = '2';
   service cloud.firestore {
     match /databases/{database}/documents {
       match /users/{userId} {
         allow read, write: if request.auth.uid == userId;
       }
       match /attendance_sessions/{sessionId} {
         allow read, write: if request.auth.uid == resource.data.userId;
       }
     }
   }
   ```

6. **Configure Firebase Auth**
   - Enable Email/Password authentication
   - Set up email verification (optional)
   - Configure password reset

### Migration Path

1. Start with local storage (current state)
2. Add Firebase imports and initialization
3. Update `AttendanceStore` to sync with Firestore
4. Batch upload existing local data on first sync
5. Implement offline-first sync strategy

### Environment Configuration

Create `.env` file (add to `.gitignore`):
```
FIREBASE_PROJECT_ID=classcheck-in-xxxxx
FIREBASE_WEB_API_KEY=AIzaSyD...
FIREBASE_APP_ID=1:123456789:android:abcdef...
FIREBASE_STORAGE_BUCKET=classcheck-in-xxxxx.appspot.com
```

## Project Structure

```
lib/
├── config/
│   ├── app_router.dart              # GoRouter configuration
│   └── route_names.dart             # Route enum
├── features/
│   ├── home_screen.dart             # Home/Dashboard screen
│   ├── history_screen.dart          # Attendance history
│   ├── profile_screen.dart          # User profile
│   ├── login_screen.dart            # Login/Sign Up
│   ├── session_form_screen.dart     # Check-in/Check-out form
│   ├── qr_scanner_screen.dart       # QR code scanning
│   └── shell_navigation_screen.dart # Bottom navigation
├── models/
│   └── attendance_session.dart      # Data models
├── services/
│   └── attendance_store.dart        # State management
├── app.dart                         # App root widget
└── main.dart                        # Entry point

android/
├── app/src/main/
│   └── AndroidManifest.xml          # Android permissions

ios/
├── Runner/
│   └── Info.plist                   # iOS permissions
```

## Troubleshooting

### Common Issues

| Issue | Solution |
|-------|----------|
| **Permission Denied (Camera)** | Check device settings > Apps > Permissions. Reinstall app if needed. |
| **Permission Denied (Location)** | Enable Location Services. Grant app permission in settings. |
| **QR Code Not Scanning** | Ensure good lighting. Use test mode for development. |
| **GPS Not Accurate** | May take 5-10 seconds to acquire fix. Use test mode for testing. |
| **Data Disappeared** | Data persists unless app is uninstalled or data is cleared manually. |

### Debug Commands

```bash
# Clear app data
flutter run --purge

# Enable verbose logging
flutter run -v

# Run in debug mode
flutter run --debug

# Check platform channels
flutter devices
```

## Known Limitations (MVP)

- ⚠️ Passwords stored in plain text (use Firebase Auth for production)
- ⚠️ No backend synchronization (local only)
- ⚠️ No offline support for network requests
- ⚠️ No data encryption
- ⚠️ QR code validation is basic (no checksum)

## Performance Notes

- App size: ~50-80 MB (varies by platform)
- Startup time: ~2-3 seconds
- Memory usage: ~100-150 MB average
- Storage: ~1-2 MB per 1000 attendance records

## Future Enhancements

- [ ] Firebase integration for backend sync
- [ ] End-to-end encryption for sensitive data
- [ ] Advanced analytics and reporting
- [ ] Multi-language support
- [ ] Biometric authentication
- [ ] Offline sync queue
- [ ] Admin dashboard for instructors
- [ ] Class statistics and trends


**Last Updated**: March 13, 2026  
**Flutter Version**: 3.38.9  
**Status**: MVP - Development Phase

