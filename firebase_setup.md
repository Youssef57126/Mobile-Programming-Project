# Firebase Setup Guide for Glamora

This guide explains how to set up Firebase for the Glamora e-commerce app.

## 1. Create a Firebase Project
1. Go to [https://console.firebase.google.com](https://console.firebase.google.com)
2. Click "Add project"
3. Name it "Glamora" (or any name)
4. Disable Google Analytics (optional for this project)
5. Click "Create project"

## 2. Add Android App to Firebase
1. In project overview → click Android icon
2. Android package name: `com.example.mobile_project` (check your `android/app/build.gradle`)
3. App nickname: Glamora
4. Register app
5. Download `google-services.json`
6. Place it in `android/app/` folder
7. Add classpath in `android/build.gradle` (project level):


8. Add plugin in `android/app/build.gradle`:

## 3. Add iOS App (Optional for testing)
1. Click iOS icon
2. Bundle ID: same as Android or `com.example.mobile_project`
3. Download `GoogleService-Info.plist`
4. Add to Xcode via Runner folder

## 4. Enable Firebase Services
1. **Authentication**:
- Go to Authentication → Sign-in method
- Enable "Email/Password" and "Google"

2. **Firestore Database**:
- Go to Firestore Database → Create database
- Start in test mode (for development)
- Location: choose closest (e.g., nam5)

## 5. Firestore Rules (Copy to Firestore Rules tab)
```rules
rules_version = '2';
service cloud.firestore {
match /databases/{database}/documents {
 match /users/{userId}/{document=**} {
   allow read, write: if request.auth != null && request.auth.uid == userId;
 }
 // Public products (if you store them in Firestore)
 match /products/{productId} {
   allow read: if true;
   allow write: if false;
 }
}
}
```

## 6. Run the App

flutter pub get
flutter run


