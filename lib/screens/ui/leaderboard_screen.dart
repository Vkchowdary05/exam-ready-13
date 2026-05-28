// lib/screens/ui/leaderboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exam_ready/theme/app_theme.dart';
import 'package:exam_ready/utils/strings.dart';
import 'package:exam_ready/utils/constants.dart';

/// Leaderboard screen — ranks contributors by XP.
class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<_LeaderEntry> _entries = [];
  bool _isLoading = true;
  String _filter = 'allTime'; // 'thisWeek', 'allTime'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _filter = _tabController.index == 0 ? 'allTime' : 'thisWeek';
        });
        _loadLeaderboard();
      }
    });
    _loadLeaderboard();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadLeaderboard() async {
    setState(() => _isLoading = true);
    try {
      final query = FirebaseFirestore.instance
          .collection(AppConstants.usersCollection)
          .orderBy('contributorXP', descending: true)
          .limit(50);

      final snap = await query.get();
      final currentUid = FirebaseAuth.instance.currentUser?.uid;

      final entries = snap.docs.asMap().entries.map((e) {
        final data = e.value.data();
        return _LeaderEntry(
          rank: e.key + 1,
          uid: e.value.id,
          name: data['name'] as String? ??
              data['displayName'] as String? ??
              'Student',
          college: data['college'] as String? ?? '',
          branch: data['branch'] as String? ?? '',
          xp: data['contributorXP'] as int? ?? 0,
          papersUploaded: data['papersUploaded'] as int? ?? 0,
          photoUrl: data['photoUrl'] as String?,
          isCurrentUser: e.value.id == currentUid,
        );
      }).toList();

      setState(() {
        _entries = entries;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textOnDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.leaderboard,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textOnDark,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.lavender,
          indicatorWeight: 3,
          labelColor: AppTheme.lavender,
          unselectedLabelColor: AppTheme.textOnDarkMuted,
          labelStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          tabs: const [
            Tab(text: 'All Time'),
            Tab(text: 'This Week'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.lavender),
            )
          : _entries.isEmpty
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.emoji_events_outlined,
                        size: 64,
                        color: AppTheme.darkBorder,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No contributors yet',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: AppTheme.textOnDarkMuted,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadLeaderboard,
                  color: AppTheme.lavender,
                  child: ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: _entries.length,
                    itemBuilder: (context, index) {
                      final entry = _entries[index];
                      return _buildLeaderRow(entry)
                          .animate(delay: Duration(milliseconds: 40 * index))
                          .fadeIn(duration: 300.ms)
                          .slideX(begin: 0.03, end: 0, duration: 300.ms);
                    },
                  ),
                ),
    );
  }

  Widget _buildLeaderRow(_LeaderEntry entry) {
    final isTop3 = entry.rank <= 3;
    final medalEmoji = switch (entry.rank) {
      1 => '🥇',
      2 => '🥈',
      3 => '🥉',
      _ => null,
    };

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: entry.isCurrentUser
            ? AppTheme.lavender.withAlpha(15)
            : AppTheme.darkSurface,
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        border: Border.all(
          color: entry.isCurrentUser
              ? AppTheme.lavender.withAlpha(60)
              : isTop3
                  ? AppTheme.lavender.withAlpha(30)
                  : AppTheme.darkBorder,
        ),
      ),
      child: Row(
        children: [
          // Rank
          SizedBox(
            width: 40,
            child: medalEmoji != null
                ? Text(medalEmoji, style: const TextStyle(fontSize: 24))
                : Text(
                    '#${entry.rank}',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textOnDarkMuted,
                    ),
                  ),
          ),
          const SizedBox(width: 12),

          // Avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.lavender.withAlpha(30),
            backgroundImage:
                entry.photoUrl != null ? NetworkImage(entry.photoUrl!) : null,
            child: entry.photoUrl == null
                ? Text(
                    entry.name.isNotEmpty ? entry.name[0].toUpperCase() : '?',
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.lavender,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 12),

          // Name + college
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        entry.name,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textOnDark,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (entry.isCurrentUser) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.lavender.withAlpha(30),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'You',
                          style: GoogleFonts.inter(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.lavender,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                if (entry.college.isNotEmpty)
                  Text(
                    entry.college,
                    style: GoogleFonts.inter(
                      fontSize: 11,
                      color: AppTheme.textOnDarkMuted,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),

          // XP + uploads
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${entry.xp} XP',
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.lavender,
                ),
              ),
              Text(
                '${entry.papersUploaded} papers',
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.textOnDarkMuted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _LeaderEntry {
  final int rank;
  final String uid;
  final String name;
  final String college;
  final String branch;
  final int xp;
  final int papersUploaded;
  final String? photoUrl;
  final bool isCurrentUser;

  const _LeaderEntry({
    required this.rank,
    required this.uid,
    required this.name,
    required this.college,
    required this.branch,
    required this.xp,
    required this.papersUploaded,
    this.photoUrl,
    this.isCurrentUser = false,
  });
}
