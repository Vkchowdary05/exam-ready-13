import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform, TargetPlatform;

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  // 🌐 Web
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCSVOy0_MPfz1H3opzj2aYhV22GZHmb3Jo',
    appId: '1:911973583663:web:7ae2172815ba819515afda',
    messagingSenderId: '911973583663',
    projectId: 'exam-ready-13',
    authDomain: 'exam-ready-13.firebaseapp.com',
    storageBucket: 'exam-ready-13.appspot.com',
    measurementId: 'G-XXXXXXXXXX', // Replace with your Analytics ID if needed
  );

  // 🤖 Android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDtRTijTZ1xICZlxjPFV5zu6L_1jKHuK7o',
    appId: '1:911973583663:android:18aad3a4c9ee86f715afda',
    messagingSenderId: '911973583663',
    projectId: 'exam-ready-13',
    storageBucket: 'exam-ready-13.appspot.com',
  );

  // 🍎 iOS
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAMQaHHEIt9pfTtVTvB2jPN1u6I1RNwjlo',
    appId: '1:911973583663:ios:95badcd1315895f615afda',
    messagingSenderId: '911973583663',
    projectId: 'exam-ready-13',
    storageBucket: 'exam-ready-13.appspot.com',
    iosBundleId: 'com.example.examReady',
  );

  // 💻 macOS
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAMQaHHEIt9pfTtVTvB2jPN1u6I1RNwjlo',
    appId: '1:911973583663:ios:95badcd1315895f615afda',
    messagingSenderId: '911973583663',
    projectId: 'exam-ready-13',
    storageBucket: 'exam-ready-13.appspot.com',
    iosBundleId: 'com.example.examReady',
  );

  // 🪟 Windows
  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCSVOy0_MPfz1H3opzj2aYhV22GZHmb3Jo',
    appId: '1:911973583663:web:4e3a1c169dad547515afda',
    messagingSenderId: '911973583663',
    projectId: 'exam-ready-13',
    authDomain: 'exam-ready-13.firebaseapp.com',
    storageBucket: 'exam-ready-13.appspot.com',
  );
}
