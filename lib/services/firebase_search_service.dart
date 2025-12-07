// lib/services/firebase_search_service.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_ready/models/question_paper_model.dart';

/// Service class for handling all Firebase Firestore operations
/// related to question paper search and management.
class FirebaseSearchService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseSearchService();

  // ---------------------------------------------------------------
  // 🔹 METADATA (colleges, branches, subjects, examTypes)
  // ---------------------------------------------------------------

  /// Fetch all colleges from Firestore
  Future<List<String>> getColleges() async {
    try {
      final snapshot = await _firestore.collection('colleges').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList()
        ..sort();
    } catch (e) {
      print('Error fetching colleges: $e');
      rethrow;
    }
  }

  /// Fetch branches for a specific college
  Future<List<String>> getBranches(String college) async {
    try {
      final snapshot = await _firestore
          .collection('branches')
          .where('college', isEqualTo: college)
          .get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList()
        ..sort();
    } catch (e) {
      print('Error fetching branches: $e');
      rethrow;
    }
  }

  /// Fetch subjects based on branch and semester
  Future<List<String>> getSubjects(String branch, String semester) async {
    try {
      final snapshot = await _firestore
          .collection('subjects')
          .where('branch', isEqualTo: branch)
          .where('semester', isEqualTo: semester)
          .get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList()
        ..sort();
    } catch (e) {
      print('Error fetching subjects: $e');
      rethrow;
    }
  }

  /// Fetch all exam types
  Future<List<String>> getExamTypes() async {
    try {
      final snapshot = await _firestore.collection('examTypes').get();
      return snapshot.docs.map((doc) => doc['name'] as String).toList()
        ..sort();
    } catch (e) {
      print('Error fetching exam types: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------
  // 🔹 SEARCH / FILTER QUESTION PAPERS
  // ---------------------------------------------------------------

  /// Search question papers with filters
  /// Returns a stream of filtered question papers from submitted_papers
  Stream<List<QuestionPaper>> searchQuestionPapers({
    String? college,
    String? branch,
    String? semester,
    String? subject,
    String? examType,
  }) {
    try {
      Query query = _firestore.collection('submitted_papers');

      if (college != null && college.isNotEmpty) {
        query = query.where('college', isEqualTo: college);
      }
      if (branch != null && branch.isNotEmpty) {
        query = query.where('branch', isEqualTo: branch);
      }
      if (semester != null && semester.isNotEmpty) {
        query = query.where('semester', isEqualTo: semester);
      }
      if (subject != null && subject.isNotEmpty) {
        query = query.where('subject', isEqualTo: subject);
      }
      if (examType != null && examType.isNotEmpty) {
        query = query.where('examType', isEqualTo: examType);
      }

      // Default sort: if no filters, show newest first
      if ([college, branch, semester, subject, examType]
          .every((v) => v == null || (v is String && v.isEmpty))) {
        query = query.orderBy('uploadedAt', descending: true);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs
            .map((doc) => QuestionPaper.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Error searching question papers: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------
  // 🔹 SINGLE PAPER
  // ---------------------------------------------------------------

  /// Fetch a single question paper by ID from submitted_papers
  Future<QuestionPaper?> getQuestionPaperById(String paperId) async {
    try {
      final doc =
          await _firestore.collection('submitted_papers').doc(paperId).get();

      if (doc.exists) {
        return QuestionPaper.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching question paper: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------
  // 🔹 TEXT SEARCH BY SUBJECT
  // ---------------------------------------------------------------

  /// Search papers by subject name (prefix text search)
  Stream<List<QuestionPaper>> searchBySubjectName(String searchText) {
    try {
      if (searchText.isEmpty) {
        // return all recent if empty text
        return _firestore
            .collection('submitted_papers')
            .orderBy('uploadedAt', descending: true)
            .limit(30)
            .snapshots()
            .map((snapshot) {
          return snapshot.docs
              .map((doc) => QuestionPaper.fromFirestore(doc))
              .toList();
        });
      }

      return _firestore
          .collection('submitted_papers')
          .where('subject', isGreaterThanOrEqualTo: searchText)
          .where('subject', isLessThan: '$searchText\uf8ff')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => QuestionPaper.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Error searching by subject name: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------
  // 🔹 STATS
  // ---------------------------------------------------------------

  /// Get total count of papers for statistics
  Future<int> getTotalPapersCount() async {
    try {
      final snapshot =
          await _firestore.collection('submitted_papers').count().get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error getting total papers count: $e');
      rethrow;
    }
  }

  // ---------------------------------------------------------------
  // 🔹 MY PAPERS
  // ---------------------------------------------------------------

  /// Get papers uploaded by a specific user
  /// Compatible with new schema: uses `userId` field in submitted_papers
  Stream<List<QuestionPaper>> getMyPapers(String userId) {
    try {
      return _firestore
          .collection('submitted_papers')
          .where('userId', isEqualTo: userId)
          .orderBy('uploadedAt', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => QuestionPaper.fromFirestore(doc))
            .toList();
      });
    } catch (e) {
      print('Error fetching user papers: $e');
      rethrow;
    }
  }
}
