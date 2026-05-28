// lib/models/user_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';

/// Expanded user model with gamification, profile, and preference fields.
class UserModel {
  final String uid;
  final String email;
  final String? name;
  final String? displayName;
  final String? photoUrl;
  final String role;             // 'user', 'admin'

  // ── Profile ────────────────────────────────────────────────────
  final String? college;
  final String? branch;
  final String? semester;

  // ── Gamification ───────────────────────────────────────────────
  final int papersUploaded;
  final int contributorXP;
  final int streakDays;
  final int level;
  final List<String> badges;

  // ── Data ───────────────────────────────────────────────────────
  final List<String> bookmarkedPapers;
  final List<String> enrolledSubjects;

  // ── Timestamps ─────────────────────────────────────────────────
  final DateTime? createdAt;
  final DateTime? lastActive;

  const UserModel({
    required this.uid,
    required this.email,
    this.name,
    this.displayName,
    this.photoUrl,
    this.role = 'user',
    this.college,
    this.branch,
    this.semester,
    this.papersUploaded = 0,
    this.contributorXP = 0,
    this.streakDays = 0,
    this.level = 1,
    this.badges = const [],
    this.bookmarkedPapers = const [],
    this.enrolledSubjects = const [],
    this.createdAt,
    this.lastActive,
  });

  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return UserModel(
      uid: doc.id,
      email: data['email'] as String? ?? '',
      name: data['name'] as String?,
      displayName: data['displayName'] as String? ?? data['name'] as String?,
      photoUrl: data['photoUrl'] as String?,
      role: data['role'] as String? ?? 'user',
      college: data['college'] as String?,
      branch: data['branch'] as String?,
      semester: data['semester'] as String?,
      papersUploaded: data['papersUploaded'] as int? ?? 0,
      contributorXP: data['contributorXP'] as int? ?? 0,
      streakDays: data['streakDays'] as int? ?? 0,
      level: data['level'] as int? ?? 1,
      badges: List<String>.from(data['badges'] ?? []),
      bookmarkedPapers: List<String>.from(data['bookmarkedPapers'] ?? []),
      enrolledSubjects: List<String>.from(data['enrolledSubjects'] ?? []),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      lastActive: (data['lastActive'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() => {
    'uid': uid,
    'email': email,
    'name': name,
    'displayName': displayName,
    'photoUrl': photoUrl,
    'role': role,
    'college': college,
    'branch': branch,
    'semester': semester,
    'papersUploaded': papersUploaded,
    'contributorXP': contributorXP,
    'streakDays': streakDays,
    'level': level,
    'badges': badges,
    'bookmarkedPapers': bookmarkedPapers,
    'enrolledSubjects': enrolledSubjects,
  };

  UserModel copyWith({
    String? uid,
    String? email,
    String? name,
    String? displayName,
    String? photoUrl,
    String? role,
    String? college,
    String? branch,
    String? semester,
    int? papersUploaded,
    int? contributorXP,
    int? streakDays,
    int? level,
    List<String>? badges,
    List<String>? bookmarkedPapers,
    List<String>? enrolledSubjects,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      college: college ?? this.college,
      branch: branch ?? this.branch,
      semester: semester ?? this.semester,
      papersUploaded: papersUploaded ?? this.papersUploaded,
      contributorXP: contributorXP ?? this.contributorXP,
      streakDays: streakDays ?? this.streakDays,
      level: level ?? this.level,
      badges: badges ?? this.badges,
      bookmarkedPapers: bookmarkedPapers ?? this.bookmarkedPapers,
      enrolledSubjects: enrolledSubjects ?? this.enrolledSubjects,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  /// XP needed for next level
  int get xpToNextLevel => (level * 200) - contributorXP;

  /// Level progress (0.0–1.0)
  double get levelProgress {
    final required = level * 200;
    if (required <= 0) return 0;
    return (contributorXP % required) / required;
  }

  /// Whether the user has completed onboarding (has college/branch set)
  bool get hasCompletedOnboarding =>
      college != null && branch != null && semester != null;

  /// Whether user is admin
  bool get isAdmin => role == 'admin';
}
