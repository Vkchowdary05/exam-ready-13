// lib/models/doubt_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// A doubt posted by a student, optionally anonymous.
class Doubt {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final String subject;
  final String? topic;
  final bool isAnonymous;
  final bool isResolved;
  final int upvotes;
  final int answerCount;
  final DateTime createdAt;
  final List<Answer> answers;

  const Doubt({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    required this.subject,
    this.topic,
    this.isAnonymous = false,
    this.isResolved = false,
    this.upvotes = 0,
    this.answerCount = 0,
    required this.createdAt,
    this.answers = const [],
  });

  factory Doubt.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Doubt(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Anonymous',
      text: data['text'] as String? ?? '',
      subject: data['subject'] as String? ?? '',
      topic: data['topic'] as String?,
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      isResolved: data['isResolved'] as bool? ?? false,
      upvotes: data['upvotes'] as int? ?? 0,
      answerCount: data['answerCount'] as int? ?? 0,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userName': isAnonymous ? 'Anonymous' : userName,
    'text': text,
    'subject': subject,
    'topic': topic,
    'isAnonymous': isAnonymous,
    'isResolved': isResolved,
    'upvotes': upvotes,
    'answerCount': answerCount,
    'createdAt': FieldValue.serverTimestamp(),
  };

  /// Display name (respects anonymity)
  String get displayName => isAnonymous ? 'Anonymous' : userName;
}

/// An answer to a doubt.
class Answer {
  final String id;
  final String userId;
  final String userName;
  final String text;
  final int upvotes;
  final bool isAccepted;
  final DateTime createdAt;

  const Answer({
    required this.id,
    required this.userId,
    required this.userName,
    required this.text,
    this.upvotes = 0,
    this.isAccepted = false,
    required this.createdAt,
  });

  factory Answer.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Answer(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      userName: data['userName'] as String? ?? 'Anonymous',
      text: data['text'] as String? ?? '',
      upvotes: data['upvotes'] as int? ?? 0,
      isAccepted: data['isAccepted'] as bool? ?? false,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'userName': userName,
    'text': text,
    'upvotes': upvotes,
    'isAccepted': isAccepted,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
