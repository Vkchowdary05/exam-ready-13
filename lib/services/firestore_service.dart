// lib/services/firestore_service.dart

import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exam_ready/utils/sanitizer.dart';
import 'package:exam_ready/utils/constants.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Submit Paper (primary) ────────────────────────────────────

  /// Submit a question paper image to Firestore.
  ///
  /// - Sanitizes all metadata fields
  /// - Checks for duplicate uploads
  /// - Links paper to user
  /// - Returns the created document ID
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
      userId ??= _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in. Cannot submit paper.');
      }

      // ── Sanitize inputs ──────────────────────────────────────
      final sanitizedCollege = InputSanitizer.sanitizeMetadataField(college);
      final sanitizedBranch = InputSanitizer.sanitizeMetadataField(branch);
      final sanitizedSemester = InputSanitizer.sanitizeMetadataField(semester);
      final sanitizedSubject = InputSanitizer.sanitizeMetadataField(subject);
      final sanitizedExamType = InputSanitizer.sanitizeMetadataField(examType);

      // ── Check for duplicates ─────────────────────────────────
      final isDuplicate = await _checkDuplicate(
        imageUrl: imageUrl,
        college: sanitizedCollege,
        branch: sanitizedBranch,
        semester: sanitizedSemester,
        subject: sanitizedSubject,
        examType: sanitizedExamType,
      );

      if (isDuplicate) {
        throw Exception(
          'This paper appears to have been uploaded already. '
          'Would you like to search for it instead?',
        );
      }

      developer.log(
        'Creating document in submitted_papers...',
        name: 'FirestoreService',
      );

      // ── Get user name ────────────────────────────────────────
      String userName = await _getUserName(userId);

      // ── Create document ──────────────────────────────────────
      final docRef = await _firestore
          .collection(AppConstants.papersCollection)
          .add({
        'college': sanitizedCollege,
        'branch': sanitizedBranch,
        'semester': sanitizedSemester,
        'subject': sanitizedSubject,
        'examType': sanitizedExamType,
        'imageUrl': imageUrl,
        'uploadedAt': FieldValue.serverTimestamp(),
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'pending',
        'userId': userId,
        'userName': userName,
        'upvotes': 0,
        'downvotes': 0,
        'views': 0,
        'verified': false,
        'flagged': false,
      });

      developer.log(
        'Document created with ID: ${docRef.id}',
        name: 'FirestoreService',
      );

      // ── Link paper to user ───────────────────────────────────
      await _linkPaperToUser(userId: userId, paperId: docRef.id);

      return docRef.id;
    } catch (e, s) {
      developer.log(
        'Error submitting paper',
        name: 'FirestoreService',
        error: e,
        stackTrace: s,
      );
      rethrow;
    }
  }

  /// Backward-compatible wrapper
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

  // ─── Submit Topic Extraction Results ───────────────────────────

  /// Save topic extraction results to `question_papers` collection.
  ///
  /// Topics are sanitized before storage.
  Future<void> submitToQuestionPapers({
    required String college,
    required String branch,
    required String semester,
    required String subject,
    required String examType,
    required List<String> topics,
  }) async {
    final userId = _auth.currentUser?.uid;

    // Sanitize topics
    final sanitizedTopics = InputSanitizer.sanitizeTopics(topics);

    final doc = {
      'college': InputSanitizer.sanitizeMetadataField(college),
      'branch': InputSanitizer.sanitizeMetadataField(branch),
      'semester': InputSanitizer.sanitizeMetadataField(semester),
      'subject': InputSanitizer.sanitizeMetadataField(subject),
      'examType': InputSanitizer.sanitizeMetadataField(examType),
      'topics': sanitizedTopics,
      'userId': userId,
      'uploadedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection(AppConstants.questionPapersCollection)
        .add(doc);
  }

  // ─── Update Topic Frequency ────────────────────────────────────

  /// Update topic frequency counts in `questions` collection.
  Future<void> updateQuestionsCollection({
    required String documentName,
    required List<String> topics,
  }) async {
    // Sanitize topics first
    final sanitizedTopics = InputSanitizer.sanitizeTopics(topics);

    final DocumentReference docRef = _firestore
        .collection(AppConstants.questionsCollection)
        .doc(documentName);

    // Compute frequencies
    final Map<String, int> freq = {};
    for (final t in sanitizedTopics) {
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

  // ─── Voting ────────────────────────────────────────────────────

  /// Upvote or downvote a paper. Uses per-user vote tracking.
  Future<void> votePaper({
    required String paperId,
    required bool isUpvote,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Not logged in.');

    final paperRef = _firestore
        .collection(AppConstants.papersCollection)
        .doc(paperId);

    final voteRef = paperRef.collection('votes').doc(userId);

    await _firestore.runTransaction((transaction) async {
      final voteSnap = await transaction.get(voteRef);
      final paperSnap = await transaction.get(paperRef);

      if (!paperSnap.exists) throw Exception('Paper not found.');

      final currentVote = voteSnap.exists
          ? (voteSnap.data()?['vote'] as String?)
          : null;

      final updates = <String, dynamic>{};

      if (currentVote == null) {
        // New vote
        if (isUpvote) {
          updates['upvotes'] = FieldValue.increment(1);
        } else {
          updates['downvotes'] = FieldValue.increment(1);
        }
        transaction.set(
          voteRef,
          {'vote': isUpvote ? 'up' : 'down', 'timestamp': FieldValue.serverTimestamp()},
        );
      } else if (currentVote == 'up' && !isUpvote) {
        // Switch from upvote to downvote
        updates['upvotes'] = FieldValue.increment(-1);
        updates['downvotes'] = FieldValue.increment(1);
        transaction.update(voteRef, {'vote': 'down', 'timestamp': FieldValue.serverTimestamp()});
      } else if (currentVote == 'down' && isUpvote) {
        // Switch from downvote to upvote
        updates['downvotes'] = FieldValue.increment(-1);
        updates['upvotes'] = FieldValue.increment(1);
        transaction.update(voteRef, {'vote': 'up', 'timestamp': FieldValue.serverTimestamp()});
      } else {
        // Same vote — toggle off
        if (currentVote == 'up') {
          updates['upvotes'] = FieldValue.increment(-1);
        } else {
          updates['downvotes'] = FieldValue.increment(-1);
        }
        transaction.delete(voteRef);
      }

      if (updates.isNotEmpty) {
        transaction.update(paperRef, updates);
      }
    });
  }

  /// Increment view count for a paper
  Future<void> incrementViews(String paperId) async {
    try {
      await _firestore
          .collection(AppConstants.papersCollection)
          .doc(paperId)
          .update({'views': FieldValue.increment(1)});
    } catch (e) {
      developer.log('Error incrementing views', name: 'FirestoreService', error: e);
    }
  }

  // ─── Bookmarks ─────────────────────────────────────────────────

  /// Toggle bookmark for current user
  Future<void> toggleBookmark(String paperId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Not logged in.');

    final userRef = _firestore
        .collection(AppConstants.usersCollection)
        .doc(userId);

    final userDoc = await userRef.get();
    final bookmarks = List<String>.from(
      userDoc.data()?['bookmarkedPapers'] ?? [],
    );

    if (bookmarks.contains(paperId)) {
      bookmarks.remove(paperId);
    } else {
      bookmarks.add(paperId);
    }

    await userRef.update({'bookmarkedPapers': bookmarks});
  }

  // ─── Private Helpers ───────────────────────────────────────────

  /// Check if a paper with similar metadata already exists
  Future<bool> _checkDuplicate({
    required String imageUrl,
    required String college,
    required String branch,
    required String semester,
    required String subject,
    required String examType,
  }) async {
    try {
      // Check by same metadata (not image URL, as that's unique per upload)
      final query = await _firestore
          .collection(AppConstants.papersCollection)
          .where('college', isEqualTo: college)
          .where('branch', isEqualTo: branch)
          .where('semester', isEqualTo: semester)
          .where('subject', isEqualTo: subject)
          .where('examType', isEqualTo: examType)
          .limit(5)
          .get();

      // If 5+ papers with same metadata exist, likely duplicate
      return query.docs.length >= 5;
    } catch (e) {
      // On error, don't block the upload
      return false;
    }
  }

  /// Get user's display name
  Future<String> _getUserName(String userId) async {
    try {
      final userDoc = await _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>?;
        return data?['name'] as String? ??
            data?['userName'] as String? ??
            data?['email'] as String? ??
            _auth.currentUser?.email ??
            'Unknown';
      }
    } catch (_) {}
    return _auth.currentUser?.email ?? 'Unknown';
  }

  /// Link paper to user's submitted_papers subcollection
  Future<void> _linkPaperToUser({
    required String userId,
    required String paperId,
  }) async {
    try {
      final userDocRef = _firestore
          .collection(AppConstants.usersCollection)
          .doc(userId);

      await userDocRef.set(
        {'lastPaperLinkedAt': FieldValue.serverTimestamp()},
        SetOptions(merge: true),
      );

      await userDocRef
          .collection('submitted_papers')
          .doc(paperId)
          .set({'paperId': paperId}, SetOptions(merge: true));

      developer.log(
        'Linked paper $paperId to user $userId',
        name: 'FirestoreService',
      );
    } catch (e, s) {
      developer.log(
        'Error linking paper $paperId to user $userId',
        name: 'FirestoreService',
        error: e,
        stackTrace: s,
      );
    }
  }

  /// Format date as IST human-readable string
  String _formatHumanReadableIST(DateTime dt) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December',
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
