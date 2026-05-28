// lib/screens/ui/study_groups_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exam_ready/models/study_group_model.dart';
import 'package:exam_ready/theme/app_theme.dart';
import 'package:exam_ready/utils/strings.dart';
import 'package:exam_ready/utils/constants.dart';
import 'package:exam_ready/utils/sanitizer.dart';
import 'package:exam_ready/utils/api_error_handler.dart';

/// Study Groups screen — create/join groups with topic checklists.
class StudyGroupsScreen extends StatefulWidget {
  const StudyGroupsScreen({super.key});

  @override
  State<StudyGroupsScreen> createState() => _StudyGroupsScreenState();
}

class _StudyGroupsScreenState extends State<StudyGroupsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  String get _currentUserId => _auth.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: AppTheme.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded,
              color: AppTheme.textOnLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.studyGroups,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textOnLight,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppTheme.lavender,
          indicatorWeight: 3,
          labelColor: AppTheme.lavender,
          unselectedLabelColor: AppTheme.textOnLightMuted,
          labelStyle:
              GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w600),
          tabs: const [
            Tab(text: 'My Groups'),
            Tab(text: 'Discover'),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showCreateGroupSheet(context),
        backgroundColor: AppTheme.lavender,
        foregroundColor: AppTheme.darkBg,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          AppStrings.createGroup,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildMyGroups(),
          _buildDiscoverGroups(),
        ],
      ),
    );
  }

  // ─── My Groups ─────────────────────────────────────────────────

  Widget _buildMyGroups() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection(AppConstants.studyGroupsCollection)
          .where('memberIds', arrayContains: _currentUserId)
          .orderBy('lastActive', descending: true)
          .limit(20)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.lavender),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.groups_outlined,
            text: AppStrings.emptyGroups,
            subtitle: 'Create or join a study group to get started',
          );
        }

        final groups = snapshot.data!.docs
            .map((doc) => StudyGroup.fromFirestore(doc))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            return _buildGroupCard(groups[index], isMember: true)
                .animate(delay: Duration(milliseconds: 40 * index))
                .fadeIn(duration: 300.ms);
          },
        );
      },
    );
  }

  // ─── Discover Groups ───────────────────────────────────────────

  Widget _buildDiscoverGroups() {
    return StreamBuilder<QuerySnapshot>(
      stream: _firestore
          .collection(AppConstants.studyGroupsCollection)
          .orderBy('memberCount', descending: true)
          .limit(30)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppTheme.lavender),
          );
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _buildEmptyState(
            icon: Icons.search_off_rounded,
            text: 'No groups available',
            subtitle: 'Be the first to create one!',
          );
        }

        final groups = snapshot.data!.docs
            .map((doc) => StudyGroup.fromFirestore(doc))
            .where((g) => !g.memberIds.contains(_currentUserId))
            .toList();

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
          itemCount: groups.length,
          itemBuilder: (context, index) {
            return _buildGroupCard(groups[index], isMember: false)
                .animate(delay: Duration(milliseconds: 40 * index))
                .fadeIn(duration: 300.ms);
          },
        );
      },
    );
  }

  // ─── Group Card ────────────────────────────────────────────────

  Widget _buildGroupCard(StudyGroup group, {required bool isMember}) {
    final completionPct = (group.completionPercent * 100).toInt();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.lightCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Icon
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppTheme.lavender.withAlpha(20),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.groups_rounded,
                  color: AppTheme.lavender,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.name,
                      style: GoogleFonts.spaceGrotesk(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textOnLight,
                      ),
                    ),
                    Text(
                      '${group.subject} • ${group.memberCount} members',
                      style: GoogleFonts.inter(
                        fontSize: 12,
                        color: AppTheme.textOnLightMuted,
                      ),
                    ),
                  ],
                ),
              ),
              if (!isMember)
                ElevatedButton(
                  onPressed: () => _joinGroup(group.id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.lavender,
                    foregroundColor: AppTheme.darkBg,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    minimumSize: Size.zero,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: Text(
                    'Join',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
            ],
          ),

          // Progress bar (for member groups)
          if (isMember && group.topicChecklist.isNotEmpty) ...[
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(3),
                    child: LinearProgressIndicator(
                      value: group.completionPercent,
                      minHeight: 5,
                      backgroundColor: AppTheme.creamBorder,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppTheme.teal),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Text(
                  '$completionPct%',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.teal,
                  ),
                ),
              ],
            ),
          ],

          if (group.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              group.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: GoogleFonts.inter(
                fontSize: 13,
                color: AppTheme.textOnLightMuted,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ─── Empty State ───────────────────────────────────────────────

  Widget _buildEmptyState({
    required IconData icon,
    required String text,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 64, color: AppTheme.creamBorder),
          const SizedBox(height: 16),
          Text(
            text,
            style: GoogleFonts.inter(
              fontSize: 16,
              color: AppTheme.textOnLightMuted,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: GoogleFonts.inter(
              fontSize: 13,
              color: AppTheme.textOnLightMuted.withAlpha(150),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Create Group Sheet ────────────────────────────────────────

  void _showCreateGroupSheet(BuildContext context) {
    final nameController = TextEditingController();
    final descController = TextEditingController();
    final subjectController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.creamSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetCtx) {
        return Padding(
          padding: EdgeInsets.fromLTRB(
            24,
            24,
            24,
            MediaQuery.of(sheetCtx).viewInsets.bottom + 24,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.createGroup,
                style: GoogleFonts.spaceGrotesk(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textOnLight,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: nameController,
                decoration: AppTheme.inputDecoration(
                  hint: 'Group Name',
                  icon: Icons.group_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: subjectController,
                decoration: AppTheme.inputDecoration(
                  hint: 'Subject',
                  icon: Icons.book_outlined,
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 2,
                decoration: AppTheme.inputDecoration(
                  hint: 'Description (optional)',
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: AppConstants.minButtonHeight,
                child: ElevatedButton(
                  onPressed: () => _createGroup(
                    nameController.text,
                    subjectController.text,
                    descController.text,
                    sheetCtx,
                  ),
                  child: Text(
                    'Create Group',
                    style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ─── Actions ───────────────────────────────────────────────────

  Future<void> _createGroup(
    String name,
    String subject,
    String description,
    BuildContext sheetContext,
  ) async {
    if (name.trim().isEmpty || subject.trim().isEmpty) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection(AppConstants.studyGroupsCollection).add({
        'name': InputSanitizer.sanitizeUserInput(name, maxLength: 100),
        'subject': InputSanitizer.sanitizeMetadataField(subject),
        'description': InputSanitizer.sanitizeUserInput(description),
        'createdBy': user.uid,
        'creatorName': user.displayName ?? user.email ?? 'Student',
        'memberIds': [user.uid],
        'memberCount': 1,
        'topicChecklist': [],
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      });

      if (sheetContext.mounted) Navigator.pop(sheetContext);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiErrorHandler.getReadableError(e))),
        );
      }
    }
  }

  Future<void> _joinGroup(String groupId) async {
    try {
      await _firestore
          .collection(AppConstants.studyGroupsCollection)
          .doc(groupId)
          .update({
        'memberIds': FieldValue.arrayUnion([_currentUserId]),
        'memberCount': FieldValue.increment(1),
        'lastActive': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(ApiErrorHandler.getReadableError(e))),
        );
      }
    }
  }
}
