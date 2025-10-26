import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Centralized Firebase service to prevent multiple instance creation
/// and ensure proper resource management
class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();

  FirebaseService._();

  // Firebase Core
  FirebaseApp get app => Firebase.app();

  // Firebase Auth
  FirebaseAuth get auth => FirebaseAuth.instance;

  // Firestore
  FirebaseFirestore get firestore => FirebaseFirestore.instance;

  // Storage
  FirebaseStorage get storage => FirebaseStorage.instance;

  /// Initialize Firebase (should be called once in main.dart)
  static Future<void> initialize() async {
    await Firebase.initializeApp();
  }

  /// Check if Firebase is initialized
  bool get isInitialized => Firebase.apps.isNotEmpty;

  /// Get current user
  User? get currentUser => auth.currentUser;

  /// Auth state changes stream
  Stream<User?> get authStateChanges => auth.authStateChanges();

  /// Dispose resources (call on app termination)
  static Future<void> dispose() async {
    // Firebase services don't need explicit disposal
    // but we can clear our singleton
    _instance = null;
  }
}
