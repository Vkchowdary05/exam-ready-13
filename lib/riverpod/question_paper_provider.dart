// lib/riverpod/question_paper_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
// ONLY import ONE of these - choose the correct one for your project
import 'package:exam_ready/models/question_paper_model.dart';  // Use this one
// Remove or comment out: import 'package:exam_ready/models/paper_model.dart';
import 'package:exam_ready/services/firebase_search_service.dart';

part 'question_paper_provider.g.dart';

/// Provider for Firebase Search Service
@riverpod
FirebaseSearchService searchService(ref) {
  return FirebaseSearchService();
}

/// State class for managing search filters
class SearchFilters {
  final String? college;
  final String? branch;
  final String? semester;
  final String? subject;
  final String? examType;

  SearchFilters({
    this.college,
    this.branch,
    this.semester,
    this.subject,
    this.examType,
  });

  SearchFilters copyWith({
    String? college,
    String? branch,
    String? semester,
    String? subject,
    String? examType,
    bool clearCollege = false,
    bool clearBranch = false,
    bool clearSemester = false,
    bool clearSubject = false,
    bool clearExamType = false,
  }) {
    return SearchFilters(
      college: clearCollege ? null : (college ?? this.college),
      branch: clearBranch ? null : (branch ?? this.branch),
      semester: clearSemester ? null : (semester ?? this.semester),
      subject: clearSubject ? null : (subject ?? this.subject),
      examType: clearExamType ? null : (examType ?? this.examType),
    );
  }

  bool get hasAnyFilter =>
      college != null ||
      branch != null ||
      semester != null ||
      subject != null ||
      examType != null;

  SearchFilters clear() {
    return SearchFilters();
  }
}

/// Modern Notifier for managing search filters
@riverpod
class SearchFiltersNotifier extends _$SearchFiltersNotifier {
  @override
  SearchFilters build() {
    return SearchFilters();
  }

  void setCollege(String? college) {
    state = state.copyWith(
      college: college,
      clearBranch: true,
      clearSemester: true,
      clearSubject: true,
    );
  }

  void setBranch(String? branch) {
    state = state.copyWith(
      branch: branch,
      clearSemester: true,
      clearSubject: true,
    );
  }

  void setSemester(String? semester) {
    state = state.copyWith(
      semester: semester,
      clearSubject: true,
    );
  }

  void setSubject(String? subject) {
    state = state.copyWith(subject: subject);
  }

  void setExamType(String? examType) {
    state = state.copyWith(examType: examType);
  }

  void resetFilters() {
    state = SearchFilters();
  }
}

/// Provider for fetching colleges list
@riverpod
Future<List<String>> colleges(ref) async {
  final service = ref.watch(searchServiceProvider);
  return service.getColleges();
}

/// Provider for fetching branches based on selected college
@riverpod
Future<List<String>> branches(ref, String? college) async {
  if (college == null || college.isEmpty) return [];
  final service = ref.watch(searchServiceProvider);
  return service.getBranches(college);
}

/// Provider for fetching subjects based on branch and semester
@riverpod
Future<List<String>> subjects(
  ref,
  {
    required String? branch,
    required String? semester,
  }
) async {
  if (branch == null || semester == null || branch.isEmpty || semester.isEmpty) {
    return [];
  }
  final service = ref.watch(searchServiceProvider);
  return service.getSubjects(branch, semester);
}

/// Provider for fetching exam types
@riverpod
Future<List<String>> examTypes(ref) async {
  final service = ref.watch(searchServiceProvider);
  return service.getExamTypes();
}

/// Provider for searching question papers with current filters
@riverpod
Stream<List<QuestionPaper>> searchResults(ref) {
  final filters = ref.watch(SearchFiltersNotifierProvider);
  final service = ref.watch(searchServiceProvider);

  return service.searchQuestionPapers(
    college: filters.college,
    branch: filters.branch,
    semester: filters.semester,
    subject: filters.subject,
    examType: filters.examType,
  );
}

/// Provider for getting a single paper by ID
@riverpod
Future<QuestionPaper?> paperDetails(ref, String paperId) async {
  final service = ref.watch(searchServiceProvider);
  return service.getQuestionPaperById(paperId);
}

/// Provider for getting the total number of papers
@riverpod
Future<int> totalPapers(ref) async {
  final service = ref.watch(searchServiceProvider);
  return service.getTotalPapersCount();
}

/// Provider for getting the recent activity
@riverpod
Stream<List<QuestionPaper>> recentActivity(ref) {
  final service = ref.watch(searchServiceProvider);
  return service.searchQuestionPapers();
}
