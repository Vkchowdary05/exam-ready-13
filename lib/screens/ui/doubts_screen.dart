// lib/screens/ui/doubts_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:exam_ready/models/doubt_model.dart';
import 'package:exam_ready/theme/app_theme.dart';
import 'package:exam_ready/utils/strings.dart';
import 'package:exam_ready/utils/constants.dart';
import 'package:exam_ready/utils/sanitizer.dart';
import 'package:exam_ready/utils/api_error_handler.dart';

/// Doubts screen — peer Q&A feed.
class DoubtsScreen extends StatefulWidget {
  const DoubtsScreen({super.key});

  @override
  State<DoubtsScreen> createState() => _DoubtsScreenState();
}

class _DoubtsScreenState extends State<DoubtsScreen> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.cream,
      appBar: AppBar(
        backgroundColor: AppTheme.cream,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.textOnLight),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          AppStrings.doubts,
          style: GoogleFonts.spaceGrotesk(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: AppTheme.textOnLight,
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showPostDoubtSheet(context),
        backgroundColor: AppTheme.lavender,
        foregroundColor: AppTheme.darkBg,
        icon: const Icon(Icons.add_rounded),
        label: Text(
          AppStrings.postDoubt,
          style: GoogleFonts.inter(fontWeight: FontWeight.w600),
        ),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection(AppConstants.doubtsCollection)
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.lavender),
            );
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.question_answer_outlined,
                    size: 64,
                    color: AppTheme.creamBorder,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppStrings.emptyDoubts,
                    style: GoogleFonts.inter(
                      fontSize: 16,
                      color: AppTheme.textOnLightMuted,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Be the first to ask a question!',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      color: AppTheme.textOnLightMuted.withAlpha(150),
                    ),
                  ),
                ],
              ),
            );
          }

          final doubts = snapshot.data!.docs
              .map((doc) => Doubt.fromFirestore(doc))
              .toList();

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
            itemCount: doubts.length,
            itemBuilder: (context, index) {
              final doubt = doubts[index];
              return _buildDoubtCard(doubt)
                  .animate(delay: Duration(milliseconds: 40 * index))
                  .fadeIn(duration: 300.ms);
            },
          );
        },
      ),
    );
  }

  Widget _buildDoubtCard(Doubt doubt) {
    final isOwner = doubt.userId == _auth.currentUser?.uid;
    final timeAgo = _timeAgo(doubt.createdAt);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.lightCard(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: author + time
          Row(
            children: [
              CircleAvatar(
                radius: 16,
                backgroundColor: AppTheme.lavender.withAlpha(30),
                child: Text(
                  doubt.displayName.isNotEmpty
                      ? doubt.displayName[0].toUpperCase()
                      : '?',
                  style: GoogleFonts.spaceGrotesk(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.lavender,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doubt.displayName,
                      style: GoogleFonts.inter(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textOnLight,
                      ),
                    ),
                    Text(
                      timeAgo,
                      style: GoogleFonts.inter(
                        fontSize: 11,
                        color: AppTheme.textOnLightMuted,
                      ),
                    ),
                  ],
                ),
              ),
              // Subject chip
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: AppTheme.chip(),
                child: Text(
                  doubt.subject,
                  style: GoogleFonts.inter(
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                    color: AppTheme.lavenderMuted,
                  ),
                ),
              ),
              if (doubt.isResolved) ...[
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.success.withAlpha(20),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppTheme.success.withAlpha(60)),
                  ),
                  child: Text(
                    '✓ Resolved',
                    style: GoogleFonts.inter(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.success,
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: 12),

          // Doubt text
          Text(
            doubt.text,
            style: GoogleFonts.inter(
              fontSize: 14,
              color: AppTheme.textOnLight,
              height: 1.5,
            ),
          ),

          // Topic chip
          if (doubt.topic != null) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: AppTheme.teal.withAlpha(15),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                doubt.topic!,
                style: GoogleFonts.inter(
                  fontSize: 11,
                  color: AppTheme.teal,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],

          const SizedBox(height: 12),
          const Divider(color: AppTheme.creamBorder, height: 1),
          const SizedBox(height: 8),

          // Actions: upvote, answers, resolve
          Row(
            children: [
              // Upvote
              InkWell(
                onTap: () => _upvoteDoubt(doubt.id),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Row(
                    children: [
                      Icon(
                        Icons.arrow_upward_rounded,
                        size: 16,
                        color: AppTheme.textOnLightMuted,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${doubt.upvotes}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textOnLightMuted,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 16),

              // Answer count
              Icon(
                Icons.chat_bubble_outline_rounded,
                size: 14,
                color: AppTheme.textOnLightMuted,
              ),
              const SizedBox(width: 4),
              Text(
                '${doubt.answerCount} answers',
                style: GoogleFonts.inter(
                  fontSize: 12,
                  color: AppTheme.textOnLightMuted,
                ),
              ),

              const Spacer(),

              // Mark resolved (owner only)
              if (isOwner && !doubt.isResolved)
                TextButton(
                  onPressed: () => _resolveDoubt(doubt.id),
                  child: Text(
                    AppStrings.markResolved,
                    style: GoogleFonts.inter(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.teal,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Post Doubt Bottom Sheet ───────────────────────────────────

  void _showPostDoubtSheet(BuildContext context) {
    final textController = TextEditingController();
    final subjectController = TextEditingController();
    bool isAnonymous = false;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppTheme.creamSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                24,
                24,
                MediaQuery.of(context).viewInsets.bottom + 24,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    AppStrings.postDoubt,
                    style: GoogleFonts.spaceGrotesk(
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textOnLight,
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: subjectController,
                    decoration: AppTheme.inputDecoration(
                      hint: 'Subject',
                      icon: Icons.book_outlined,
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: textController,
                    maxLines: 4,
                    decoration: AppTheme.inputDecoration(
                      hint: 'What\'s your doubt?',
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Switch(
                        value: isAnonymous,
                        onChanged: (v) => setSheetState(() => isAnonymous = v),
                        activeColor: AppTheme.lavender,
                      ),
                      Text(
                        AppStrings.postAnonymously,
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textOnLightMuted,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: AppConstants.minButtonHeight,
                    child: ElevatedButton(
                      onPressed: () => _submitDoubt(
                        textController.text,
                        subjectController.text,
                        isAnonymous,
                        context,
                      ),
                      child: Text(
                        'Post Doubt',
                        style: GoogleFonts.inter(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  // ─── Actions ───────────────────────────────────────────────────

  Future<void> _submitDoubt(
    String text,
    String subject,
    bool isAnonymous,
    BuildContext sheetContext,
  ) async {
    if (text.trim().isEmpty || subject.trim().isEmpty) return;

    try {
      final user = _auth.currentUser;
      if (user == null) return;

      await _firestore.collection(AppConstants.doubtsCollection).add({
        'userId': user.uid,
        'userName': user.displayName ?? user.email ?? 'Student',
        'text': InputSanitizer.sanitizeUserInput(text),
        'subject': InputSanitizer.sanitizeMetadataField(subject),
        'isAnonymous': isAnonymous,
        'isResolved': false,
        'upvotes': 0,
        'answerCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
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

  Future<void> _upvoteDoubt(String doubtId) async {
    try {
      await _firestore
          .collection(AppConstants.doubtsCollection)
          .doc(doubtId)
          .update({'upvotes': FieldValue.increment(1)});
    } catch (_) {}
  }

  Future<void> _resolveDoubt(String doubtId) async {
    try {
      await _firestore
          .collection(AppConstants.doubtsCollection)
          .doc(doubtId)
          .update({'isResolved': true});
    } catch (_) {}
  }

  String _timeAgo(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }
}
