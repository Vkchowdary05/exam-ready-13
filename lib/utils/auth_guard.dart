// lib/utils/auth_guard.dart

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:exam_ready/screens/auth/login_screen.dart';

/// Wraps any screen that requires authentication.
///
/// Usage in router or direct navigation:
/// ```dart
/// AuthGuard(child: const DashboardScreen())
/// ```
///
/// Behavior:
/// 1. Shows a loading splash while checking auth state
/// 2. If user is null → redirects to LoginScreen
/// 3. If user is authenticated → renders the child
class AuthGuard extends StatelessWidget {
  final Widget child;

  const AuthGuard({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Still checking auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const _AuthLoadingScreen();
        }

        // Not authenticated
        if (!snapshot.hasData || snapshot.data == null) {
          return const LoginScreen();
        }

        // Authenticated — render protected content
        return child;
      },
    );
  }

  /// Static helper for wrapping any widget inline
  static Widget guard({required Widget child}) {
    return AuthGuard(child: child);
  }
}

/// Minimal loading screen shown while Firebase checks auth state.
class _AuthLoadingScreen extends StatelessWidget {
  const _AuthLoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Color(0xFF0B2B32), // darkBg from BRIK palette
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'EXAM READY',
              style: TextStyle(
                color: Color(0xFFF5F2EB), // cream text
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
                valueColor:
                    AlwaysStoppedAnimation<Color>(Color(0xFFCBC5F0)), // lavender
              ),
            ),
          ],
        ),
      ),
    );
  }
}
