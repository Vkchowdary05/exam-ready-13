// lib/models/subject_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents a subject in a B.Tech curriculum.
class Subject {
  final String id;
  final String name;
  final String code;
  final String branch;
  final String semester;
  final int unitCount;
  final Map<String, double> unitWeightage; // e.g., {'Unit 1': 0.3, ...}
  final List<String> topTopics;

  const Subject({
    required this.id,
    required this.name,
    required this.code,
    required this.branch,
    required this.semester,
    this.unitCount = 5,
    this.unitWeightage = const {},
    this.topTopics = const [],
  });

  factory Subject.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Subject(
      id: doc.id,
      name: data['name'] as String? ?? '',
      code: data['code'] as String? ?? '',
      branch: data['branch'] as String? ?? '',
      semester: data['semester'] as String? ?? '',
      unitCount: data['unitCount'] as int? ?? 5,
      unitWeightage: Map<String, double>.from(
        (data['unitWeightage'] as Map<String, dynamic>? ?? {})
            .map((k, v) => MapEntry(k, (v as num).toDouble())),
      ),
      topTopics: List<String>.from(data['topTopics'] ?? []),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'code': code,
    'branch': branch,
    'semester': semester,
    'unitCount': unitCount,
    'unitWeightage': unitWeightage,
    'topTopics': topTopics,
  };
}
