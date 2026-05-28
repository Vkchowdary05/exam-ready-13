// lib/utils/api_error_handler.dart

import 'dart:async';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Converts raw exceptions from Firebase, HTTP, and third-party services
/// into human-readable error messages suitable for display to students.
///
/// Usage:
/// ```dart
/// try {
///   await someFirebaseCall();
/// } catch (e) {
///   showSnackBar(ApiErrorHandler.getReadableError(e));
/// }
/// ```
class ApiErrorHandler {
  ApiErrorHandler._();

  /// Convert any error/exception into a user-friendly string.
  static String getReadableError(dynamic error) {
    // ── Firebase Auth ──────────────────────────────────────────────
    if (error is FirebaseAuthException) {
      return _authError(error.code);
    }

    // ── Firestore / Firebase ───────────────────────────────────────
    if (error is FirebaseException) {
      return _firestoreError(error.code);
    }

    // ── Network ────────────────────────────────────────────────────
    if (error is SocketException) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (error is TimeoutException) {
      return 'The request timed out. Please check your connection and try again.';
    }

    if (error is HttpException) {
      return 'A network error occurred. Please try again.';
    }

    // ── String-based heuristics (for wrapped errors) ───────────────
    final msg = error.toString();

    if (msg.contains('SocketException') ||
        msg.contains('Connection refused') ||
        msg.contains('Network is unreachable')) {
      return 'No internet connection. Please check your network and try again.';
    }

    if (msg.contains('TimeoutException')) {
      return 'The request timed out. Please check your connection and try again.';
    }

    if (msg.contains('PERMISSION_DENIED') ||
        msg.contains('permission-denied')) {
      return 'You don\'t have permission to perform this action.';
    }

    if (msg.contains('NOT_FOUND')) {
      return 'The requested data was not found.';
    }

    if (msg.contains('ALREADY_EXISTS')) {
      return 'This item already exists.';
    }

    if (msg.contains('quota') || msg.contains('RESOURCE_EXHAUSTED')) {
      return 'Service limit reached. Please try again later.';
    }

    // ── Fallback ───────────────────────────────────────────────────
    return 'Something went wrong. Please try again.';
  }

  /// Firebase Auth error codes → friendly messages
  static String _authError(String code) {
    return switch (code) {
      'user-not-found' => 'No account found with this email.',
      'wrong-password' => 'Incorrect password. Please try again.',
      'email-already-in-use' =>
        'An account with this email already exists. Try logging in instead.',
      'weak-password' => 'Password must be at least 6 characters.',
      'invalid-email' => 'Please enter a valid email address.',
      'user-disabled' => 'This account has been disabled. Contact support.',
      'too-many-requests' =>
        'Too many attempts. Please wait a few minutes and try again.',
      'operation-not-allowed' =>
        'This sign-in method is not enabled. Contact support.',
      'network-request-failed' =>
        'No internet connection. Please check your network.',
      'invalid-credential' =>
        'Invalid credentials. Please check your email and password.',
      'account-exists-with-different-credential' =>
        'An account exists with this email but a different sign-in method.',
      'requires-recent-login' =>
        'For security, please log in again before making this change.',
      'expired-action-code' =>
        'This link has expired. Please request a new one.',
      'invalid-action-code' =>
        'This link is invalid or has already been used.',
      _ => 'Authentication error. Please try again.',
    };
  }

  /// Firestore error codes → friendly messages
  static String _firestoreError(String code) {
    return switch (code) {
      'permission-denied' =>
        'You don\'t have permission to do that.',
      'unavailable' =>
        'Service temporarily unavailable. Please try again shortly.',
      'not-found' => 'The requested data was not found.',
      'already-exists' => 'This item already exists.',
      'resource-exhausted' =>
        'Service limit reached. Please try again tomorrow.',
      'cancelled' => 'The operation was cancelled.',
      'deadline-exceeded' =>
        'The request took too long. Please try again.',
      'data-loss' =>
        'Data loss detected. Please contact support.',
      'unauthenticated' =>
        'You need to be logged in. Please sign in and try again.',
      _ => 'Something went wrong. Please try again.',
    };
  }
}
