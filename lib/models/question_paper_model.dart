import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a Question Paper document
/// Compatible with the new submitted_papers schema.
class QuestionPaper {
  final String id;
  final String college;
  final String branch;
  final String semester;
  final String subject;
  final String examType;
  final String imageUrl;
  final String imagePublicId;
  final String uploadedBy; // userId
  String uploadedByName; // userName/email
  final DateTime uploadedAt;
  // Convenience getters for newer naming
  // Returns uploader name if already stored in document.
  // If missing, it will fetch from Firestore and cache it.
  String get userName {
    if (uploadedByName.isNotEmpty) return uploadedByName;

    // Start async fetch — cannot await inside getter
    _fetchAndCacheUserName();

    return ''; // temporarily empty until async loads
  }

  String get userId => uploadedBy;

  QuestionPaper({
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
  });

  // ---------------------------------------------------------------------------
  //  READ HELPERS
  // ---------------------------------------------------------------------------

  /// Flexible reader with multiple fallback key names
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

  /// Timestamp parser supporting multiple formats
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

  // ---------------------------------------------------------------------------
  //  FACTORY: From Firestore Document
  // ---------------------------------------------------------------------------

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
      uploadedByName:
          _read(data, [
            'uploadedByName',
            'userName',
            'user_name',
            'uploaderName',
          ]) ??
          '',
      uploadedAt: uploadedAt,
    );
  }

  // ---------------------------------------------------------------------------
  //  FACTORY: From Map (Dashboard summaries, custom aggregations, etc.)
  // ---------------------------------------------------------------------------

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
      uploadedByName:
          _read(map, [
            'uploadedByName',
            'userName',
            'user_name',
            'uploaderName',
          ]) ??
          '',
      uploadedAt: uploadedAt,
    );
  }

  // ---------------------------------------------------------------------------
  //  TO MAP
  // ---------------------------------------------------------------------------

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
    };
  }

  // ---------------------------------------------------------------------------
  //  COPYWITH
  // ---------------------------------------------------------------------------

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
    );
  }

  // Cache variable so we don't fetch repeatedly
  static final Map<String, String> _userNameCache = {};

  Future<void> _fetchAndCacheUserName() async {
    // If cached, do not fetch again
    if (_userNameCache.containsKey(uploadedBy)) return;

    try {
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(uploadedBy)
          .get();

      if (snap.exists) {
        final data = snap.data() as Map<String, dynamic>?;
        final name = data?['name'] as String? ?? '';

        if (name.isNotEmpty) {
          _userNameCache[uploadedBy] = name;

          // Update this instance internally
          // (your UI must rebuild to reflect updated name)
          uploadedByName = name;
        }
      }
    } catch (e) {
      print("⚠️ Failed to fetch username for $uploadedBy: $e");
    }
  }
}
