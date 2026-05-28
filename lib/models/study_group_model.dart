// lib/models/study_group_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// A study group for collaborative exam preparation.
class StudyGroup {
  final String id;
  final String name;
  final String description;
  final String createdBy;
  final String creatorName;
  final String subject;
  final String? college;
  final String? branch;
  final List<String> memberIds;
  final int memberCount;
  final List<TopicCheckItem> topicChecklist;
  final DateTime createdAt;
  final DateTime? lastActive;

  const StudyGroup({
    required this.id,
    required this.name,
    required this.description,
    required this.createdBy,
    required this.creatorName,
    required this.subject,
    this.college,
    this.branch,
    this.memberIds = const [],
    this.memberCount = 0,
    this.topicChecklist = const [],
    required this.createdAt,
    this.lastActive,
  });

  factory StudyGroup.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    final checklist = (data['topicChecklist'] as List<dynamic>?)
            ?.map((e) => TopicCheckItem.fromMap(e as Map<String, dynamic>))
            .toList() ??
        [];

    return StudyGroup(
      id: doc.id,
      name: data['name'] as String? ?? '',
      description: data['description'] as String? ?? '',
      createdBy: data['createdBy'] as String? ?? '',
      creatorName: data['creatorName'] as String? ?? '',
      subject: data['subject'] as String? ?? '',
      college: data['college'] as String?,
      branch: data['branch'] as String?,
      memberIds: List<String>.from(data['memberIds'] ?? []),
      memberCount: data['memberCount'] as int? ?? 0,
      topicChecklist: checklist,
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'description': description,
    'createdBy': createdBy,
    'creatorName': creatorName,
    'subject': subject,
    'college': college,
    'branch': branch,
    'memberIds': memberIds,
    'memberCount': memberCount,
    'topicChecklist': topicChecklist.map((e) => e.toMap()).toList(),
    'createdAt': FieldValue.serverTimestamp(),
    'lastActive': FieldValue.serverTimestamp(),
  };

  /// Whether the current user is a member
  bool isMember(String userId) => memberIds.contains(userId);

  /// Completion percentage of the topic checklist
  double get completionPercent {
    if (topicChecklist.isEmpty) return 0;
    final completed = topicChecklist.where((t) => t.isCompleted).length;
    return completed / topicChecklist.length;
  }
}

/// A single topic in a study group's checklist.
class TopicCheckItem {
  final String topic;
  final bool isCompleted;
  final String? completedBy;

  const TopicCheckItem({
    required this.topic,
    this.isCompleted = false,
    this.completedBy,
  });

  factory TopicCheckItem.fromMap(Map<String, dynamic> data) {
    return TopicCheckItem(
      topic: data['topic'] as String? ?? '',
      isCompleted: data['isCompleted'] as bool? ?? false,
      completedBy: data['completedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'topic': topic,
    'isCompleted': isCompleted,
    'completedBy': completedBy,
  };
}
