// lib/screens/ui/topic_analysis_screen.dart
//
// THE KILLER FEATURE — Topic frequency analysis with heatmap.
// Shows which topics repeat most, which are "hot", which are "due".

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_ready/theme/app_theme.dart';
import 'package:exam_ready/utils/strings.dart';
import 'package:exam_ready/utils/constants.dart';

/// Topic Analysis — heatmap + ranked list of topics by frequency.
class TopicAnalysisScreen extends ConsumerStatefulWidget {
  final String subject;
  final String? branch;
  final String? semester;

  const TopicAnalysisScreen({
    super.key,
    required this.subject,
    this.branch,
    this.semester,
  });

  @override
  ConsumerState<TopicAnalysisScreen> createState() =>
      _TopicAnalysisScreenState();
}

class _TopicAnalysisScreenState extends ConsumerState<TopicAnalysisScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<_TopicData> _topics = [];
  bool _isLoading = true;
  String _filterBadge = 'All'; // All, Hot, Due

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadTopics();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadTopics() async {
    setState(() => _isLoading = true);
    try {
      // Query the questions collection for this subject
      final querySnap = await FirebaseFirestore.instance
          .collection(AppConstants.questionsCollection)
          .get();

      final Map<String, int> topicFreq = {};
      final Map<String, List<String>> topicYears = {};

      for (final doc in querySnap.docs) {
        final data = doc.data();
        // Each doc in "questions" has topic names as keys with count values
        data.forEach((key, value) {
          if (key == 'createdAt' || key == 'lastModified' || key == 'updatedAt') return;
          if (value is int && value > 0) {
            final topic = key.toUpperCase();
            topicFreq[topic] = (topicFreq[topic] ?? 0) + value;
          }
        });
      }

      // Build topic data
      final currentYear = DateTime.now().year;
      final topics = topicFreq.entries.map((e) {
        final years = topicYears[e.key] ?? [];
        final lastSeen = years.isNotEmpty
            ? years.map((y) => int.tryParse(y) ?? 0).reduce((a, b) => a > b ? a : b)
            : currentYear;

        return _TopicData(
          name: e.key,
          count: e.value,
          isHot: e.value >= AppConstants.hotTopicThreshold,
          isDue: (currentYear - lastSeen) >= AppConstants.dueTopicYearsGap,
          lastSeenYear: lastSeen,
        );
      }).toList();

      // Sort by frequency (descending)
      topics.sort((a, b) => b.count.compareTo(a.count));

      setState(() {
        _topics = topics;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  List<_TopicData> get _filteredTopics {
    switch (_filterBadge) {
      case 'Hot':
        return _topics.where((t) => t.isHot).toList();
      case 'Due':
        return _topics.where((t) => t.isDue).toList();
      default:
        return _topics;
    }
  }

  int get _maxCount =>
      _topics.isNotEmpty ? _topics.first.count : 1;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: CustomScrollView(
        slivers: [
          // ── App Bar ────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 140,
            pinned: true,
            backgroundColor: AppTheme.darkBg,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textOnDark),
              onPressed: () => Navigator.pop(context),
            ),
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
              title: Text(
                AppStrings.topicAnalysis,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textOnDark,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.backgroundGradient,
                ),
              ),
            ),
          ),

          // ── Subject Header ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.subject,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lavender,
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  if (widget.branch != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      '${widget.branch} • ${widget.semester ?? ''}',
                      style: GoogleFonts.inter(
                        fontSize: 14,
                        color: AppTheme.textOnDarkMuted,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // ── Stats Summary ──────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Row(
                children: [
                  _buildStatCard(
                    label: 'Total Topics',
                    value: '${_topics.length}',
                    color: AppTheme.lavender,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    label: 'Hot Topics',
                    value: '${_topics.where((t) => t.isHot).length}',
                    color: AppTheme.coral,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    label: 'Due Topics',
                    value: '${_topics.where((t) => t.isDue).length}',
                    color: AppTheme.amber,
                  ),
                ],
              ).animate().fadeIn(duration: 400.ms, delay: 200.ms),
            ),
          ),

          // ── Filter Chips ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              child: Row(
                children: ['All', 'Hot', 'Due'].map((badge) {
                  final isActive = _filterBadge == badge;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: GestureDetector(
                      onTap: () => setState(() => _filterBadge = badge),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppTheme.lavender.withAlpha(30)
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isActive
                                ? AppTheme.lavender
                                : AppTheme.darkBorder,
                          ),
                        ),
                        child: Text(
                          badge == 'Hot'
                              ? '🔥 Hot'
                              : badge == 'Due'
                                  ? '⚡ Due'
                                  : 'All',
                          style: GoogleFonts.inter(
                            fontSize: 13,
                            fontWeight:
                                isActive ? FontWeight.w600 : FontWeight.w400,
                            color: isActive
                                ? AppTheme.lavender
                                : AppTheme.textOnDarkMuted,
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Topic Heatmap Grid ─────────────────────────────────
          if (!_isLoading && _filteredTopics.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Frequency Heatmap',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textOnDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: _filteredTopics.take(30).map((topic) {
                        return _buildHeatmapChip(topic);
                      }).toList(),
                    ),
                  ],
                ).animate().fadeIn(duration: 400.ms, delay: 300.ms),
              ),
            ),

          // ── Section: Most Important ────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                AppStrings.topImportantTopics,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textOnDark,
                ),
              ),
            ),
          ),

          // ── Topic List ─────────────────────────────────────────
          if (_isLoading)
            const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(
                  color: AppTheme.lavender,
                ),
              ),
            )
          else if (_filteredTopics.isEmpty)
            SliverFillRemaining(
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.analytics_outlined,
                      size: 64,
                      color: AppTheme.darkBorder,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No topic data available yet',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        color: AppTheme.textOnDarkMuted,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Upload papers to generate topic analysis',
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        color: AppTheme.textOnDarkMuted.withAlpha(150),
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final topic = _filteredTopics[index];
                  return _buildTopicRow(topic, index + 1)
                      .animate(delay: Duration(milliseconds: 50 * index))
                      .fadeIn(duration: 300.ms)
                      .slideX(begin: 0.05, end: 0, duration: 300.ms);
                },
                childCount: _filteredTopics.length,
              ),
            ),

          // Bottom padding
          const SliverToBoxAdapter(child: SizedBox(height: 32)),
        ],
      ),
    );
  }

  // ─── Stat Card ─────────────────────────────────────────────────

  Widget _buildStatCard({
    required String label,
    required String value,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(15),
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          border: Border.all(color: color.withAlpha(40)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: GoogleFonts.spaceGrotesk(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppTheme.textOnDarkMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Heatmap Chip ──────────────────────────────────────────────

  Widget _buildHeatmapChip(_TopicData topic) {
    // Color intensity based on frequency
    final intensity = _maxCount > 0 ? topic.count / _maxCount : 0.0;
    final bgColor = Color.lerp(
      AppTheme.darkSurface,
      AppTheme.lavender,
      intensity * 0.7,
    )!;
    final textColor = intensity > 0.4
        ? AppTheme.darkBg
        : AppTheme.textOnDark;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: AppTheme.lavender.withAlpha((intensity * 100).toInt() + 30),
          width: 1,
        ),
      ),
      child: Text(
        '${topic.name} (${topic.count})',
        style: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textColor,
        ),
      ),
    );
  }

  // ─── Topic Row ─────────────────────────────────────────────────

  Widget _buildTopicRow(_TopicData topic, int rank) {
    final barWidth = _maxCount > 0 ? topic.count / _maxCount : 0.0;

    // Priority badge
    Color badgeColor;
    String priorityLabel;
    if (topic.isHot && topic.isDue) {
      badgeColor = AppTheme.coral;
      priorityLabel = AppStrings.mustStudy;
    } else if (topic.isHot) {
      badgeColor = AppTheme.amber;
      priorityLabel = AppStrings.shouldStudy;
    } else {
      badgeColor = AppTheme.teal;
      priorityLabel = AppStrings.canSkip;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.darkCard(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                // Rank number
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: rank <= 3
                        ? AppTheme.lavender.withAlpha(30)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8),
                    border: rank <= 3
                        ? Border.all(color: AppTheme.lavender.withAlpha(60))
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '#$rank',
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: rank <= 3
                            ? AppTheme.lavender
                            : AppTheme.textOnDarkMuted,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),

                // Topic name
                Expanded(
                  child: Text(
                    topic.name,
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textOnDark,
                    ),
                  ),
                ),

                // Badges
                if (topic.isHot)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      gradient: AppTheme.hotBadgeGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '🔥',
                      style: GoogleFonts.inter(fontSize: 10),
                    ),
                  ),
                if (topic.isDue)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      gradient: AppTheme.dueBadgeGradient,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '⚡',
                      style: GoogleFonts.inter(fontSize: 10),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // Frequency bar
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: barWidth,
                      minHeight: 6,
                      backgroundColor: AppTheme.darkBorder,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color.lerp(AppTheme.teal, AppTheme.lavender, barWidth)!,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  '${topic.count}×',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lavender,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Priority label
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  '$priorityLabel Priority',
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.textOnDarkMuted,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Internal Data Class ─────────────────────────────────────────

class _TopicData {
  final String name;
  final int count;
  final bool isHot;
  final bool isDue;
  final int lastSeenYear;

  const _TopicData({
    required this.name,
    required this.count,
    this.isHot = false,
    this.isDue = false,
    this.lastSeenYear = 0,
  });
}
