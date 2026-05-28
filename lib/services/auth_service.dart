// lib/services/auth_service.dart

import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:exam_ready/utils/api_error_handler.dart';
import 'package:exam_ready/utils/constants.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Google Sign-In instance (used only on mobile)
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    clientId: kIsWeb
        ? '911973583663-ciict72ribfd16shrdnd59sr22vvidre.apps.googleusercontent.com'
        : null,
  );

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Stream of auth state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Check if current user's email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // ─── Sign Up ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(name);
      await result.user?.reload();

      // Send verification email
      await result.user?.sendEmailVerification();

      // Create user document in Firestore
      final user = _auth.currentUser;
      if (user != null) {
        await _createUserDocument(user, name: name);
      }

      return {
        'success': true,
        'message': 'Account created! Please verify your email.',
        'user': _auth.currentUser,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': ApiErrorHandler.getReadableError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': ApiErrorHandler.getReadableError(e),
      };
    }
  }

  // ─── Sign In ───────────────────────────────────────────────────

  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update last active timestamp
      if (result.user != null) {
        await _updateLastActive(result.user!.uid);
      }

      return {
        'success': true,
        'message': 'Login successful!',
        'user': result.user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': ApiErrorHandler.getReadableError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': ApiErrorHandler.getReadableError(e),
      };
    }
  }

  // ─── Google Sign-In ────────────────────────────────────────────

  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({'prompt': 'select_account'});
        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

        if (googleUser == null) {
          return {
            'success': false,
            'message': 'Google Sign-In was cancelled',
          };
        }

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final OAuthCredential credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCredential = await _auth.signInWithCredential(credential);
      }

      // Create/update user document
      if (userCredential.user != null) {
        await _createUserDocument(
          userCredential.user!,
          name: userCredential.user!.displayName,
        );
      }

      return {
        'success': true,
        'message': 'Signed in successfully with Google!',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': ApiErrorHandler.getReadableError(e),
      };
    } catch (e) {
      developer.log(
        'Google sign-in error',
        name: 'AuthService',
        error: e,
      );
      return {
        'success': false,
        'message': ApiErrorHandler.getReadableError(e),
      };
    }
  }

  // ─── Email Verification ────────────────────────────────────────

  /// Send email verification to current user
  Future<Map<String, dynamic>> sendEmailVerification() async {
    try {
      final user = _auth.currentUser;
      if (user == null) {
        return {'success': false, 'message': 'No user signed in.'};
      }

      if (user.emailVerified) {
        return {'success': true, 'message': 'Email already verified.'};
      }

      await user.sendEmailVerification();
      return {
        'success': true,
        'message': 'Verification email sent! Check your inbox.',
      };
    } catch (e) {
      return {
        'success': false,
        'message': ApiErrorHandler.getReadableError(e),
      };
    }
  }

  /// Reload user and check if email is now verified
  Future<bool> checkEmailVerified() async {
    try {
      await _auth.currentUser?.reload();
      return _auth.currentUser?.emailVerified ?? false;
    } catch (e) {
      developer.log(
        'Error checking email verification',
        name: 'AuthService',
        error: e,
      );
      return false;
    }
  }

  // ─── Reset Password ────────────────────────────────────────────

  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return {
        'success': true,
        'message': 'Password reset email sent! Check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': ApiErrorHandler.getReadableError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': ApiErrorHandler.getReadableError(e),
      };
    }
  }

  // ─── Sign Out ──────────────────────────────────────────────────

  /// Complete sign out: Firebase Auth + Google + state cleanup.
  ///
  /// When using Riverpod, the caller should also invalidate all
  /// user-dependent providers after calling this.
  Future<void> signOut() async {
    try {
      // Sign out from Google if applicable
      if (!kIsWeb) {
        try {
          await _googleSignIn.signOut();
        } catch (_) {
          // Ignore Google sign-out errors
        }
      }

      // Sign out from Firebase
      await _auth.signOut();

      developer.log('User signed out successfully', name: 'AuthService');
    } catch (e) {
      developer.log('Error during sign out', name: 'AuthService', error: e);
      // Still try to sign out from Firebase even if Google fails
      await _auth.signOut();
    }
  }

  /// Sign out from Google + Firebase (backward compatibility)
  Future<void> signOutGoogle() async => signOut();

  // ─── Update Profile ────────────────────────────────────────────

  Future<Map<String, dynamic>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return {'success': false, 'message': 'No user is currently signed in.'};
      }

      if (displayName != null) {
        await user.updateDisplayName(displayName);
      }

      if (photoURL != null) {
        await user.updatePhotoURL(photoURL);
      }

      await user.reload();

      // Update Firestore document too
      final updates = <String, dynamic>{};
      if (displayName != null) updates['name'] = displayName;
      if (photoURL != null) updates['photoUrl'] = photoURL;
      updates['lastActive'] = FieldValue.serverTimestamp();

      if (updates.isNotEmpty) {
        await _firestore
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set(updates, SetOptions(merge: true));
      }

      return {
        'success': true,
        'message': 'Profile updated successfully!',
        'user': _auth.currentUser,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': ApiErrorHandler.getReadableError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': ApiErrorHandler.getReadableError(e),
      };
    }
  }

  // ─── Delete Account ────────────────────────────────────────────

  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return {'success': false, 'message': 'No user is currently signed in.'};
      }

      await user.delete();

      return {'success': true, 'message': 'Account deleted successfully.'};
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': ApiErrorHandler.getReadableError(e),
      };
    } catch (e) {
      return {
        'success': false,
        'message': ApiErrorHandler.getReadableError(e),
      };
    }
  }

  // ─── Private Helpers ───────────────────────────────────────────

  /// Create or merge user document in Firestore on sign up / first sign in
  Future<void> _createUserDocument(User user, {String? name}) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .set({
        'uid': user.uid,
        'email': user.email ?? '',
        'name': name ?? user.displayName ?? '',
        'photoUrl': user.photoURL ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
        'role': 'user',
        'papersUploaded': 0,
        'contributorXP': 0,
        'streakDays': 0,
        'badges': [],
        'bookmarkedPapers': [],
      }, SetOptions(merge: true));
    } catch (e) {
      developer.log(
        'Error creating user document',
        name: 'AuthService',
        error: e,
      );
      // Non-fatal: don't block auth flow
    }
  }

  /// Update last active timestamp
  Future<void> _updateLastActive(String userId) async {
    try {
      await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .set(
        {'lastActive': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );
    } catch (_) {
      // Non-fatal
    }
  }
}
