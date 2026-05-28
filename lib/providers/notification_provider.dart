// lib/providers/notification_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_ready/models/notification_model.dart';
import 'package:exam_ready/utils/constants.dart';

/// Stream of user's notifications (real, not hardcoded)
final notificationsProvider =
    StreamProvider.autoDispose<List<AppNotification>>((ref) {
  final user = FirebaseAuth.instance.currentUser;
  if (user == null) return Stream.value([]);

  return FirebaseFirestore.instance
      .collection(AppConstants.notificationsCollection)
      .where('userId', isEqualTo: user.uid)
      .orderBy('createdAt', descending: true)
      .limit(30)
      .snapshots()
      .map((snap) => snap.docs
          .map((doc) => AppNotification.fromFirestore(doc))
          .toList());
});

/// Unread notification count
final unreadNotificationCountProvider =
    Provider.autoDispose<int>((ref) {
  final notifs = ref.watch(notificationsProvider);
  return notifs.when(
    data: (list) => list.where((n) => !n.read).length,
    loading: () => 0,
    error: (_, __) => 0,
  );
});
