import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBhLd1r3JQ6AvJPhF2OqDXIJl3SIltbklU',
    appId: '1:962792463176:web:e1d351d41ca084dc2f317d',
    messagingSenderId: '962792463176',
    projectId: 'auth-c7e59',
    authDomain: 'auth-c7e59.firebaseapp.com',
    storageBucket: 'auth-c7e59.firebasestorage.app',
  );

  static FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC2Si2m7Kqhj0GIw3vD5eOiFYqmlZMHXdg',
    appId: '1:962792463176:android:8a9ca2e6d195c00a2f317d',
    messagingSenderId: '962792463176',
    projectId: 'auth-c7e59',
    storageBucket: 'auth-c7e59.firebasestorage.app',
  );

  static FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCxyQzQwKclw3LuKcYKzlJc0DgeH3GrzAk',
    appId: '1:962792463176:ios:7469cb3cb9c356c12f317d',
    messagingSenderId: '962792463176',
    projectId: 'auth-c7e59',
    storageBucket: 'auth-c7e59.firebasestorage.app',
    iosBundleId: 'com.example.mobileProject',
  );

  static FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCxyQzQwKclw3LuKcYKzlJc0DgeH3GrzAk',
    appId: '1:962792463176:ios:7469cb3cb9c356c12f317d',
    messagingSenderId: '962792463176',
    projectId: 'auth-c7e59',
    storageBucket: 'auth-c7e59.firebasestorage.app',
    iosBundleId: 'com.example.mobileProject',
  );

  static FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyBhLd1r3JQ6AvJPhF2OqDXIJl3SIltbklU',
    appId: '1:962792463176:web:c540dad5e71695a32f317d',
    messagingSenderId: '962792463176',
    projectId: 'auth-c7e59',
    authDomain: 'auth-c7e59.firebaseapp.com',
    storageBucket: 'auth-c7e59.firebasestorage.app',
  );
}
