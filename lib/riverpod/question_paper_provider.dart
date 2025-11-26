// lib/riverpod/question_paper_provider.dart

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_ready/models/question_paper_model.dart';
import 'package:exam_ready/repositories/search_repository.dart';

/// Provider for SearchRepository instance
final searchRepositoryProvider = Provider<SearchRepository>((ref) {
  return SearchRepository();
});

/// Provider to get a single paper by ID
/// Usage: ref.watch(paperDetailsProvider(paperId))
final paperDetailsProvider = StreamProvider.family<QuestionPaper?, String>((
  ref,
  paperId,
) async* {
  final repository = ref.watch(searchRepositoryProvider);

  // Get the paper once
  final paper = await repository.getPaperById(paperId);

  // Yield the result
  if (paper != null) {
    yield paper;
  } else {
    yield null;
  }
});

/// Provider to get papers by user ID
/// Usage: ref.watch(userPapersProvider(userId))
final userPapersProvider = StreamProvider.family<List<QuestionPaper>, String>((
  ref,
  userId,
) {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.getPapersByUserId(userId);
});

/// Provider for recent papers
/// Usage: ref.watch(recentPapersProvider)
final recentPapersProvider = StreamProvider<List<QuestionPaper>>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.getRecentPapers(limit: 10);
});

/// Provider for popular papers
/// Usage: ref.watch(popularPapersProvider)
final popularPapersProvider = StreamProvider<List<QuestionPaper>>((ref) {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.getPopularPapers(limit: 10);
});

/// Provider for total papers count
/// Usage: ref.watch(totalPapersCountProvider)
final totalPapersCountProvider = FutureProvider<int>((ref) async {
  final repository = ref.watch(searchRepositoryProvider);
  return await repository.getTotalPapersCount();
});

/// Provider for unique colleges list
/// Usage: ref.watch(uniqueCollegesProvider)
final uniqueCollegesProvider = FutureProvider<List<String>>((ref) async {
  final repository = ref.watch(searchRepositoryProvider);
  return await repository.getUniqueColleges();
});

/// Provider for unique branches for a college
/// Usage: ref.watch(uniqueBranchesProvider(college))
final uniqueBranchesProvider = FutureProvider.family<List<String>, String>((
  ref,
  college,
) async {
  final repository = ref.watch(searchRepositoryProvider);
  return await repository.getUniqueBranches(college);
});

/// Provider for unique subjects for branch and semester
/// Usage: ref.watch(uniqueSubjectsProvider({'branch': branch, 'semester': semester}))
final uniqueSubjectsProvider =
    FutureProvider.family<List<String>, Map<String, String>>((
      ref,
      params,
    ) async {
      final repository = ref.watch(searchRepositoryProvider);
      return await repository.getUniqueSubjects(
        branch: params['branch']!,
        semester: params['semester']!,
      );
    });

/// Provider for search with filters
/// Usage: ref.watch(searchWithFiltersProvider(filters))
final searchWithFiltersProvider =
    StreamProvider.family<List<QuestionPaper>, Map<String, String?>>((
      ref,
      filters,
    ) {
      final repository = ref.watch(searchRepositoryProvider);
      return repository.searchExamPapers(
        college: filters['college'],
        branch: filters['branch'],
        semester: filters['semester'],
        subject: filters['subject'],
        examType: filters['examType'],
      );
    });

/// Provider for text search
/// Usage: ref.watch(textSearchProvider(searchText))
final textSearchProvider = StreamProvider.family<List<QuestionPaper>, String>((
  ref,
  searchText,
) {
  final repository = ref.watch(searchRepositoryProvider);
  return repository.searchPapersByText(searchText);
});

/// Notifier for managing paper likes (using Riverpod 2.0)
class PaperLikesNotifier extends Notifier<Map<String, int>> {
  @override
  Map<String, int> build() {
    return {};
  }

  SearchRepository get _repository => ref.watch(searchRepositoryProvider);

  /// Toggle like for a paper
  Future<void> toggleLike(
    String paperId,
    int currentLikes,
    bool isLiked,
  ) async {
    final newLikes = isLiked ? currentLikes - 1 : currentLikes + 1;

    // Optimistically update UI
    state = {...state, paperId: newLikes};

    // Update in Firestore
    final success = await _repository.updatePaperLikes(paperId, newLikes);

    if (!success) {
      // Revert on failure
      state = {...state, paperId: currentLikes};
    }
  }

  /// Get likes count for a paper
  int getLikes(String paperId, int defaultLikes) {
    return state[paperId] ?? defaultLikes;
  }
}

/// Provider for paper likes management
final paperLikesProvider =
    NotifierProvider<PaperLikesNotifier, Map<String, int>>(
      PaperLikesNotifier.new,
    );

/// Notifier for managing user's liked papers (using Riverpod 2.0)
class UserLikedPapersNotifier extends Notifier<Set<String>> {
  @override
  Set<String> build() {
    return {};
  }

  /// Add a paper to liked papers
  void likePaper(String paperId) {
    state = {...state, paperId};
  }

  /// Remove a paper from liked papers
  void unlikePaper(String paperId) {
    state = {...state}..remove(paperId);
  }

  /// Toggle like status
  void toggleLike(String paperId) {
    if (state.contains(paperId)) {
      unlikePaper(paperId);
    } else {
      likePaper(paperId);
    }
  }

  /// Check if a paper is liked
  bool isLiked(String paperId) {
    return state.contains(paperId);
  }

  /// Get all liked paper IDs
  Set<String> getLikedPapers() {
    return state;
  }

  /// Clear all likes (on logout)
  void clearAll() {
    state = {};
  }
}

/// Provider for managing user's liked papers
final userLikedPapersProvider =
    NotifierProvider<UserLikedPapersNotifier, Set<String>>(
      UserLikedPapersNotifier.new,
    );

/// Provider to delete a paper
/// This is a one-time action provider
final deletePaperProvider = FutureProvider.family<bool, String>((
  ref,
  paperId,
) async {
  final repository = ref.watch(searchRepositoryProvider);
  return await repository.deletePaper(paperId);
});
