// lib/models/question_paper.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Model class representing a Question Paper document
/// Contains all metadata about an uploaded exam paper
class QuestionPaper {
  final String id;
  final String college;
  final String branch;
  final String semester;
  final String subject;
  final String examType;
  final String imageUrl;
  final String imagePublicId;
  final String uploadedBy;
  final String uploadedByName;
  final DateTime uploadedAt;

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

  /// Factory constructor to create QuestionPaper from Firestore document
  factory QuestionPaper.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionPaper(
      id: doc.id,
      college: data['college'] ?? '',
      branch: data['branch'] ?? '',
      semester: data['semester'] ?? '',
      subject: data['subject'] ?? '',
      examType: data['examType'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      imagePublicId: data['imagePublicId'] ?? '',
      uploadedBy: data['uploadedBy'] ?? '',
      uploadedByName: data['uploadedByName'] ?? 'Anonymous',
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Convert QuestionPaper to Map for Firestore upload
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

  /// Create a copy of QuestionPaper with updated fields
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
}