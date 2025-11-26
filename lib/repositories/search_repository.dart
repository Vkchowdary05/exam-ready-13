// lib/repositories/search_repository.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_ready/models/question_paper_model.dart';

class SearchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static const String _collectionName = 'question_papers'; // Your actual collection name
  static const int _pageSize = 20;

  /// Search exam papers with optional filters
  /// Returns a stream of QuestionPaper list for real-time updates
  Stream<List<QuestionPaper>> searchExamPapers({
    String? college,
    String? branch,
    String? semester,
    String? subject,
    String? examType,
    DocumentSnapshot? startAfter,
  }) {
    try {
      Query query = _firestore.collection(_collectionName);

      // Apply filters only if they are not null
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

      // Order by timestamp (most recent first)
      query = query.orderBy('timestamp', descending: true);

      // Pagination: start after the last document
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      // Limit the number of results
      query = query.limit(_pageSize);

      // Return stream of papers
      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return QuestionPaper.fromFirestore(doc);
        }).toList();
      });
    } catch (e) {
      // If error occurs, return empty stream
      return Stream.value([]);
    }
  }

  /// Get a single paper by ID
  Future<QuestionPaper?> getPaperById(String paperId) async {
    try {
      final doc = await _firestore
          .collection(_collectionName)
          .doc(paperId)
          .get();

      if (doc.exists) {
        return QuestionPaper.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error fetching paper: $e');
      return null;
    }
  }

  /// Get papers by user ID (for user's uploaded papers)
  Stream<List<QuestionPaper>> getPapersByUserId(String userId) {
    try {
      return _firestore
          .collection(_collectionName)
          .where('userId', isEqualTo: userId)
          .orderBy('timestamp', descending: true)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return QuestionPaper.fromFirestore(doc);
        }).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Delete a paper by ID
  Future<bool> deletePaper(String paperId) async {
    try {
      await _firestore.collection(_collectionName).doc(paperId).delete();
      return true;
    } catch (e) {
      print('Error deleting paper: $e');
      return false;
    }
  }

  /// Update paper likes
  Future<bool> updatePaperLikes(String paperId, int newLikesCount) async {
    try {
      await _firestore.collection(_collectionName).doc(paperId).update({
        'likes': newLikesCount,
      });
      return true;
    } catch (e) {
      print('Error updating likes: $e');
      return false;
    }
  }

  /// Get all unique colleges
  Future<List<String>> getUniqueColleges() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .get();

      final colleges = <String>{};
      for (var doc in snapshot.docs) {
        final college = doc.data()['college'] as String?;
        if (college != null && college.isNotEmpty) {
          colleges.add(college);
        }
      }

      return colleges.toList()..sort();
    } catch (e) {
      print('Error fetching colleges: $e');
      return [];
    }
  }

  /// Get all unique branches for a college
  Future<List<String>> getUniqueBranches(String college) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('college', isEqualTo: college)
          .get();

      final branches = <String>{};
      for (var doc in snapshot.docs) {
        final branch = doc.data()['branch'] as String?;
        if (branch != null && branch.isNotEmpty) {
          branches.add(branch);
        }
      }

      return branches.toList()..sort();
    } catch (e) {
      print('Error fetching branches: $e');
      return [];
    }
  }

  /// Get all unique subjects for a branch and semester
  Future<List<String>> getUniqueSubjects({
    required String branch,
    required String semester,
  }) async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .where('branch', isEqualTo: branch)
          .where('semester', isEqualTo: semester)
          .get();

      final subjects = <String>{};
      for (var doc in snapshot.docs) {
        final subject = doc.data()['subject'] as String?;
        if (subject != null && subject.isNotEmpty) {
          subjects.add(subject);
        }
      }

      return subjects.toList()..sort();
    } catch (e) {
      print('Error fetching subjects: $e');
      return [];
    }
  }

  /// Get total count of papers (for statistics)
  Future<int> getTotalPapersCount() async {
    try {
      final snapshot = await _firestore
          .collection(_collectionName)
          .count()
          .get();
      return snapshot.count ?? 0;
    } catch (e) {
      print('Error fetching total count: $e');
      return 0;
    }
  }

  /// Search papers by text query (subject name or college name)
  Stream<List<QuestionPaper>> searchPapersByText(String searchText) {
    try {
      if (searchText.isEmpty) {
        return Stream.value([]);
      }

      // This is a simple implementation. For better search, consider using
      // Algolia, ElasticSearch, or Cloud Functions with full-text search
      return _firestore
          .collection(_collectionName)
          .orderBy('subject')
          .startAt([searchText])
          .endAt([searchText + '\uf8ff'])
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return QuestionPaper.fromFirestore(doc);
        }).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Get recent papers (homepage/dashboard)
  Stream<List<QuestionPaper>> getRecentPapers({int limit = 10}) {
    try {
      return _firestore
          .collection(_collectionName)
          .orderBy('timestamp', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return QuestionPaper.fromFirestore(doc);
        }).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }

  /// Get popular papers (by likes)
  Stream<List<QuestionPaper>> getPopularPapers({int limit = 10}) {
    try {
      return _firestore
          .collection(_collectionName)
          .orderBy('likes', descending: true)
          .limit(limit)
          .snapshots()
          .map((snapshot) {
        return snapshot.docs.map((doc) {
          return QuestionPaper.fromFirestore(doc);
        }).toList();
      });
    } catch (e) {
      return Stream.value([]);
    }
  }
}