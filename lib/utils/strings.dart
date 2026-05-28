// lib/utils/strings.dart

/// Centralized user-facing strings.
///
/// All hardcoded UI text should reference this file.
/// This makes future i18n/localization straightforward.
class AppStrings {
  AppStrings._();

  // ─── App Identity ────────────────────────────────────────────────
  static const String appName = 'EXAM READY';
  static const String appTagline = 'Know what matters.';
  static const String appDescription =
      'Your AI-powered exam preparation companion';

  // ─── Onboarding ──────────────────────────────────────────────────
  static const String onboardingSlide1Title =
      '15,000+ papers. Zero WhatsApp hunting.';
  static const String onboardingSlide1Subtitle =
      'All your previous year papers in one place, organized and searchable.';
  static const String onboardingSlide2Title =
      'Know which topics repeat. Beat the pattern.';
  static const String onboardingSlide2Subtitle =
      'AI-powered topic analysis shows you exactly what to study.';
  static const String onboardingSlide3Title =
      'Your campus. Your papers. Your edge.';
  static const String onboardingSlide3Subtitle =
      'Join your college community and share knowledge.';
  static const String getStarted = 'Get Started';

  // ─── Auth ────────────────────────────────────────────────────────
  static const String welcomeBack = 'Welcome Back';
  static const String signInSubtitle =
      'Sign in to continue your exam preparation';
  static const String createAccount = 'Create Account';
  static const String signUpSubtitle =
      'Join thousands of students preparing smarter';
  static const String emailHint = 'Email Address';
  static const String passwordHint = 'Password';
  static const String nameHint = 'Full Name';
  static const String forgotPassword = 'Forgot Password?';
  static const String login = 'Login';
  static const String signUp = 'Sign Up';
  static const String continueWithGoogle = 'Continue with Google';
  static const String orDivider = 'OR';
  static const String noAccount = 'Don\'t have an account? ';
  static const String hasAccount = 'Already have an account? ';
  static const String passwordResetSent =
      'Password reset email sent! Check your inbox.';
  static const String enterEmailFirst =
      'Please enter your email address first';
  static const String googleSignInCancelled = 'Google Sign-In was cancelled';

  // ─── Email Verification ──────────────────────────────────────────
  static const String verifyEmail = 'Verify Your Email';
  static const String verifyEmailSubtitle =
      'We sent a verification link to your email. Please verify to continue.';
  static const String resendVerification = 'Resend Verification Email';
  static const String verificationSent = 'Verification email sent!';
  static const String checkVerification = 'I\'ve Verified';

  // ─── Dashboard ───────────────────────────────────────────────────
  static const String dashboard = 'Dashboard';
  static const String welcomeFormat = 'Hey %s, welcome back.';
  static const String searchPapers = 'Search Papers';
  static const String browseTopics = 'Browse Topics';
  static const String addPaper = 'Add Paper';
  static const String trendingThisWeek = 'Trending This Week';
  static const String hotTopics = 'Hot Topics Right Now';
  static const String yourSubjects = 'Your Subjects';
  static const String continueWhereYouLeft = 'Continue where you left off';
  static const String examCountdownLabel = 'Days to End-Sem';

  // ─── Search ──────────────────────────────────────────────────────
  static const String searchTitle = 'Search Papers';
  static const String searchHint = 'Search by subject, college, topic...';
  static const String noResults = 'No papers found';
  static const String noResultsSubtitle =
      'Try different filters or be the first to upload!';
  static const String beFirstToUpload = 'Be the first to upload';
  static const String recentSearches = 'Recent Searches';

  // ─── Upload ──────────────────────────────────────────────────────
  static const String uploadTitle = 'Upload Question Paper';
  static const String chooseMethod = 'Choose your upload method';
  static const String fromGallery = 'Gallery';
  static const String fromCamera = 'Camera';
  static const String captureTip =
      'Make sure the entire paper is visible and well-lit';
  static const String processing = 'Processing...';
  static const String readingPaper = 'Reading paper...';
  static const String extractingTopics = 'Extracting topics...';
  static const String savingToCloud = 'Saving to cloud...';
  static const String submitPaper = 'Submit Paper';
  static const String paperSubmitted = 'Paper submitted successfully!';
  static const String duplicateFound =
      'This paper already exists. Would you like to upvote it instead?';
  static const String ocrWarning =
      'We couldn\'t read this paper clearly. Would you like to retake the photo?';

