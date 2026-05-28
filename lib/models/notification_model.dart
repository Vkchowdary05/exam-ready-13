// lib/models/notification_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// In-app notification model.
class AppNotification {
  final String id;
  final String userId;
  final String type;       // 'paper_added', 'doubt_answered', 'group_invite', etc.
  final String title;
  final String description;
  final String? targetId;  // ID of the related entity (paper, doubt, group)
  final bool read;
  final DateTime createdAt;

  const AppNotification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.description,
    this.targetId,
    this.read = false,
    required this.createdAt,
  });

  factory AppNotification.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return AppNotification(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: data['type'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      targetId: data['targetId'] as String?,
      read: data['read'] as bool? ?? false,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
    'userId': userId,
    'type': type,
    'title': title,
    'description': description,
    'targetId': targetId,
    'read': read,
    'createdAt': FieldValue.serverTimestamp(),
  };
}
