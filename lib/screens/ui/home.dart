import 'package:exam_ready/models/question_paper_model.dart';
import 'package:exam_ready/screens/ui/profile_page.dart';
import 'package:exam_ready/screens/ui/search.dart';
import 'package:exam_ready/screens/ui/topics_search_page.dart';
import 'package:exam_ready/screens/ui/question_paper_submission_page.dart';
import 'package:exam_ready/providers/dashboard_provider.dart' as dashboard;
import 'package:exam_ready/services/firebase_service.dart';
import 'package:exam_ready/widgets/modern_loading_indicator.dart';
import 'package:exam_ready/widgets/animated_scale_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:exam_ready/providers/theme_provider.dart';

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen>
    with TickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  static const Color primaryColor = Color(0xFF6366F1);
  static const Color backgroundColor = Color(0xFFF8FAFC);
  static const Color cardColor = Color(0xFFFFFFFF);
  static const Color textPrimary = Color(0xFF1E293B);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color borderColor = Color(0xFFE2E8F0);
  static const Color accentBlue = Color(0xFF3B82F6);
  static const Color accentPurple = Color(0xFF8B5CF6);
  static const Color accentTeal = Color(0xFF06B6D4);

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final recentActivity = ref.watch(dashboard.recentActivityProvider);
    final recentQuestionPapers = ref.watch(
      dashboard.recentQuestionPapersProvider,
    );

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final screenWidth = constraints.maxWidth;
            final isMobile = screenWidth < 600;
            final isTablet = screenWidth >= 600 && screenWidth < 1024;
            final isDesktop = screenWidth >= 1024;

            return Column(
              children: [
                _buildHeader(isMobile, isTablet, isDesktop),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Center(
                      child: Container(
                        constraints: const BoxConstraints(maxWidth: 1400),
                        child: SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.symmetric(
                            horizontal: isMobile ? 20 : (isTablet ? 32 : 48),
                            vertical: isMobile ? 24 : (isTablet ? 28 : 32),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildQuickActions(isMobile, isTablet, isDesktop),
                              SizedBox(
                                height: isMobile ? 40 : (isTablet ? 48 : 56),
                              ),
                              _buildSectionTitle(
                                'Overview',
                                isMobile,
                                isTablet,
                              ),
                              SizedBox(
                                height: isMobile ? 20 : (isTablet ? 24 : 28),
                              ),
                              _buildStatsGrid(isMobile, isTablet, isDesktop),
                              SizedBox(
                                height: isMobile ? 40 : (isTablet ? 48 : 56),
                              ),
                              _buildSectionTitle(
                                'Recent Activity',
                                isMobile,
                                isTablet,
                              ),
                              SizedBox(
                                height: isMobile ? 20 : (isTablet ? 24 : 28),
                              ),
                              _buildRecentActivity(
                                recentActivity,
                                recentQuestionPapers,
                                isMobile,
                                isTablet,
                                isDesktop,
                              ),
                              SizedBox(
                                height: isMobile ? 24 : (isTablet ? 32 : 40),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
    );
  }

  Widget _buildHeader(bool isMobile, bool isTablet, bool isDesktop) {
    final titleSize = isMobile ? 24.0 : (isTablet ? 26.0 : 28.0);
    final subtitleSize = isMobile ? 13.0 : (isTablet ? 14.0 : 15.0);
    final horizontalPadding = isMobile ? 20.0 : (isTablet ? 32.0 : 48.0);
    final verticalPadding = isMobile ? 20.0 : (isTablet ? 24.0 : 28.0);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 1400),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Welcome Back',
                      style: GoogleFonts.inter(
                        fontSize: subtitleSize,
                        color: textSecondary,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.2,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Exam Ready',
                      style: GoogleFonts.inter(
                        fontSize: titleSize,
                        color: textPrimary,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  _buildHeaderIcon(Icons.notifications_none_rounded, () {
                    _showNotifications();
                  }, isMobile),
                  SizedBox(width: isMobile ? 12 : 16),
                  _buildHeaderIcon(Icons.settings_outlined, () {
                    _showSettings();
                  }, isMobile),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderIcon(IconData icon, VoidCallback onTap, bool isMobile) {
    final size = isMobile ? 22.0 : 24.0;
    final padding = isMobile ? 10.0 : 12.0;

    return AnimatedScaleButton(
      onPressed: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Icon(icon, color: textSecondary, size: size),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isMobile, bool isTablet) {
    final fontSize = isMobile ? 20.0 : (isTablet ? 22.0 : 24.0);

    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: fontSize,
        fontWeight: FontWeight.w700,
        color: textPrimary,
        letterSpacing: -0.5,
      ),
    );
  }

  Widget _buildQuickActions(bool isMobile, bool isTablet, bool isDesktop) {
    if (isDesktop) {
      return Center(
        child: Container(
          constraints: const BoxConstraints(maxWidth: 800),
          child: Row(
            children: [
              Expanded(
                child: _buildActionCard(
                  'Search Papers',
                  Icons.search_rounded,
                  primaryColor,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const SearchQuestionPaperPage(),
                      ),
                    );
                  },
                  isMobile,
                  isTablet,
                  isDesktop,
                ),
              ),
              const SizedBox(width: 24),
              Expanded(
                child: _buildActionCard(
                  'Browse Topics',
                  Icons.auto_stories_rounded,
                  accentPurple,
                  () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const TopicsSearchPage(),
                      ),
                    );
                  },
                  isMobile,
                  isTablet,
                  isDesktop,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            'Search Papers',
            Icons.search_rounded,
            primaryColor,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const SearchQuestionPaperPage(),
                ),
              );
            },
            isMobile,
            isTablet,
            isDesktop,
          ),
        ),
        SizedBox(width: isMobile ? 16 : 20),
        Expanded(
          child: _buildActionCard(
            'Browse Topics',
            Icons.auto_stories_rounded,
            accentPurple,
            () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const TopicsSearchPage(),
                ),
              );
            },
            isMobile,
            isTablet,
            isDesktop,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard(
    String title,
    IconData icon,
    Color color,
    VoidCallback onTap,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    final padding = isMobile ? 24.0 : (isTablet ? 28.0 : 32.0);
    final iconSize = isMobile ? 32.0 : (isTablet ? 36.0 : 40.0);
    final iconPadding = isMobile ? 14.0 : (isTablet ? 16.0 : 18.0);
    final titleSize = isMobile ? 15.0 : (isTablet ? 16.0 : 17.0);

    return AnimatedScaleButton(
      onPressed: onTap,
      child: Container(
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [color.withOpacity(0.08), color.withOpacity(0.04)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withOpacity(0.15), width: 1),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: iconSize),
            ),
            SizedBox(height: isMobile ? 16 : 20),
            Text(
              title,
              textAlign: TextAlign.center,
              style: GoogleFonts.inter(
                color: textPrimary,
                fontSize: titleSize,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsGrid(bool isMobile, bool isTablet, bool isDesktop) {
    final List<_StatCardData> stats = [
      _StatCardData(
        title: 'Colleges',
        icon: Icons.school_outlined,
        collection: 'colleges',
        color: primaryColor,
        delay: 0,
      ),
      _StatCardData(
        title: 'Exam Papers',
        icon: Icons.description_outlined,
        collection: 'question_papers',
        color: accentPurple,
        delay: 100,
      ),
      _StatCardData(
        title: 'Branches',
        icon: Icons.account_tree_outlined,
        collection: 'branches',
        color: accentBlue,
        delay: 200,
      ),
      _StatCardData(
        title: 'Active Users',
        icon: Icons.people_outline_rounded,
        collection: 'users',
        color: accentTeal,
        delay: 300,
      ),
    ];

    final crossAxisCount = isMobile ? 2 : (isTablet ? 2 : 4);
    final spacing = isMobile ? 16.0 : (isTablet ? 20.0 : 24.0);
    final aspectRatio = isMobile ? 1.4 : (isTablet ? 1.35 : 1.3);

    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        mainAxisSpacing: spacing,
        crossAxisSpacing: spacing,
        childAspectRatio: aspectRatio,
      ),
      itemCount: stats.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final stat = stats[index];
        return _StatCardFromFirestore(
          title: stat.title,
          icon: stat.icon,
          collection: stat.collection,
          color: stat.color,
          delay: stat.delay,
        );
      },
    );
  }

  Widget _buildRecentActivity(
    AsyncValue<List<Map<String, dynamic>>> recentActivity,
    AsyncValue<List<QuestionPaper>> recentQuestionPapers,
    bool isMobile,
    bool isTablet,
    bool isDesktop,
  ) {
    if (isDesktop) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                recentActivity.when(
                  data: (activities) {
                    if (activities.isEmpty) {
                      return _buildEmptyState(
                        'No recent activity',
                        Icons.timeline_rounded,
                        isMobile,
                      );
                    }
                    return Column(
                      children: activities.take(3).map((activity) {
                        return _buildActivityItem(
                          activity['title'] ?? 'Activity',
                          activity['description'] ?? 'No description',
                          _getActivityIcon(activity['type']),
                          _getActivityColor(activity['type']),
                          _formatTimestamp(activity['timestamp']),
                          isMobile,
                          isTablet,
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const ModernLoadingIndicator(
                    message: 'Loading activity...',
                    type: LoadingType.dots,
                  ),
                  error: (error, stackTrace) =>
                      _buildErrorState('Failed to load activity', isMobile),
                ),
              ],
            ),
          ),
          const SizedBox(width: 24),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                recentQuestionPapers.when(
                  data: (papers) {
                    if (papers.isEmpty) {
                      return _buildEmptyState(
                        'No recent papers',
                        Icons.description_outlined,
                        isMobile,
                      );
                    }
                    return Column(
                      children: papers.take(3).map((paper) {
                        return _buildActivityItem(
                          'New paper added',
                          '${paper.subject} - ${paper.college}',
                          Icons.library_add_check_outlined,
                          primaryColor,
                          _formatTimestamp(paper.uploadedAt),
                          isMobile,
                          isTablet,
                        );
                      }).toList(),
                    );
                  },
                  loading: () => const ModernLoadingIndicator(
                    message: 'Loading papers...',
                    type: LoadingType.dots,
                  ),
                  error: (error, stackTrace) =>
                      _buildErrorState('Failed to load papers', isMobile),
                ),
              ],
            ),
          ),
        ],
      );
    }

    return Column(
      children: [
        recentActivity.when(
          data: (activities) {
            if (activities.isEmpty) {
              return _buildEmptyState(
                'No recent activity',
                Icons.timeline_rounded,
                isMobile,
              );
            }
            return Column(
              children: activities.take(3).map((activity) {
                return _buildActivityItem(
                  activity['title'] ?? 'Activity',
                  activity['description'] ?? 'No description',
                  _getActivityIcon(activity['type']),
                  _getActivityColor(activity['type']),
                  _formatTimestamp(activity['timestamp']),
                  isMobile,
                  isTablet,
                );
              }).toList(),
            );
          },
          loading: () => const ModernLoadingIndicator(
            message: 'Loading activity...',
            type: LoadingType.dots,
          ),
          error: (error, stackTrace) =>
              _buildErrorState('Failed to load activity', isMobile),
        ),
        SizedBox(height: isMobile ? 16 : 20),
        recentQuestionPapers.when(
          data: (papers) {
            if (papers.isEmpty) {
              return _buildEmptyState(
                'No recent papers',
                Icons.description_outlined,
                isMobile,
              );
            }
            return Column(
              children: papers.take(2).map((paper) {
                return _buildActivityItem(
                  'New paper added',
                  '${paper.subject} - ${paper.college}',
                  Icons.library_add_check_outlined,
                  primaryColor,
                  _formatTimestamp(paper.uploadedAt),
                  isMobile,
                  isTablet,
                );
              }).toList(),
            );
          },
          loading: () => const ModernLoadingIndicator(
            message: 'Loading papers...',
            type: LoadingType.dots,
          ),
          error: (error, stackTrace) =>
              _buildErrorState('Failed to load papers', isMobile),
        ),
      ],
    );
  }

  Widget _buildActivityItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
    String time,
    bool isMobile,
    bool isTablet,
  ) {
    final padding = isMobile ? 18.0 : (isTablet ? 20.0 : 22.0);
    final iconSize = isMobile ? 22.0 : (isTablet ? 24.0 : 26.0);
    final iconPadding = isMobile ? 11.0 : (isTablet ? 12.0 : 13.0);
    final titleSize = isMobile ? 15.0 : (isTablet ? 16.0 : 16.0);
    final subtitleSize = isMobile ? 13.0 : (isTablet ? 14.0 : 14.0);
    final timeSize = isMobile ? 12.0 : (isTablet ? 13.0 : 13.0);

    return AnimatedScaleButton(
      onPressed: () {},
      child: Container(
        margin: EdgeInsets.only(bottom: isMobile ? 12 : 16),
        padding: EdgeInsets.all(padding),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 12,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(iconPadding),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [color.withOpacity(0.12), color.withOpacity(0.06)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: iconSize),
            ),
            SizedBox(width: isMobile ? 16 : 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: GoogleFonts.inter(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w600,
                      color: textPrimary,
                      letterSpacing: -0.2,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: GoogleFonts.inter(
                      fontSize: subtitleSize,
                      color: textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (!isMobile || time.length < 8)
              Text(
                time,
                style: GoogleFonts.inter(
                  fontSize: timeSize,
                  color: textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(String message, IconData icon, bool isMobile) {
    final padding = isMobile ? 32.0 : 40.0;
    final iconSize = isMobile ? 40.0 : 48.0;
    final fontSize = isMobile ? 14.0 : 15.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Center(
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                icon,
                size: iconSize,
                color: textSecondary.withOpacity(0.4),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: GoogleFonts.inter(
                color: textSecondary,
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message, bool isMobile) {
    final padding = isMobile ? 18.0 : 20.0;
    final fontSize = isMobile ? 14.0 : 15.0;

    return Container(
      padding: EdgeInsets.all(padding),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFFECACA), width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFDC2626).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.error_outline_rounded,
              color: Color(0xFFDC2626),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: GoogleFonts.inter(
                color: const Color(0xFFDC2626),
                fontSize: fontSize,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getActivityIcon(String? type) {
    switch (type) {
      case 'paper_added':
        return Icons.library_add_check_outlined;
      case 'user_login':
        return Icons.login_rounded;
      case 'user_signup':
        return Icons.person_add_alt_outlined;
      case 'paper_viewed':
        return Icons.visibility_outlined;
      default:
        return Icons.timeline_rounded;
    }
  }

  Color _getActivityColor(String? type) {
    switch (type) {
      case 'paper_added':
        return primaryColor;
      case 'user_login':
        return accentBlue;
      case 'user_signup':
        return accentPurple;
      case 'paper_viewed':
        return accentTeal;
      default:
        return textSecondary;
    }
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'Just now';

    DateTime dateTime;
    if (timestamp is Timestamp) {
      dateTime = timestamp.toDate();
    } else if (timestamp is String) {
      dateTime = DateTime.parse(timestamp);
    } else {
      return 'Just now';
    }

    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  Widget _buildFloatingActionButton() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = MediaQuery.of(context).size.width < 600;

        return FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => const QuestionPaperSubmissionPage(),
              ),
            );
          },
          backgroundColor: primaryColor,
          elevation: 4,
          icon: Icon(Icons.add_rounded, size: isMobile ? 22 : 24),
          label: Text(
            'Add Paper',
            style: GoogleFonts.inter(
              fontWeight: FontWeight.w600,
              fontSize: isMobile ? 15 : 16,
              letterSpacing: -0.2,
            ),
          ),
        );
      },
    );
  }

  void _showNotifications() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.3,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: const BoxDecoration(
              color: cardColor,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(24),
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: borderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Notifications',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.inter(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 24),
                _buildNotificationItem(
                  'New papers available',
                  '5 new papers in your subjects',
                  Icons.description_outlined,
                  primaryColor,
                ),
                _buildNotificationItem(
                  'System update',
                  'New features added',
                  Icons.update_outlined,
                  accentBlue,
                ),
                _buildNotificationItem(
                  'Maintenance scheduled',
                  'Brief downtime on Sunday',
                  Icons.construction_outlined,
                  accentPurple,
                ),
                _buildNotificationItem(
                  'Your paper was viewed',
                  'Someone viewed your uploaded paper',
                  Icons.visibility_outlined,
                  accentTeal,
                ),
                const SizedBox(height: 8),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildNotificationItem(
    String title,
    String subtitle,
    IconData icon,
    Color color,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: borderColor, width: 1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [color.withOpacity(0.12), color.withOpacity(0.06)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    color: textSecondary,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = ref.watch(themeModeProvider) == ThemeMode.dark;
        return Container(
          decoration: const BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: borderColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Settings',
                style: GoogleFonts.inter(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: textPrimary,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 24),
              _buildSettingItem('Profile', Icons.person_outline_rounded, () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ProfilePage()),
                );
              }),
              _buildSettingItem(
                'Dark Mode',
                Icons.dark_mode_outlined,
                () {},
                trailing: Switch(
                  value: isDark,
                  onChanged: (val) {
                    ref.read(themeModeProvider.notifier).state = val
                        ? ThemeMode.dark
                        : ThemeMode.light;
                  },
                  activeColor: primaryColor,
                ),
              ),
              _buildSettingItem('Language', Icons.language_outlined, () {}),
              _buildSettingItem(
                'Notifications',
                Icons.notifications_none_rounded,
                () {},
              ),
              _buildSettingItem('Privacy', Icons.privacy_tip_outlined, () {}),
              _buildSettingItem('About', Icons.info_outline_rounded, () {}),
              _buildSettingItem(
                'Help & Feedback',
                Icons.help_outline_rounded,
                () {},
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSettingItem(
    String title,
    IconData icon,
    VoidCallback onTap, {
    Widget? trailing,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor, width: 1),
        ),
        child: Row(
          children: [
            Icon(icon, color: textSecondary, size: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Text(
                title,
                style: GoogleFonts.inter(
                  fontSize: 15,
                  color: textPrimary,
                  fontWeight: FontWeight.w600,
                  letterSpacing: -0.2,
                ),
              ),
            ),
            if (trailing != null)
              trailing
            else
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: textSecondary,
              ),
          ],
        ),
      ),
    );
  }
}

class _StatCardData {
  final String title;
  final IconData icon;
  final String collection;
  final Color color;
  final int delay;
  _StatCardData({
    required this.title,
    required this.icon,
    required this.collection,
    required this.color,
    required this.delay,
  });
}

class _StatCardFromFirestore extends StatefulWidget {
  final String title;
  final IconData icon;
  final String collection;
  final Color color;
  final int delay;
  const _StatCardFromFirestore({
    required this.title,
    required this.icon,
    required this.collection,
    required this.color,
    required this.delay,
  });
  @override
  State<_StatCardFromFirestore> createState() => _StatCardFromFirestoreState();
}

class _StatCardFromFirestoreState extends State<_StatCardFromFirestore>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    Future.delayed(Duration(milliseconds: widget.delay), () {
      if (mounted) {
        _controller.forward();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: StreamBuilder<int>(
          stream: _fetchCount(widget.collection),
          builder: (context, snapshot) {
            final count = snapshot.data ?? 0;
            return LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 150;
                final padding = isMobile ? 16.0 : 20.0;
                final iconSize = isMobile ? 24.0 : 26.0;
                final iconPadding = isMobile ? 10.0 : 12.0;
                final numberSize = isMobile ? 24.0 : 28.0;
                final labelSize = isMobile ? 12.0 : 13.0;

                return Container(
                  padding: EdgeInsets.all(padding),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: const Color(0xFFE2E8F0),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.03),
                        blurRadius: 12,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.all(iconPadding),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              widget.color.withOpacity(0.12),
                              widget.color.withOpacity(0.06),
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          widget.icon,
                          color: widget.color,
                          size: iconSize,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (snapshot.connectionState ==
                              ConnectionState.waiting)
                            Container(
                              width: 50,
                              height: isMobile ? 24 : 28,
                              decoration: BoxDecoration(
                                color: const Color(0xFFE2E8F0),
                                borderRadius: BorderRadius.circular(8),
                              ),
                            )
                          else
                            Text(
                              count.toString(),
                              style: GoogleFonts.inter(
                                fontSize: numberSize,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF1E293B),
                                letterSpacing: -1,
                              ),
                            ),
                          const SizedBox(height: 4),
                          Text(
                            widget.title,
                            style: GoogleFonts.inter(
                              fontSize: labelSize,
                              color: const Color(0xFF64748B),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Stream<int> _fetchCount(String collection) {
    if (collection == 'question_papers') {
      return FirebaseService.instance.firestore
          .collection('submitted_papers')
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    }
    if (collection == "colleges") {
      return Stream.value(30);
    }
    if (collection == 'branches') {
      return Stream.value(20);
    }
    if (collection == 'users') {
      return FirebaseFirestore.instance
          .collection('users')
          .snapshots()
          .map((snapshot) => snapshot.docs.length);
    }

    return Stream.value(0);
  }
}