  // ─── Paper Detail ────────────────────────────────────────────────
  static const String topicsInPaper = 'Topics in this paper';
  static const String reportIssue = 'Report Issue';
  static const String reportReasons = 'What\'s wrong with this paper?';
  static const String wrongSubject = 'Wrong subject';
  static const String wrongSemester = 'Wrong semester';
  static const String wrongCollege = 'Wrong college';
  static const String wrongYear = 'Wrong year';
  static const String poorQuality = 'Poor image quality';
  static const String inappropriate = 'Inappropriate content';

  // ─── Topics ──────────────────────────────────────────────────────
  static const String topicAnalysis = 'Topic Analysis';
  static const String hotBadge = '🔥 Hot';
  static const String dueBadge = '⚡ Due';
  static const String notedBadge = '📌 Noted';
  static const String appearedInExams = 'Appeared in %d exams';
  static const String topImportantTopics = 'Most Important Topics';
  static const String unitWeightage = 'Unit Weightage';
  static const String studyPriority = 'Study Priority';
  static const String mustStudy = 'Must';
  static const String shouldStudy = 'Should';
  static const String canSkip = 'Can Skip';

  // ─── Study Groups ───────────────────────────────────────────────
  static const String studyGroups = 'Study Groups';
  static const String myGroups = 'My Groups';
  static const String discoverGroups = 'Discover Groups';
  static const String createGroup = 'Create Group';
  static const String startStudySession = 'Start Study Session';
  static const String topicChecklist = 'Topic Checklist';

  // ─── Doubts ──────────────────────────────────────────────────────
  static const String doubts = 'Doubts';
  static const String postDoubt = 'Post a Doubt';
  static const String postAnonymously = 'Post Anonymously';
  static const String markResolved = 'Mark as Resolved';
  static const String addAnswer = 'Add an Answer';
  static const String yourDoubtAnswered = 'Your doubt has been answered!';

  // ─── Profile ─────────────────────────────────────────────────────
  static const String profile = 'Profile';
  static const String myBookmarks = 'My Bookmarks';
  static const String myUploads = 'My Uploads';
  static const String papersUploaded = 'Papers Uploaded';
  static const String topicsUnlocked = 'Topics Unlocked';
  static const String studyStreak = 'Study Streak';
  static const String xpPoints = 'XP Points';
  static const String logout = 'Logout';
  static const String logoutConfirm =
      'Are you sure you want to log out?';

  // ─── Leaderboard ─────────────────────────────────────────────────
  static const String leaderboard = 'Leaderboard';
  static const String thisWeek = 'This Week';
  static const String allTime = 'All Time';
  static const String myCollege = 'My College';
  static const String myBranch = 'My Branch';
  static const String allIndia = 'All India';

  // ─── Empty States ────────────────────────────────────────────────
  static const String emptyActivity = 'No recent activity';
  static const String emptyPapers = 'No papers yet';
  static const String emptyBookmarks = 'No bookmarks yet';
  static const String emptyGroups = 'No study groups yet';
  static const String emptyDoubts = 'No doubts posted yet';

  // ─── Errors ──────────────────────────────────────────────────────
  static const String genericError = 'Something went wrong. Please try again.';
  static const String noInternet =
      'No internet connection. Please check your network.';
  static const String timeout =
      'Request timed out. Please try again.';
  static const String sessionExpired =
      'Your session has expired. Please log in again.';
  static const String uploadFailed =
      'Upload failed. Please try again.';
  static const String dailyLimitReached =
      'Daily upload limit reached. Please try again tomorrow.';

  // ─── Badges ──────────────────────────────────────────────────────
  static const String badgePaperHunter = 'Paper Hunter 🏹';
  static const String badgeSeniorScholar = 'Senior Scholar 🎓';
  static const String badgeLegend = 'Legend 👑';
  static const String badgeFirstUpload = 'First Upload ⭐';
  static const String badgeStreakMaster = 'Streak Master 🔥';

  // ─── Quality Badges ──────────────────────────────────────────────
  static const String qualityGood = '📸 Good';
  static const String qualityFair = '📸 Fair';
  static const String qualityPoor = '📸 Poor';
  static const String verified = '✓ Verified';
}
