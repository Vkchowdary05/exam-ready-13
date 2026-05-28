// lib/main.dart

import 'dart:developer' as developer;

import 'package:exam_ready/screens/ui/entry_screen.dart';
import 'package:exam_ready/screens/ui/home.dart';
import 'package:exam_ready/services/firebase_service.dart';
import 'package:exam_ready/theme/app_theme.dart';
import 'package:exam_ready/providers/theme_provider.dart';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ── SECURITY FIX: Removed dotenv.load() ───────────────────────
  // The .env file was bundled as a Flutter asset, exposing API keys
  // in the compiled binary. All sensitive keys are now server-side
  // in Cloud Functions config. No client-side .env is needed.
  // ──────────────────────────────────────────────────────────────

  try {
    // Firebase initialization
    await FirebaseService.initialize();

    // 🔐 App Check (web only)
    if (kIsWeb) {
      // ReCAPTCHA site key is a PUBLIC key (safe to embed)
      const recaptchaSiteKey = String.fromEnvironment(
        'RECAPTCHA_SITE_KEY',
        defaultValue: '6Lcn2iUsAAAAALbUU6ADw3HG30_pL9gEJGVmG0wG',
      );

      await FirebaseAppCheck.instance.activate(
        webProvider: ReCaptchaV3Provider(recaptchaSiteKey),
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

/// Root auth gate — checks if user is authenticated.
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: Color(0xFF0B2B32),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'EXAM READY',
                    style: TextStyle(
                      color: Color(0xFFF5F2EB),
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 2.0,
                    ),
                  ),
                  SizedBox(height: 24),
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFCBC5F0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        // Authenticated
        if (snapshot.hasData && snapshot.data != null) {
          return const DashboardScreen().animate().fadeIn(duration: 600.ms);
        }

        // Not authenticated
        return const EntryScreen().animate().fadeIn(duration: 600.ms);
      },
    );
  }
}
