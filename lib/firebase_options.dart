
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCSVOy0_MPfz1H3opzj2aYhV22GZHmb3Jo',
    appId: '1:911973583663:web:7ae2172815ba819515afda',
    messagingSenderId: '911973583663',
    projectId: 'exam-ready-13',
    authDomain: 'exam-ready-13.firebaseapp.com',
    storageBucket: 'exam-ready-13.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDtRTijTZ1xICZlxjPFV5zu6L_1jKHuK7o',
    appId: '1:911973583663:android:18aad3a4c9ee86f715afda',
    messagingSenderId: '911973583663',
    projectId: 'exam-ready-13',
    storageBucket: 'exam-ready-13.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAMQaHHEIt9pfTtVTvB2jPN1u6I1RNwjlo',
    appId: '1:911973583663:ios:95badcd1315895f615afda',
    messagingSenderId: '911973583663',
    projectId: 'exam-ready-13',
    storageBucket: 'exam-ready-13.firebasestorage.app',
    iosBundleId: 'com.example.examReady',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAMQaHHEIt9pfTtVTvB2jPN1u6I1RNwjlo',
    appId: '1:911973583663:ios:95badcd1315895f615afda',
    messagingSenderId: '911973583663',
    projectId: 'exam-ready-13',
    storageBucket: 'exam-ready-13.firebasestorage.app',
    iosBundleId: 'com.example.examReady',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCSVOy0_MPfz1H3opzj2aYhV22GZHmb3Jo',
    appId: '1:911973583663:web:4e3a1c169dad547515afda',
    messagingSenderId: '911973583663',
    projectId: 'exam-ready-13',
    authDomain: 'exam-ready-13.firebaseapp.com',
    storageBucket: 'exam-ready-13.firebasestorage.app',
  );

}