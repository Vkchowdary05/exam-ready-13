// lib/models/question_paper.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

/// Unified QuestionPaper model combining fields and helpers from both
/// previous implementations. Supports flexible Firestore field names
/// (snake_case and camelCase) and multiple timestamp formats.
class QuestionPaper extends Equatable {
  final String id;
  final String college;
  final String branch;
  final String semester;
  final String subject;
  final String examType;
  final String imageUrl;
  final String pdfUrl;
  final String year;
  final DateTime uploadedAt; // canonical upload timestamp
  final String status; // pending, approved, rejected
  final int views;
  final int downloads;
  final int likes;
  final String userId;

  const QuestionPaper({
    required this.id,
    required this.college,
    required this.branch,
    required this.semester,
    required this.subject,
    required this.examType,
    required this.imageUrl,
    this.pdfUrl = '',
    this.year = '',
    required this.uploadedAt,
    this.status = 'pending',
    this.views = 0,
    this.downloads = 0,
    this.likes = 0,
    this.userId = '',
  });

  /// Flexible factory from Firestore DocumentSnapshot that handles both
  /// snake_case and camelCase field names and multiple timestamp formats.
  factory QuestionPaper.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data();
    final data = (raw is Map<String, dynamic>) ? raw : <String, dynamic>{};

    // Helper to read with fallback keys
    T? read<T>(List<String> keys, {T? defaultValue}) {
      for (final k in keys) {
        if (data.containsKey(k) && data[k] != null) {
          return data[k] as T;
        }
      }
      return defaultValue;
    }

    // Determine timestamp: try multiple possible keys
    final dynamic uploadedRaw = read<dynamic>(['uploaded_at', 'uploadedAt', 'timestamp', 'createdAt']);
    final DateTime uploadedAt = _parseTimestamp(uploadedRaw);

    return QuestionPaper(
      id: doc.id,
      college: (read<String>(['college']) ?? 'Unknown'),
      branch: (read<String>(['branch']) ?? 'Unknown'),
      semester: (read<String>(['semester']) ?? 'Unknown'),
      subject: (read<String>(['subject']) ?? 'Unknown'),
      examType: (read<String>(['exam_type', 'examType']) ?? 'Unknown'),
      imageUrl: (read<String>(['image_url', 'imageUrl']) ?? ''),
      pdfUrl: (read<String>(['pdf_url', 'pdfUrl']) ?? ''),
      year: (read<String>(['year']) ?? ''),
      uploadedAt: uploadedAt,
      status: (read<String>(['status']) ?? 'pending'),
      views: (read<int>(['views']) ?? 0),
      downloads: (read<int>(['downloads']) ?? 0),
      likes: (read<int>(['likes']) ?? 0),
      userId: (read<String>(['userId', 'user_id', 'uploadedBy']) ?? ''),
    );
  }

  /// Factory from a plain Map (e.g., decoded JSON) with an explicit id
  factory QuestionPaper.fromMap(Map<String, dynamic> map, String id) {
    // Same flexible parsing as above
    dynamic read(List<String> keys) {
      for (final k in keys) {
        if (map.containsKey(k) && map[k] != null) return map[k];
      }
      return null;
    }

    final uploadedRaw = read(['uploaded_at', 'uploadedAt', 'timestamp', 'createdAt']);
    final uploadedAt = _parseTimestamp(uploadedRaw);

    return QuestionPaper(
      id: id,
      college: (read(['college']) as String?) ?? 'Unknown',
      branch: (read(['branch']) as String?) ?? 'Unknown',
      semester: (read(['semester']) as String?) ?? 'Unknown',
      subject: (read(['subject']) as String?) ?? 'Unknown',
      examType: (read(['exam_type', 'examType']) as String?) ?? 'Unknown',
      imageUrl: (read(['image_url', 'imageUrl']) as String?) ?? '',
      pdfUrl: (read(['pdf_url', 'pdfUrl']) as String?) ?? '',
      year: (read(['year']) as String?) ?? '',
      uploadedAt: uploadedAt,
      status: (read(['status']) as String?) ?? 'pending',
      views: (read(['views']) as int?) ?? (read(['views']) is String ? int.tryParse(read(['views'])) ?? 0 : 0),
      downloads: (read(['downloads']) as int?) ?? 0,
      likes: (read(['likes']) as int?) ?? 0,
      userId: (read(['userId', 'user_id', 'uploadedBy']) as String?) ?? '',
    );
  }

  /// Convert to Firestore-friendly map (uses camelCase keys).
  /// Use this when writing/updating documents; consistent naming helps.
  Map<String, dynamic> toMap() {
    return {
      'college': college,
      'branch': branch,
      'semester': semester,
      'subject': subject,
      'examType': examType,
      'imageUrl': imageUrl,
      'pdfUrl': pdfUrl,
      'year': year,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'status': status,
      'views': views,
      'downloads': downloads,
      'likes': likes,
      'userId': userId,
    };
  }

  /// Defensive timestamp parser: supports Timestamp, DateTime, int, String
  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();

    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    if (timestamp is int) return DateTime.fromMillisecondsSinceEpoch(timestamp);
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (e) {
        // try to parse as integer string (ms since epoch)
        final ms = int.tryParse(timestamp);
        if (ms != null) return DateTime.fromMillisecondsSinceEpoch(ms);
      }
    }
    return DateTime.now();
  }

  /// CopyWith for immutability
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
    int? likes,
    String? userId,
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
      likes: likes ?? this.likes,
      userId: userId ?? this.userId,
    );
  }

  // ---------- Helpers & computed properties ----------

  bool get hasPdf => pdfUrl.isNotEmpty;
  bool get isApproved => status.toLowerCase() == 'approved';
  bool get isPending => status.toLowerCase() == 'pending';
  bool get isRejected => status.toLowerCase() == 'rejected';

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

  /// Similar to previous implementation: "Just now", "5m ago", "2d ago" or date
  String get shortFormattedDate {
    final now = DateTime.now();
    final difference = now.difference(uploadedAt);

    if (difference.inDays == 0) {
      if (difference.inHours == 0) {
        if (difference.inMinutes == 0) return 'Just now';
        return '${difference.inMinutes}m ago';
      }
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
      return '${uploadedAt.day} ${months[uploadedAt.month - 1]} ${uploadedAt.year}';
    }
  }

  bool get isRecent {
    final now = DateTime.now();
    final difference = now.difference(uploadedAt);
    return difference.inDays <= 7;
  }

  bool get isPopular => likes > 10;

  int? get semesterNumber {
    final match = RegExp(r'\d+').firstMatch(semester);
    if (match != null) return int.tryParse(match.group(0)!);
    return null;
  }

  String get examTypeAbbr {
    final lower = examType.toLowerCase();
    if (lower.contains('mid')) {
      final match = RegExp(r'\d+').firstMatch(examType);
      if (match != null) return 'M${match.group(0)}';
      return 'Mid';
    } else if (lower.contains('end')) {
      return 'End';
    } else if (lower.contains('final')) {
      return 'Final';
    }
    return examType;
  }

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
        likes,
        userId,
      ];

  @override
  String toString() {
    return 'QuestionPaper(id: $id, subject: $subject, examType: $examType, semester: $semester, college: $college, branch: $branch, likes: $likes, userId: $userId)';
  }
}
