import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/firebase_service.dart';
import '../services/auth_service.dart';

/// Auth state provider for reactive authentication state management
final authProvider = StreamProvider<User?>((ref) {
  return FirebaseService.instance.authStateChanges;
});

/// Current user provider
final currentUserProvider = Provider<User?>((ref) {
  return ref
      .watch(authProvider)
      .when(data: (user) => user, loading: () => null, error: (_, __) => null);
});

/// Auth service provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});
