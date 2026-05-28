// lib/models/question_paper_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a Question Paper document.
///
/// Compatible with the `submitted_papers` collection schema.
/// Expanded with voting, topics, views, verification, and flagging fields.
class QuestionPaper {
  final String id;
  final String college;
  final String branch;
  final String semester;
  final String subject;
  final String examType;
  final String imageUrl;
  final String imagePublicId;
  final String uploadedBy;     // userId
  final String uploadedByName; // userName/email
  final DateTime uploadedAt;

  // ── New fields ─────────────────────────────────────────────────
  final List<String> topics;
  final int upvotes;
  final int downvotes;
  final int views;
  final bool verified;
  final bool flagged;
  final String? flagReason;
  final String? year;         // exam year
  final double? ocrConfidence;
  final String status;        // 'pending', 'approved', 'rejected'

  // Convenience getters
  String get userName => uploadedByName;
  String get userId => uploadedBy;
  int get netVotes => upvotes - downvotes;

  /// Quality badge based on OCR confidence
  String get qualityBadge {
    if (ocrConfidence == null) return '';
    if (ocrConfidence! >= 0.7) return '📸 Good';
    if (ocrConfidence! >= 0.4) return '📸 Fair';
    return '📸 Poor';
  }

  const QuestionPaper({
    required this.id,
    required this.college,
    required this.branch,
    required this.semester,
    required this.subject,
    required this.examType,
    required this.imageUrl,
    required this.imagePublicId,
    required this.uploadedBy,
    required this.uploadedByName,
    required this.uploadedAt,
    this.topics = const [],
    this.upvotes = 0,
    this.downvotes = 0,
    this.views = 0,
    this.verified = false,
    this.flagged = false,
    this.flagReason,
    this.year,
    this.ocrConfidence,
    this.status = 'pending',
  });

  // ─── Read Helpers ──────────────────────────────────────────────

  static T? _read<T>(
    Map<String, dynamic> data,
    List<String> keys, {
    T? defaultValue,
  }) {
    for (final k in keys) {
      if (data.containsKey(k) && data[k] != null) {
        return data[k] as T;
      }
    }
    return defaultValue;
  }

  static DateTime _parseTimestamp(dynamic timestamp) {
    if (timestamp == null) return DateTime.now();
    if (timestamp is Timestamp) return timestamp.toDate();
    if (timestamp is DateTime) return timestamp;
    if (timestamp is int) {
      return DateTime.fromMillisecondsSinceEpoch(timestamp);
    }
    if (timestamp is String) {
      try {
        return DateTime.parse(timestamp);
      } catch (_) {
        final ms = int.tryParse(timestamp);
        if (ms != null) {
          return DateTime.fromMillisecondsSinceEpoch(ms);
        }
      }
    }
    return DateTime.now();
  }

  // ─── Factory: From Firestore ───────────────────────────────────

  factory QuestionPaper.fromFirestore(DocumentSnapshot doc) {
    final raw = doc.data();
    final Map<String, dynamic> data = raw is Map<String, dynamic>
        ? raw
        : <String, dynamic>{};

    final uploadedAt = _parseTimestamp(
      _read(data, ['uploadedAt', 'uploaded_at', 'timestamp', 'createdAt']),
    );

    return QuestionPaper(
      id: doc.id,
      college: _read(data, ['college']) ?? 'Unknown',
      branch: _read(data, ['branch']) ?? 'Unknown',
      semester: _read(data, ['semester']) ?? 'Unknown',
      subject: _read(data, ['subject']) ?? 'Unknown',
      examType: _read(data, ['examType', 'exam_type']) ?? 'Unknown',
      imageUrl: _read(data, ['imageUrl', 'image_url']) ?? '',
      imagePublicId: _read(data, ['imagePublicId', 'image_public_id']) ?? '',
      uploadedBy: _read(data, ['uploadedBy', 'userId', 'user_id']) ?? '',
      uploadedByName: _read(data, [
            'uploadedByName', 'userName', 'user_name', 'uploaderName',
          ]) ?? '',
      uploadedAt: uploadedAt,
      topics: List<String>.from(data['topics'] ?? []),
      upvotes: data['upvotes'] as int? ?? data['likes'] as int? ?? 0,
      downvotes: data['downvotes'] as int? ?? 0,
      views: data['views'] as int? ?? 0,
      verified: data['verified'] as bool? ?? false,
      flagged: data['flagged'] as bool? ?? false,
      flagReason: data['flagReason'] as String?,
      year: data['year'] as String?,
      ocrConfidence: (data['ocrConfidence'] as num?)?.toDouble(),
      status: data['status'] as String? ?? 'pending',
    );
  }

