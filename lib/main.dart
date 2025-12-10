// lib/main.dart

import 'dart:developer' as developer;

import 'package:exam_ready/screens/ui/entry_screen.dart';
import 'package:exam_ready/screens/ui/home.dart';
import 'package:exam_ready/services/firebase_service.dart';
import 'package:exam_ready/theme/app_theme.dart';
import 'package:exam_ready/providers/theme_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';       // 👈 NEW
import 'package:flutter/foundation.dart' show kIsWeb;              // 👈 NEW
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");

  try {
    // Your custom Firebase init
    await FirebaseService.initialize();

    // 🔐 App Check only on Web
    if (kIsWeb) {
      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider(
          '6Lcn2iUsAAAAALbUU6ADw3HG30_pL9gEJGVmG0wG', // 👈 SITE KEY (public), not secret
        ),
      );

      developer.log(
        'Firebase App Check (web) activated',
        name: 'FirebaseAppCheck',
      );
    }

    developer.log(
      'Firebase Initialized: ${Firebase.app().name}',
      name: 'FirebaseInit',
    );
  } catch (e, s) {
    developer.log(
      'Firebase init failed',
      error: e,
      stackTrace: s,
      name: 'FirebaseInitError',
    );
  }

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen().animate().fadeIn(duration: 600.ms);
        }

        return const EntryScreen().animate().fadeIn(duration: 600.ms);
      },
    );
  }
}
