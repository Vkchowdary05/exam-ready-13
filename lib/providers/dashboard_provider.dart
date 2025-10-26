import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_ready/services/dashboard_service.dart';
import 'package:exam_ready/models/question_paper_model.dart';

/// Dashboard service provider
final dashboardServiceProvider = Provider<DashboardService>((ref) {
  return DashboardService();
});

/// Active users count provider
final activeUsersCountProvider = StreamProvider<int>((ref) {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return dashboardService.getActiveUsersCount();
});

/// Exam papers count provider
final examPapersCountProvider = StreamProvider<int>((ref) {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return dashboardService.getCollectionCount('question_papers');
});

/// Colleges count provider
final collegesCountProvider = StreamProvider<int>((ref) {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return dashboardService.getCollectionCount('colleges');
});

/// Branches count provider
final branchesCountProvider = StreamProvider<int>((ref) {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return dashboardService.getCollectionCount('branches');
});

/// Recent activity provider
final recentActivityProvider = StreamProvider<List<Map<String, dynamic>>>((
  ref,
) {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return dashboardService.getRecentActivity();
});

/// Recent question papers provider
final recentQuestionPapersProvider = StreamProvider<List<QuestionPaper>>((ref) {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return dashboardService.getRecentQuestionPapers();
});

/// Dashboard statistics provider
final dashboardStatsProvider = FutureProvider<Map<String, int>>((ref) {
  final dashboardService = ref.watch(dashboardServiceProvider);
  return dashboardService.getDashboardStats();
});

/// User activity provider
final userActivityProvider =
    StreamProvider.family<List<Map<String, dynamic>>, String>((ref, userId) {
      final dashboardService = ref.watch(dashboardServiceProvider);
      return dashboardService.getUserActivity(userId);
    });
