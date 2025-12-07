// lib/services/firestore_service.dart

import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Preferred submit method — returns the created document ID.
  /// - Stores userId + userName in submitted_papers
  /// - Creates a reference under users/{uid}/submitted_papers/{paperId}
  Future<String> submitQuestionPaper({
    required String college,
    required String branch,
    required String semester,
    required String subject,
    required String examType,
    required String imageUrl,
    String? userId,
  }) async {
    try {
      // resolve userId (from param or FirebaseAuth)
      userId ??= _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in. Cannot submit paper.');
      }

      developer.log(
        'Attempting to create document in submitted_papers...',
        name: 'FirestoreService',
      );

      // 1) Get user name from users/{uid} (fallback to auth email)
      String? userName;
      try {
        final userDoc =
            await _firestore.collection('users').doc(userId).get();
        if (userDoc.exists) {
          final data = userDoc.data() as Map<String, dynamic>?;
          userName = data?['name'] as String?;
          userName ??= data?['userName'] as String?;
          userName ??= data?['email'] as String?;
        }
      } catch (_) {
        // ignore, we'll fallback
      }
      userName ??= _auth.currentUser?.email ?? 'Unknown';

      final serverTs = FieldValue.serverTimestamp();
      final nowIso = DateTime.now().toIso8601String();

      // 2) Create main document in submitted_papers
      final docRef = await _firestore.collection('submitted_papers').add({
        // canonical
        'college': college,
        'branch': branch,
        'semester': semester,
        'subject': subject,
        'examType': examType,
        'imageUrl': imageUrl,
        'uploadedAt': serverTs,
        'timestamp': serverTs,
        'status': 'pending',
        'userId': userId,
        'userName': userName,

        
      });

      developer.log(
        'Firestore: Document created with ID: ${docRef.id}',
        name: 'FirestoreService',
      );

      // 3) Link this paper under user doc (subcollection with only ID)
      await _linkPaperToUser(userId: userId, paperId: docRef.id);

      return docRef.id;
    } catch (e, s) {
      developer.log(
        'Error submitting question paper to Firestore',
        name: 'FirestoreService',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  /// Backward-compatible wrapper used by old UI code.
  Future<String> submitToSubmittedPapers({
    required String college,
    required String branch,
    required String semester,
    required String subject,
    required String examType,
    required String imageUrl,
    String? userId,
  }) {
    return submitQuestionPaper(
      college: college,
      branch: branch,
      semester: semester,
      subject: subject,
      examType: examType,
      imageUrl: imageUrl,
      userId: userId,
    );
  }

  /// Only creates a reference document under:
  /// users/{userId}/submitted_papers/{paperId}
  /// with a single field: paperId
  Future<void> _linkPaperToUser({
    required String userId,
    required String paperId,
  }) async {
    try {
      final userDocRef = _firestore.collection('users').doc(userId);

      // Ensure user doc exists (but don't overwrite details)
      await userDocRef.set(
        {
          'uid': userId,
          'lastPaperLinkedAt': FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      final userPaperRef =
          userDocRef.collection('submitted_papers').doc(paperId);

      await userPaperRef.set(
        {
          'paperId': paperId,
        },
        SetOptions(merge: true),
      );

      developer.log(
        'Linked paper $paperId to user $userId (ID only)',
        name: 'FirestoreService',
      );
    } catch (e, s) {
      developer.log(
        'Error linking paper $paperId to user $userId',
        name: 'FirestoreService',
        error: e,
        stackTrace: s,
      );
      // don't rethrow; main submit already succeeded
    }
  }

  /// Legacy "question_papers" collection for topic metadata (if you still use it)
  Future<void> submitToQuestionPapers({
    required String college,
    required String branch,
    required String semester,
    required String subject,
    required String examType,
    required List<String> topics,
  }) async {
    final doc = {
      'college': college,
      'branch': branch,
      'semester': semester,
      'subject': subject,
      'examType': examType,
      'topics': topics,
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('question_papers').add(doc);
  }

  /// Update topic frequency counts in `questions` collection.
  /// This is what you call after Groq topic extraction.
  Future<void> updateQuestionsCollection({
    required String documentName,
    required List<String> topics,
  }) async {
    final DocumentReference docRef =
        _firestore.collection('questions').doc(documentName);

    // Compute frequencies
    final Map<String, int> freq = {};
    for (final t in topics) {
      final key = t.trim();
      if (key.isEmpty) continue;
      freq[key] = (freq[key] ?? 0) + 1;
    }

    final DateTime nowUtc = DateTime.now().toUtc();
    final DateTime nowIst = nowUtc.add(const Duration(hours: 5, minutes: 30));
    final String lastModifiedIso = nowUtc.toIso8601String();
    final String humanIst = _formatHumanReadableIST(nowIst);

    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (snapshot.exists) {
        final Map<String, dynamic> increments = {};
        freq.forEach((topic, count) {
          increments[topic] = FieldValue.increment(count);
        });
        increments['lastModified'] = lastModifiedIso;
        increments['updatedAt'] = humanIst;

        transaction.update(docRef, increments);
      } else {
        final Map<String, dynamic> initial = {};
        freq.forEach((topic, count) {
          initial[topic] = count;
        });

        initial['createdAt'] = humanIst;
        initial['lastModified'] = lastModifiedIso;
        initial['updatedAt'] = humanIst;

        transaction.set(docRef, initial);
      }
    });
  }

  /// "24 November 2025 at 23:24:59 UTC+5:30"
  String _formatHumanReadableIST(DateTime dt) {
    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');

    return '$day $month $year at $hour:$minute:$second UTC+5:30';
  }
}
