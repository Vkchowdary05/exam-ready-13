// lib/models/topic_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an aggregated topic across multiple question papers.
///
/// Used for the Topic Analysis / Heatmap feature.
class Topic {
  final String id;
  final String name;
  final String subject;
  final String branch;
  final int count;           // total appearances
  final List<String> papers; // paper IDs containing this topic
  final List<int> years;     // years this topic appeared
  final int lastSeenYear;
  final bool isHot;          // appeared ≥ 3 times
  final bool isDue;          // last seen ≥ 2 years ago

  const Topic({
    required this.id,
    required this.name,
    required this.subject,
    required this.branch,
    required this.count,
    this.papers = const [],
    this.years = const [],
    this.lastSeenYear = 0,
    this.isHot = false,
    this.isDue = false,
  });

  factory Topic.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final currentYear = DateTime.now().year;
    final yearsList = List<int>.from(data['years'] ?? []);
    final lastSeen = yearsList.isNotEmpty ? yearsList.reduce((a, b) => a > b ? a : b) : 0;
    final count = data['count'] as int? ?? 0;

    return Topic(
      id: doc.id,
      name: data['name'] as String? ?? '',
      subject: data['subject'] as String? ?? '',
      branch: data['branch'] as String? ?? '',
      count: count,
      papers: List<String>.from(data['papers'] ?? []),
      years: yearsList,
      lastSeenYear: lastSeen,
      isHot: count >= 3,
      isDue: lastSeen > 0 && (currentYear - lastSeen) >= 2,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'subject': subject,
    'branch': branch,
    'count': count,
    'papers': papers,
    'years': years,
    'lastSeenYear': lastSeenYear,
    'isHot': isHot,
    'isDue': isDue,
  };

  /// Priority score for ranking topics by importance.
  /// Higher = more important to study.
  double get priority {
    double score = count * 10.0;
    if (isHot) score += 20;
    if (isDue) score += 15;
    return score;
  }

  /// Badge text for UI display
  String? get badge {
    if (isHot && isDue) return '🔥⚡ Hot & Due';
    if (isHot) return '🔥 Hot';
    if (isDue) return '⚡ Due';
    return null;
  }
}
