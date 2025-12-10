import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  // Firebase Auth instance
  final FirebaseAuth _auth = FirebaseAuth.instance;

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

  // Sign Up with Email and Password
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

      // Update display name and reload user to persist changes
      await result.user?.updateDisplayName(name);
      await result.user?.reload();

      // Get updated user
      User? updatedUser = _auth.currentUser;

      return {
        'success': true,
        'message': 'Account created successfully!',
        'user': updatedUser,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Sign In with Email and Password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      return {
        'success': true,
        'message': 'Login successful!',
        'user': result.user,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Reset Password
  Future<Map<String, dynamic>> resetPassword({required String email}) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());

      return {
        'success': true,
        'message': 'Password reset email sent! Check your inbox.',
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'An unexpected error occurred. Please try again.',
      };
    }
  }

  // Sign Out (generic)
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Update User Profile
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
      User? updatedUser = _auth.currentUser;

      return {
        'success': true,
        'message': 'Profile updated successfully!',
        'user': updatedUser,
      };
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to update profile. Please try again.',
      };
    }
  }

  // Delete Account
  Future<Map<String, dynamic>> deleteAccount() async {
    try {
      User? user = _auth.currentUser;

      if (user == null) {
        return {'success': false, 'message': 'No user is currently signed in.'};
      }

      await user.delete();

      return {'success': true, 'message': 'Account deleted successfully.'};
    } on FirebaseAuthException catch (e) {
      return {'success': false, 'message': _getErrorMessage(e.code)};
    } catch (e) {
      return {
        'success': false,
        'message': 'Failed to delete account. Please try again.',
      };
    }
  }

  // Get user-friendly error messages
  String _getErrorMessage(String code) {
    switch (code) {
      case 'weak-password':
        return 'Password is too weak. Use at least 6 characters.';
      case 'email-already-in-use':
        return 'An account already exists with this email.';
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'invalid-email':
        return 'Invalid email address format.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later.';
      case 'operation-not-allowed':
        return 'Email/password accounts are not enabled.';
      case 'network-request-failed':
        return 'Network error. Check your internet connection.';
      case 'invalid-credential':
        return 'The credentials provided are invalid or expired.';
      case 'account-exists-with-different-credential':
        return 'An account exists with the same email but different sign-in credentials.';
      case 'invalid-verification-code':
        return 'Invalid verification code. Please try again.';
      case 'invalid-verification-id':
        return 'Invalid verification ID. Please request a new code.';
      case 'expired-action-code':
        return 'This verification code has expired. Request a new one.';
      case 'invalid-action-code':
        return 'This verification code is invalid or already used.';
      case 'requires-recent-login':
        return 'Please log in again to perform this action.';
      default:
        return 'Authentication error: $code. Please try again.';
    }
  }

  // Google Sign-In (web + mobile)
  Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      UserCredential userCredential;

      if (kIsWeb) {
        // 🔹 WEB: use Firebase signInWithPopup
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        googleProvider.setCustomParameters({
          'prompt': 'select_account',
        });

        userCredential = await _auth.signInWithPopup(googleProvider);
      } else {
        // 🔹 MOBILE: use google_sign_in plugin
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

      return {
        'success': true,
        'message': 'Signed in successfully with Google!',
        'user': userCredential.user,
      };
    } on FirebaseAuthException catch (e) {
      return {
        'success': false,
        'message': e.message ?? 'Google Sign-In failed',
      };
    } catch (e) {
      return {
        'success': false,
        'message': 'An error occurred: ${e.toString()}',
      };
    }
  }

  /// Sign out from Google + Firebase
  Future<void> signOutGoogle() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }
}
