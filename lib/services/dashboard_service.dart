import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_ready/services/firebase_service.dart';
import 'package:exam_ready/models/question_paper_model.dart';

/// Service for managing dashboard data and statistics
class DashboardService {
  static final DashboardService _instance = DashboardService._internal();
  factory DashboardService() => _instance;
  DashboardService._internal();

  final FirebaseFirestore _firestore = FirebaseService.instance.firestore;

  /// Get real-time count of documents in a collection
  Stream<int> getCollectionCount(String collectionName) {
    return _firestore
        .collection(collectionName)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get active users count (users with recent activity)
  Stream<int> getActiveUsersCount() {
    final now = DateTime.now();
    final oneDayAgo = now.subtract(const Duration(days: 1));

    return _firestore
        .collection('users')
        .where('lastActive', isGreaterThan: Timestamp.fromDate(oneDayAgo))
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Get recent activity stream
  Stream<List<Map<String, dynamic>>> getRecentActivity() {
    return _firestore
        .collection('recent_activity')
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }

  /// Get recent question papers
  Stream<List<QuestionPaper>> getRecentQuestionPapers() {
    return _firestore
        .collection('question_papers')
        .orderBy('createdAt', descending: true)
        .limit(5)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return QuestionPaper.fromMap(data, doc.id);
          }).toList(),
        );
  }

  /// Get dashboard statistics
  Future<Map<String, int>> getDashboardStats() async {
    try {
      final futures = await Future.wait([
        _firestore.collection('users').get(),
        _firestore.collection('question_papers').get(),
        _firestore.collection('colleges').get(),
        _firestore.collection('branches').get(),
      ]);

      return {
        'activeUsers': futures[0].docs.length,
        'examPapers': futures[1].docs.length,
        'colleges': futures[2].docs.length,
        'branches': futures[3].docs.length,
      };
    } catch (e) {
      return {'activeUsers': 0, 'examPapers': 0, 'colleges': 0, 'branches': 0};
    }
  }

  /// Add activity to recent activity feed
  Future<void> addActivity({
    required String type,
    required String title,
    required String description,
    String? userId,
  }) async {
    try {
      await _firestore.collection('recent_activity').add({
        'type': type,
        'title': title,
        'description': description,
        'userId': userId,
        'timestamp': FieldValue.serverTimestamp(),
        'createdAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      // Handle error silently or log it
      print('Error adding activity: $e');
    }
  }

  /// Get user-specific activity
  Stream<List<Map<String, dynamic>>> getUserActivity(String userId) {
    return _firestore
        .collection('recent_activity')
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(10)
        .snapshots()
        .map(
          (snapshot) => snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return data;
          }).toList(),
        );
  }
}
