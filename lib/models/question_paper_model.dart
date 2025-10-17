import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Represents a Question Paper uploaded to the system
/// Uses Equatable for value-based equality comparisons
class QuestionPaper extends Equatable {
  final String id;
  final String college;
  final String branch;
  final String semester;
  final String subject;
  final String examType;
  final String imageUrl; // Cloudinary image URL
  final String pdfUrl;
  final String year;
  final DateTime uploadedAt;
  final String status; // pending, approved, rejected
  final int views;
  final int downloads;

  const QuestionPaper({
    required this.id,
    required this.college,
    required this.branch,
    required this.semester,
    required this.subject,
    required this.examType,
    required this.imageUrl,
    this.pdfUrl = '', // Default empty string since not all papers have PDFs yet
    this.year = '',
    required this.uploadedAt,
    this.status = 'pending',
    this.views = 0,
    this.downloads = 0,
  });

  /// ✅ Create a QuestionPaper from a Firestore document
  factory QuestionPaper.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return QuestionPaper(
      id: doc.id,
      college: data['college'] ?? 'Unknown',
      branch: data['branch'] ?? 'Unknown',
      semester: data['semester'] ?? 'Unknown',
      subject: data['subject'] ?? 'Unknown',
      examType: data['exam_type'] ?? 'Unknown',
      imageUrl: data['image_url'] ?? '',
      pdfUrl: data['pdf_url'] ?? '',
      year: data['year'] ?? '',
      uploadedAt: _parseTimestamp(data['uploaded_at']),
      status: data['status'] ?? 'pending',
      views: data['views'] ?? 0,
      downloads: data['downloads'] ?? 0,
    );
  }

  /// ✅ Create a QuestionPaper from a raw map
  factory QuestionPaper.fromMap(Map<String, dynamic> data, String id) {
    return QuestionPaper(
      id: id,
      college: data['college'] ?? 'Unknown',
      branch: data['branch'] ?? 'Unknown',
      semester: data['semester'] ?? 'Unknown',
      subject: data['subject'] ?? 'Unknown',
      examType: data['exam_type'] ?? 'Unknown',
      imageUrl: data['image_url'] ?? '',
      pdfUrl: data['pdf_url'] ?? '',
      year: data['year'] ?? '',
      uploadedAt: _parseTimestamp(data['uploaded_at']),
      status: data['status'] ?? 'pending',
      views: data['views'] ?? 0,
      downloads: data['downloads'] ?? 0,
    );
  }

  /// ✅ Convert QuestionPaper to a Firestore-compatible map
  Map<String, dynamic> toMap() {
    return {
      'college': college,
      'branch': branch,
      'semester': semester,
      'subject': subject,
      'exam_type': examType,
      'image_url': imageUrl,
      'pdf_url': pdfUrl,
      'year': year,
      'uploaded_at': Timestamp.fromDate(uploadedAt),
      'status': status,
      'views': views,
      'downloads': downloads,
    };
  }

  /// ✅ Helper method to safely parse Firestore Timestamp
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp is Timestamp) {
      return timestamp.toDate();
    } else if (timestamp is DateTime) {
      return timestamp;
    }
    return DateTime.now();
  }

  /// ✅ Create a copy with modified fields (immutability pattern)
  QuestionPaper copyWith({
    String? id,
    String? college,
    String? branch,
    String? semester,
    String? subject,
    String? examType,
    String? imageUrl,
    String? pdfUrl,
    String? year,
    DateTime? uploadedAt,
    String? status,
    int? views,
    int? downloads,
  }) {
    return QuestionPaper(
      id: id ?? this.id,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      subject: subject ?? this.subject,
      examType: examType ?? this.examType,
      imageUrl: imageUrl ?? this.imageUrl,
      pdfUrl: pdfUrl ?? this.pdfUrl,
      year: year ?? this.year,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      status: status ?? this.status,
      views: views ?? this.views,
      downloads: downloads ?? this.downloads,
    );
  }

  /// ✅ Equatable properties for value-based equality
  @override
  List<Object?> get props => [
        id,
        college,
        branch,
        semester,
        subject,
        examType,
        imageUrl,
        pdfUrl,
        year,
        uploadedAt,
        status,
        views,
        downloads,
      ];

  /// ✅ Helper method to check if paper has PDF
  bool get hasPdf => pdfUrl.isNotEmpty;

  /// ✅ Helper method to check if paper is approved
  bool get isApproved => status == 'approved';

  /// ✅ Helper method to check if paper is pending
  bool get isPending => status == 'pending';

  /// ✅ Helper method to check if paper is rejected
  bool get isRejected => status == 'rejected';

  /// ✅ Get formatted upload date
  String get formattedUploadDate {
    final now = DateTime.now();
    final difference = now.difference(uploadedAt);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hours ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minutes ago';
    } else {
      return 'Just now';
    }
  }

  @override
  String toString() => 'QuestionPaper(id: $id, subject: $subject, examType: $examType)';
}

