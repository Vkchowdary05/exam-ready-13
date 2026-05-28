// lib/models/paper_request_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// A request for a missing question paper.
///
/// Students can request papers that haven't been uploaded yet,
/// and other students can fulfill them.
class PaperRequest {
  final String id;
  final String userId;
  final String userName;
  final String college;
  final String branch;
  final String semester;
  final String subject;
  final String examType;
  final String? year;
  final String? note;
  final bool isFulfilled;
  final String? fulfilledBy;
  final String? fulfilledPaperId;
  final int upvotes;
  final DateTime createdAt;

  const PaperRequest({
    required this.id,
    required this.userId,
    required this.userName,
    required this.college,
    required this.branch,
    required this.semester,
    required this.subject,
    required this.examType,
    this.year,
    this.note,
    this.isFulfilled = false,
    this.fulfilledBy,
    this.fulfilledPaperId,
    this.upvotes = 0,
    required this.createdAt,
  });

  factory PaperRequest.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return PaperRequest(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? '',
      college: data['college'] as String? ?? '',
      branch: data['branch'] as String? ?? '',
      semester: data['semester'] as String? ?? '',
      subject: data['subject'] as String? ?? '',
      examType: data['examType'] as String? ?? '',
      year: data['year'] as String?,
      note: data['note'] as String?,
      isFulfilled: data['isFulfilled'] as bool? ?? false,
      fulfilledBy: data['fulfilledBy'] as String?,
      fulfilledPaperId: data['fulfilledPaperId'] as String?,
      upvotes: data['upvotes'] as int? ?? 0,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userName': userName,
    'college': college,
    'branch': branch,
    'semester': semester,
    'subject': subject,
    'examType': examType,
    'year': year,
    'note': note,
    'isFulfilled': isFulfilled,
    'fulfilledBy': fulfilledBy,
    'fulfilledPaperId': fulfilledPaperId,
    'upvotes': upvotes,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
