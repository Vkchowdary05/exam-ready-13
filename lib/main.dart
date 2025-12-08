// lib/main.dart

import 'dart:developer' as developer;

import 'package:exam_ready/screens/ui/entry_screen.dart';
import 'package:exam_ready/screens/ui/home.dart'; // must contain DashboardScreen
import 'package:exam_ready/services/firebase_service.dart';
import 'package:exam_ready/theme/app_theme.dart';
import 'package:exam_ready/providers/theme_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load .env variables
  await dotenv.load(fileName: ".env");

  try {
    // Firebase init
    await FirebaseService.initialize();

    developer.log(
      'Firebase Initialized: ${Firebase.app().name}',
      name: 'FirebaseInit',
    );
  } catch (e) {
    developer.log(
      'Firebase init failed',
      error: e,
      name: 'FirebaseInitError',
    );
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch light/dark mode dynamically
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'Exam Ready',
      debugShowCheckedModeBanner: false,

      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: themeMode,

      home: const AuthGate(),
    );
  }
}

// ========================================
// 🔐 Auth Gate → Keeps User Logged In
// ========================================

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(), // session listener
      builder: (context, snapshot) {
        // Show loading while checking login state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // If user is logged in → go to Dashboard
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen().animate().fadeIn(duration: 600.ms);
        }

        // Otherwise → Entry screen
        return const EntryScreen().animate().fadeIn(duration: 600.ms);
      },
    );
  }
}