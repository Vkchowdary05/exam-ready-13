// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'question_paper_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for Firebase Search Service

@ProviderFor(searchService)
const searchServiceProvider = SearchServiceProvider._();

/// Provider for Firebase Search Service

final class SearchServiceProvider
    extends
        $FunctionalProvider<
          FirebaseSearchService,
          FirebaseSearchService,
          FirebaseSearchService
        >
    with $Provider<FirebaseSearchService> {
  /// Provider for Firebase Search Service
  const SearchServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchServiceProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchServiceHash();

  @$internal
  @override
  $ProviderElement<FirebaseSearchService> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  FirebaseSearchService create(Ref ref) {
    return searchService(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(FirebaseSearchService value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<FirebaseSearchService>(value),
    );
  }
}

String _$searchServiceHash() => r'3542dc1b01df570af696b49a0e743e1416fbc58c';

/// Modern Notifier for managing search filters

@ProviderFor(SearchFiltersNotifier)
const searchFiltersProvider = SearchFiltersNotifierProvider._();

/// Modern Notifier for managing search filters
final class SearchFiltersNotifierProvider
    extends $NotifierProvider<SearchFiltersNotifier, SearchFilters> {
  /// Modern Notifier for managing search filters
  const SearchFiltersNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchFiltersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchFiltersNotifierHash();

  @$internal
  @override
  SearchFiltersNotifier create() => SearchFiltersNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SearchFilters value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SearchFilters>(value),
    );
  }
}

String _$searchFiltersNotifierHash() =>
    r'655ddd84b4f4aec83c52dc590e01b90205b9cda1';

/// Modern Notifier for managing search filters

abstract class _$SearchFiltersNotifier extends $Notifier<SearchFilters> {
  SearchFilters build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SearchFilters, SearchFilters>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<SearchFilters, SearchFilters>,
              SearchFilters,
              Object?,
              Object?
            >;
    element.handleValue(ref, created);
  }
}

/// Provider for fetching colleges list

@ProviderFor(colleges)
const collegesProvider = CollegesProvider._();

/// Provider for fetching colleges list

final class CollegesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provider for fetching colleges list
  const CollegesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'collegesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$collegesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return colleges(ref);
  }
}

String _$collegesHash() => r'882bd8fa2095249d494327b265d8eae4dade9d74';

/// Provider for fetching branches based on selected college

@ProviderFor(branches)
const branchesProvider = BranchesFamily._();

/// Provider for fetching branches based on selected college