  // ─── Factory: From Map ─────────────────────────────────────────

  factory QuestionPaper.fromMap(Map<String, dynamic> map, String id) {
    final uploadedAt = _parseTimestamp(
      _read(map, ['uploadedAt', 'uploaded_at', 'timestamp', 'createdAt']),
    );

    return QuestionPaper(
      id: id,
      college: _read(map, ['college']) ?? 'Unknown',
      branch: _read(map, ['branch']) ?? 'Unknown',
      semester: _read(map, ['semester']) ?? 'Unknown',
      subject: _read(map, ['subject']) ?? 'Unknown',
      examType: _read(map, ['examType', 'exam_type']) ?? 'Unknown',
      imageUrl: _read(map, ['imageUrl', 'image_url']) ?? '',
      imagePublicId: _read(map, ['imagePublicId', 'image_public_id']) ?? '',
      uploadedBy: _read(map, ['uploadedBy', 'userId', 'user_id']) ?? '',
      uploadedByName: _read(map, [
            'uploadedByName', 'userName', 'user_name', 'uploaderName',
          ]) ?? '',
      uploadedAt: uploadedAt,
      topics: List<String>.from(map['topics'] ?? []),
      upvotes: map['upvotes'] as int? ?? 0,
      downvotes: map['downvotes'] as int? ?? 0,
      views: map['views'] as int? ?? 0,
      verified: map['verified'] as bool? ?? false,
      flagged: map['flagged'] as bool? ?? false,
      flagReason: map['flagReason'] as String?,
      year: map['year'] as String?,
      ocrConfidence: (map['ocrConfidence'] as num?)?.toDouble(),
      status: map['status'] as String? ?? 'pending',
    );
  }

  // ─── To Map ────────────────────────────────────────────────────

  Map<String, dynamic> toMap() {
    return {
      'college': college,
      'branch': branch,
      'semester': semester,
      'subject': subject,
      'examType': examType,
      'imageUrl': imageUrl,
      'imagePublicId': imagePublicId,
      'uploadedBy': uploadedBy,
      'uploadedByName': uploadedByName,
      'uploadedAt': Timestamp.fromDate(uploadedAt),
      'topics': topics,
      'upvotes': upvotes,
      'downvotes': downvotes,
      'views': views,
      'verified': verified,
      'flagged': flagged,
      'flagReason': flagReason,
      'year': year,
      'ocrConfidence': ocrConfidence,
      'status': status,
    };
  }

  // ─── CopyWith ──────────────────────────────────────────────────

  QuestionPaper copyWith({
    String? id,
    String? college,
    String? branch,
    String? semester,
    String? subject,
    String? examType,
    String? imageUrl,
    String? imagePublicId,
    String? uploadedBy,
    String? uploadedByName,
    DateTime? uploadedAt,
    List<String>? topics,
    int? upvotes,
    int? downvotes,
    int? views,
    bool? verified,
    bool? flagged,
    String? flagReason,
    String? year,
    double? ocrConfidence,
    String? status,
  }) {
    return QuestionPaper(
      id: id ?? this.id,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      subject: subject ?? this.subject,
      examType: examType ?? this.examType,
      imageUrl: imageUrl ?? this.imageUrl,
      imagePublicId: imagePublicId ?? this.imagePublicId,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      uploadedByName: uploadedByName ?? this.uploadedByName,
      uploadedAt: uploadedAt ?? this.uploadedAt,
      topics: topics ?? this.topics,
      upvotes: upvotes ?? this.upvotes,
      downvotes: downvotes ?? this.downvotes,
      views: views ?? this.views,
      verified: verified ?? this.verified,
      flagged: flagged ?? this.flagged,
      flagReason: flagReason ?? this.flagReason,
      year: year ?? this.year,
      ocrConfidence: ocrConfidence ?? this.ocrConfidence,
      status: status ?? this.status,
    );
  }
}
