import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:exam_ready/services/firebase_service.dart';
import 'package:exam_ready/providers/auth_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'firebase_test_helper.dart';

void main() {
  group('Firebase Integration Tests', () {
    setUpAll(() async {
      await FirebaseTestHelper.initializeFirebase();
    });

    test('Firebase Service initialization', () async {
      // Test Firebase service singleton
      final firebaseService = FirebaseService.instance;
      expect(firebaseService, isNotNull);
      expect(firebaseService.isInitialized, isTrue);
    });

    test('Firebase Auth state changes', () async {
      // Test auth state stream
      final authStream = FirebaseService.instance.authStateChanges;
      expect(authStream, isNotNull);
    });

    test('Firebase Firestore instance', () async {
      // Test Firestore instance
      final firestore = FirebaseService.instance.firestore;
      expect(firestore, isNotNull);
    });

    test('Firebase Storage instance', () async {
      // Test Storage instance
      final storage = FirebaseService.instance.storage;
      expect(storage, isNotNull);
    });

    testWidgets('Auth provider works correctly', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: Consumer(
                builder: (context, ref, child) {
                  final authState = ref.watch(authProvider);
                  return authState.when(
                    data: (user) => Text(user?.uid ?? 'No user'),
                    loading: () => const CircularProgressIndicator(),
                    error: (error, stack) => Text('Error: $error'),
                  );
                },
              ),
            ),
          ),
        ),
      );

      await tester.pump();
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