final class BranchesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provider for fetching branches based on selected college
  const BranchesProvider._({
    required BranchesFamily super.from,
    required String? super.argument,
  }) : super(
         retry: null,
         name: r'branchesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$branchesHash();

  @override
  String toString() {
    return r'branchesProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as String?;
    return branches(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is BranchesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$branchesHash() => r'4308eff63dae584a3bf27d821141bf598ca7d1d5';

/// Provider for fetching branches based on selected college

final class BranchesFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<String>>, String?> {
  const BranchesFamily._()
    : super(
        retry: null,
        name: r'branchesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for fetching branches based on selected college

  BranchesProvider call(String? college) =>
      BranchesProvider._(argument: college, from: this);

  @override
  String toString() => r'branchesProvider';
}

/// Provider for fetching subjects based on branch and semester

@ProviderFor(subjects)
const subjectsProvider = SubjectsFamily._();

/// Provider for fetching subjects based on branch and semester

final class SubjectsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provider for fetching subjects based on branch and semester
  const SubjectsProvider._({
    required SubjectsFamily super.from,
    required ({String? branch, String? semester}) super.argument,
  }) : super(
         retry: null,
         name: r'subjectsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$subjectsHash();

  @override
  String toString() {
    return r'subjectsProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    final argument = this.argument as ({String? branch, String? semester});
    return subjects(ref, branch: argument.branch, semester: argument.semester);
  }

  @override
  bool operator ==(Object other) {
    return other is SubjectsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$subjectsHash() => r'bf93de779b5067db0b70a917f7c21bee308fd9db';

/// Provider for fetching subjects based on branch and semester

final class SubjectsFamily extends $Family
    with
        $FunctionalFamilyOverride<
          FutureOr<List<String>>,
          ({String? branch, String? semester})
        > {
  const SubjectsFamily._()
    : super(
        retry: null,
        name: r'subjectsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for fetching subjects based on branch and semester

  SubjectsProvider call({required String? branch, required String? semester}) =>
      SubjectsProvider._(
        argument: (branch: branch, semester: semester),
        from: this,
      );

  @override
  String toString() => r'subjectsProvider';
}

/// Provider for fetching exam types

@ProviderFor(examTypes)
const examTypesProvider = ExamTypesProvider._();

/// Provider for fetching exam types

final class ExamTypesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  /// Provider for fetching exam types
  const ExamTypesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'examTypesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$examTypesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return examTypes(ref);
  }
}

String _$examTypesHash() => r'42eba16deeafc6a71d5b2871d77836e2ec2e7ab0';

/// Provider for searching question papers with current filters

@ProviderFor(searchResults)
const searchResultsProvider = SearchResultsProvider._();

/// Provider for searching question papers with current filters

final class SearchResultsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QuestionPaper>>,
          List<QuestionPaper>,
          Stream<List<QuestionPaper>>
        >
    with
        $FutureModifier<List<QuestionPaper>>,
        $StreamProvider<List<QuestionPaper>> {
  /// Provider for searching question papers with current filters
  const SearchResultsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'searchResultsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$searchResultsHash();

  @$internal
  @override
  $StreamProviderElement<List<QuestionPaper>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<QuestionPaper>> create(Ref ref) {
    return searchResults(ref);
  }
}

String _$searchResultsHash() => r'4c8d9d8d8bcad16cd763daa0290765ab59eb8295';

/// Provider for getting a single paper by ID

@ProviderFor(paperDetails)
const paperDetailsProvider = PaperDetailsFamily._();

/// Provider for getting a single paper by ID

final class PaperDetailsProvider
    extends
        $FunctionalProvider<
          AsyncValue<QuestionPaper?>,
          QuestionPaper?,
          FutureOr<QuestionPaper?>
        >
    with $FutureModifier<QuestionPaper?>, $FutureProvider<QuestionPaper?> {
  /// Provider for getting a single paper by ID
  const PaperDetailsProvider._({
    required PaperDetailsFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'paperDetailsProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$paperDetailsHash();

  @override
  String toString() {
    return r'paperDetailsProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<QuestionPaper?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<QuestionPaper?> create(Ref ref) {
    final argument = this.argument as String;
    return paperDetails(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PaperDetailsProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$paperDetailsHash() => r'b333c05cafc148120bad194e7edd8f515af0c153';

/// Provider for getting a single paper by ID

final class PaperDetailsFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<QuestionPaper?>, String> {
  const PaperDetailsFamily._()
    : super(
        retry: null,
        name: r'paperDetailsProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Provider for getting a single paper by ID

  PaperDetailsProvider call(String paperId) =>
      PaperDetailsProvider._(argument: paperId, from: this);

  @override
  String toString() => r'paperDetailsProvider';
}

/// Provider for getting the total number of papers

@ProviderFor(totalPapers)
const totalPapersProvider = TotalPapersProvider._();

/// Provider for getting the total number of papers

final class TotalPapersProvider
    extends $FunctionalProvider<AsyncValue<int>, int, FutureOr<int>>
    with $FutureModifier<int>, $FutureProvider<int> {
  /// Provider for getting the total number of papers
  const TotalPapersProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'totalPapersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$totalPapersHash();

  @$internal
  @override
  $FutureProviderElement<int> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int> create(Ref ref) {
    return totalPapers(ref);
  }
}

String _$totalPapersHash() => r'8f01f836211510da666b661f460eaf0983efd422';

/// Provider for getting the recent activity

@ProviderFor(recentActivity)
const recentActivityProvider = RecentActivityProvider._();

/// Provider for getting the recent activity

final class RecentActivityProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<QuestionPaper>>,
          List<QuestionPaper>,
          Stream<List<QuestionPaper>>
        >
    with
        $FutureModifier<List<QuestionPaper>>,
        $StreamProvider<List<QuestionPaper>> {
  /// Provider for getting the recent activity
  const RecentActivityProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'recentActivityProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$recentActivityHash();

  @$internal
  @override
  $StreamProviderElement<List<QuestionPaper>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<QuestionPaper>> create(Ref ref) {
    return recentActivity(ref);
  }
}

String _$recentActivityHash() => r'7646115b82b8b2b03047057129f751dcab5222e3';
