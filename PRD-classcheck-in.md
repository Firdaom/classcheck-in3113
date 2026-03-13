# PRD: Class Check-in

## Problem Statement
Manual attendance and class reflection are often incomplete, inaccurate, or easy to falsify. Instructors need a simple way to confirm that students were physically present before and after class, while also collecting lightweight learning and sentiment data that can improve teaching quality and student engagement.

## Target User
- Primary users: Students attending in-person classes
- Secondary users: Instructors who review attendance, learning reflections, and class feedback
- Admin users: School staff who may manage course, class, and reporting settings

## Product Goal
Build a Flutter mobile app that allows students to check in before class and complete class check-out after class using location, timestamp, and QR verification, while capturing short reflective inputs.

## Feature List
- Student pre-class check-in
- GPS location capture during check-in
- Automatic timestamp recording
- QR code scan for class verification
- Pre-class reflection form:
  - Previous class topic
  - Expected topic for today
  - Mood before class on a 1 to 5 scale
- Student post-class completion flow
- GPS location capture during finish-class flow
- Second QR code scan for end-of-class verification
- Post-class reflection form:
  - What the student learned today
  - Feedback about the class or instructor
- Basic validation to require all mandatory fields before submission
- Storage of attendance and reflection records for instructor review

## User Flow
### Before Class
1. Student opens the app and selects the current class.
2. Student presses **Check-in**.
3. App records the current GPS location and timestamp.
4. Student scans the class QR code.
5. Student fills in:
   - Topic covered in the previous class
   - Topic expected today
   - Mood before class
6. Student submits the check-in record.

### After Class
1. Student opens the class session and presses **Finish Class**.
2. Student scans the class QR code again.
3. App records the current GPS location and timestamp.
4. Student fills in:
   - What they learned today
   - Feedback about the class or instructor
5. Student submits the class completion record.

## Data Fields
### Check-in Record
- Student ID
- Class ID
- Session ID or date
- Check-in timestamp
- Check-in GPS latitude
- Check-in GPS longitude
- QR verification result
- Previous class topic
- Expected topic today
- Mood score (1 to 5)

### Finish Class Record
- Student ID
- Class ID
- Session ID or date
- Finish timestamp
- Finish GPS latitude
- Finish GPS longitude
- QR verification result
- Learned today summary
- Class or instructor feedback

## Functional Requirements
- The app must require GPS permission before location-based attendance is submitted.
- The app must require QR scanning for both check-in and finish-class submission.
- The app must save timestamps automatically and prevent manual editing.
- The app must validate required text fields and mood selection before submission.
- The app should handle weak internet conditions with retry or queued submission behavior.

## Non-Functional Requirements
- Mobile-first experience for Android and iOS
- Simple flow that can be completed within 30 to 60 seconds
- Secure storage and transmission of attendance data
- Responsive UI with clear status feedback for scan, location, and submission states

## Tech Stack
- Frontend: Flutter
- Language: Dart
- State management: Provider, Riverpod, or Bloc
- QR scanning: Flutter package such as `mobile_scanner`
- Location services: Flutter package such as `geolocator`
- Backend: Firebase or REST API service
- Database: Firestore, Supabase, or relational database via backend API
- Authentication: Firebase Auth or institution account login

## Success Criteria
- Students can complete check-in and finish-class flows without staff assistance.
- Attendance records contain valid timestamp, GPS, and QR verification data.
- Instructors can review attendance, reflections, and feedback per class session.
- The submission completion rate is high for both pre-class and post-class flows.