//
// ──────────────────────────────────────────────
// FILTER & STATE CLASSES
// ──────────────────────────────────────────────
//

/// Dropdown filter options used in search/filter UI
class FilterOptions extends Equatable {
  final List<String> colleges;
  final List<String> branches;
  final List<String> semesters;
  final List<String> subjects;
  final List<String> examTypes;

  const FilterOptions({
    this.colleges = const [],
    this.branches = const [],
    this.semesters = const [],
    this.subjects = const [],
    this.examTypes = const [],
  });

  FilterOptions copyWith({
    List<String>? colleges,
    List<String>? branches,
    List<String>? semesters,
    List<String>? subjects,
    List<String>? examTypes,
  }) {
    return FilterOptions(
      colleges: colleges ?? this.colleges,
      branches: branches ?? this.branches,
      semesters: semesters ?? this.semesters,
      subjects: subjects ?? this.subjects,
      examTypes: examTypes ?? this.examTypes,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters =>
      colleges.isNotEmpty ||
      branches.isNotEmpty ||
      semesters.isNotEmpty ||
      subjects.isNotEmpty ||
      examTypes.isNotEmpty;

  /// Clear all filters
  FilterOptions clearAll() {
    return const FilterOptions();
  }

  @override
  List<Object?> get props => [colleges, branches, semesters, subjects, examTypes];

  @override
  String toString() => 'FilterOptions(colleges: $colleges, branches: $branches)';
}

/// State model used by your Provider/Bloc for Question Papers
class QuestionPaperState extends Equatable {
  final List<QuestionPaper> papers;
  final FilterOptions filterOptions;
  final bool isLoading;
  final String? error;

  const QuestionPaperState({
    this.papers = const [],
    this.filterOptions = const FilterOptions(),
    this.isLoading = false,
    this.error,
  });

  QuestionPaperState copyWith({
    List<QuestionPaper>? papers,
    FilterOptions? filterOptions,
    bool? isLoading,
    String? error,
  }) {
    return QuestionPaperState(
      papers: papers ?? this.papers,
      filterOptions: filterOptions ?? this.filterOptions,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }

  /// Helper to clear error state
  QuestionPaperState clearError() {
    return copyWith(error: null);
  }

  /// Helper to check if there are papers
  bool get hasPapers => papers.isNotEmpty;

  /// Helper to get approved papers only
  List<QuestionPaper> get approvedPapers =>
      papers.where((paper) => paper.isApproved).toList();

  /// Helper to get pending papers count
  int get pendingCount => papers.where((paper) => paper.isPending).length;

  @override
  List<Object?> get props => [papers, filterOptions, isLoading, error];

  @override
  String toString() =>
      'QuestionPaperState(papers: ${papers.length}, isLoading: $isLoading, error: $error)';
}
