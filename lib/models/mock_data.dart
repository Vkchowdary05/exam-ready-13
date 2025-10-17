/// Mock data models and sample JSON for the exam_ready profile page.
/// This file contains data classes, JSON serialization, and mock API responses.

import 'dart:convert';

// ─────────────────────────────────────────────────────────────
// Data Models
// ─────────────────────────────────────────────────────────────

/// Represents a single exam paper posted by a user.
class ExamPaper {
  final String id;
  final String title;
  final DateTime? postedDate;
  final int? questionCount;

  ExamPaper({
    required this.id,
    required this.title,
    this.postedDate,
    this.questionCount,
  });

  /// Convert JSON to ExamPaper instance.
  factory ExamPaper.fromJson(Map<String, dynamic> json) {
    return ExamPaper(
      id: json['id'] ?? '',
      title: json['title'] ?? 'Untitled',
      postedDate: json['postedDate'] != null 
          ? DateTime.parse(json['postedDate']) 
          : null,
      questionCount: json['questionCount'],
    );
  }

  /// Convert ExamPaper to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'postedDate': postedDate?.toIso8601String(),
    'questionCount': questionCount,
  };
}

/// Represents a user profile with their posted exam papers.
class UserProfile {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final List<ExamPaper> papers;

  UserProfile({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.papers = const [],
  });

  /// Convert JSON to UserProfile instance.
  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] ?? '',
      name: json['name'] ?? 'User',
      email: json['email'] ?? '',
      avatarUrl: json['avatarUrl'],
      papers: (json['papers'] as List<dynamic>?)
              ?.map((p) => ExamPaper.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Convert UserProfile to JSON.
  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'email': email,
    'avatarUrl': avatarUrl,
    'papers': papers.map((p) => p.toJson()).toList(),
  };

  /// Getter for paper count.
  int get paperCount => papers.length;
}

// ─────────────────────────────────────────────────────────────
// Mock Data & API Simulation
// ─────────────────────────────────────────────────────────────

/// Sample JSON response (mock API data).
const String mockUserProfileJson = '''
{
  "id": "user_01",
  "name": "Aisha Khan",
  "email": "aisha.khan@example.com",
  "avatarUrl": "https://i.pravatar.cc/150?img=25",
  "papers": [
    {
      "id": "p1",
      "title": "Physics Final 2024",
      "postedDate": "2024-12-01T10:30:00Z",
      "questionCount": 45
    },
    {
      "id": "p2",
      "title": "Calculus Midterm - Spring",
      "postedDate": "2024-11-15T14:20:00Z",
      "questionCount": 30
    },
    {
      "id": "p3",
      "title": "World History - Practice",
      "postedDate": "2024-10-28T09:00:00Z",
      "questionCount": 50
    },
    {
      "id": "p4",
      "title": "Biology Lab Report",
      "postedDate": "2024-10-10T11:45:00Z",
      "questionCount": 25
    }
  ]
}
''';

/// Empty profile mock (for testing empty state).
const String mockEmptyUserProfileJson = '''
{
  "id": "user_02",
  "name": "John Doe",
  "email": "john.doe@example.com",
  "avatarUrl": "https://i.pravatar.cc/150?img=42",
  "papers": []
}
''';

/// Mock API response function. In production, replace with actual HTTP call.
Future<UserProfile> fetchUserProfile({bool empty = false}) async {
  // Simulate network delay.
  await Future.delayed(const Duration(milliseconds: 800));

  final jsonString = empty ? mockEmptyUserProfileJson : mockUserProfileJson;
  final json = jsonDecode(jsonString) as Map<String, dynamic>;
  return UserProfile.fromJson(json);
}