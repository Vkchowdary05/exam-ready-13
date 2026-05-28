// lib/providers/user_provider.dart
//
// Riverpod providers for user profile data.

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_ready/models/user_model.dart';
import 'package:exam_ready/utils/constants.dart';

/// Current Firebase Auth user stream
final authUserProvider = StreamProvider.autoDispose<User?>((ref) {
  return FirebaseAuth.instance.authStateChanges();
});

/// Current user's Firestore profile document
final userProfileProvider =
    StreamProvider.autoDispose<UserModel?>((ref) {
  final authUser = ref.watch(authUserProvider);

  return authUser.when(
    data: (user) {
      if (user == null) return Stream.value(null);

      return FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .doc(user.uid)
          .snapshots()
          .map((doc) {
        if (!doc.exists) return null;
        return UserModel.fromFirestore(doc);
      });
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

/// Current user's bookmarked paper IDs
final bookmarkedPapersProvider =
    Provider.autoDispose<List<String>>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile.when(
    data: (user) => user?.bookmarkedPapers ?? [],
    loading: () => [],
    error: (_, __) => [],
  );
});

/// Whether onboarding is completed
final onboardingCompletedProvider = Provider.autoDispose<bool>((ref) {
  final profile = ref.watch(userProfileProvider);
  return profile.when(
    data: (user) => user?.hasCompletedOnboarding ?? false,
    loading: () => false,
    error: (_, __) => false,
  );
});
