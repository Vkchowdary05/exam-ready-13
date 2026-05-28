// lib/utils/constants.dart

import 'dart:ui';

/// Business logic constants for Exam Ready.
///
/// All magic numbers and thresholds should be defined here.
class AppConstants {
  AppConstants._();

  // ─── Upload Limits ───────────────────────────────────────────────
  /// Maximum file size for image uploads (5 MB)
  static const int maxFileSizeBytes = 5 * 1024 * 1024;

  /// Maximum uploads per user per day
  static const int maxDailyUploads = 10;

  /// Allowed image extensions for upload
  static const List<String> allowedImageExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
  ];

  /// Image compression target width
  static const int compressionTargetWidth = 1200;

  /// Image compression quality (0-100)
  static const int compressionQuality = 80;

  // ─── OCR ─────────────────────────────────────────────────────────
  /// Minimum OCR confidence to accept extraction (0.0–1.0)
  static const double ocrConfidenceThreshold = 0.3;

  /// Minimum extracted text length to consider valid
  static const int minimumOCRTextLength = 50;

  // ─── API Timeouts ────────────────────────────────────────────────
  /// HTTP request timeout for Groq API calls
  static const Duration groqTimeout = Duration(seconds: 30);

  /// HTTP request timeout for Cloudinary uploads
  static const Duration cloudinaryTimeout = Duration(seconds: 60);

  /// HTTP request timeout for Firestore operations
  static const Duration firestoreTimeout = Duration(seconds: 30);

  /// Number of retry attempts for failed API calls
  static const int maxRetryAttempts = 2;

  /// Base delay for exponential backoff
  static const Duration retryBaseDelay = Duration(seconds: 2);

  // ─── Topic Analysis ──────────────────────────────────────────────
  /// Minimum appearances for "Hot Topic" badge
  static const int hotTopicThreshold = 3;

  /// Years gap for "Due for Repeat" badge
  static const int dueTopicYearsGap = 2;

  /// Maximum topics to extract from a single paper
  static const int maxTopicsPerPaper = 30;

  // ─── Voting ──────────────────────────────────────────────────────
  /// Net downvote threshold for auto-flagging papers
  static const int autoFlagThreshold = -5;

  // ─── Pagination ──────────────────────────────────────────────────
  /// Default page size for Firestore queries
  static const int defaultPageSize = 20;

  /// Maximum results for search queries
  static const int maxSearchResults = 50;

  // ─── Gamification ────────────────────────────────────────────────
  /// XP awarded for uploading a paper
  static const int xpPerUpload = 50;

  /// XP awarded per upvote received
  static const int xpPerUpvote = 5;

  /// XP required for level up
  static const int xpPerLevel = 200;

  /// Streak bonus XP multiplier
  static const double streakBonusMultiplier = 1.5;

  // ─── Study Groups ───────────────────────────────────────────────
  /// Maximum members per study group
  static const int maxGroupMembers = 50;

  /// Pomodoro study session duration (minutes)
  static const int pomodoroStudyMinutes = 25;

  /// Pomodoro break duration (minutes)
  static const int pomodoroBreakMinutes = 5;

  // ─── UI ──────────────────────────────────────────────────────────
  /// Card border radius
  static const double cardRadius = 20.0;

  /// Button border radius (pill shape)
  static const double buttonRadius = 50.0;

  /// Chip/tag border radius
  static const double chipRadius = 8.0;

  /// Input field border radius
  static const double inputRadius = 14.0;

  /// Large container border radius
  static const double containerRadius = 24.0;

  /// Minimum button height
  static const double minButtonHeight = 52.0;

  /// Button horizontal padding
  static const double buttonPaddingH = 28.0;

  /// Bottom nav icon size
  static const double navIconSize = 22.0;

  // ─── Cache ───────────────────────────────────────────────────────
  /// Maximum papers to cache offline
  static const int maxCachedPapers = 50;

  /// Cache expiry duration
  static const Duration cacheExpiry = Duration(days: 7);

  /// Number of papers to pre-cache on WiFi
  static const int preCacheCount = 5;

  // ─── Firestore Collections ───────────────────────────────────────
  static const String usersCollection = 'users';
  static const String papersCollection = 'submitted_papers';
  static const String questionPapersCollection = 'question_papers';
  static const String questionsCollection = 'questions';
  static const String topicsCollection = 'topics';
  static const String subjectsCollection = 'subjects';
  static const String collegesCollection = 'colleges';
  static const String studyGroupsCollection = 'study_groups';
  static const String doubtsCollection = 'doubts';
  static const String notificationsCollection = 'notifications';
  static const String paperRequestsCollection = 'paper_requests';
  static const String adminQueueCollection = 'admin_queue';
  static const String platformStatsCollection = 'platform_stats';
  static const String dailyUploadsCollection = 'daily_uploads';
  static const String votesCollection = 'votes';
}
