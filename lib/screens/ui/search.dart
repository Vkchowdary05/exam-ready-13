// lib/pages/search_question_paper_page.dart

import 'dart:async';
import 'dart:ui';
import 'package:exam_ready/data/dropdown_data.dart';
import 'package:exam_ready/models/question_paper_model.dart';
import 'package:exam_ready/repositories/search_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';
import 'package:exam_ready/riverpod/question_paper_provider.dart';

final searchRepositoryProvider = Provider((ref) => SearchRepository());

final searchResultsProvider =
    StreamProvider.family<List<QuestionPaper>, Map<String, String?>>(
  (ref, filters) {
    final searchRepository = ref.watch(searchRepositoryProvider);
    return searchRepository.searchExamPapers(
      college: filters['college'],
      branch: filters['branch'],
      semester: filters['semester'],
      subject: filters['subject'],
      examType: filters['examType'],
    );
  },
);

// ============================================================================
// PAPER DETAILS PAGE (ENHANCED & RESPONSIVE)
// ============================================================================

class PaperDetailsPage extends ConsumerStatefulWidget {
  final String paperId;

  const PaperDetailsPage({super.key, required this.paperId});

  @override
  ConsumerState<PaperDetailsPage> createState() => _PaperDetailsPageState();
}

class _PaperDetailsPageState extends ConsumerState<PaperDetailsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _isDeleting = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    _animationController.forward();
  }

  Widget _buildLoadingState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.white,
            Colors.blue.shade50.withOpacity(0.3),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildModernBackButton(),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.shade100.withOpacity(0.5),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: CircularProgressIndicator(
                        color: Colors.blue.shade600,
                        strokeWidth: 3,
                      ),
                    ),
                    const SizedBox(height: 32),
                    Text(
                      'Loading paper details...',
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundState() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.white,
            Colors.orange.shade50.withOpacity(0.3),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildModernBackButton(),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.orange.shade50,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.search_off_rounded,
                        size: 64,
                        color: Colors.orange.shade300,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Paper Not Found',
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'This paper may have been deleted',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 15,
                        letterSpacing: 0.2,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.white,
            Colors.red.shade50.withOpacity(0.3),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: _buildModernBackButton(),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Colors.red.shade300,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Something Went Wrong',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error,
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 15,
                          letterSpacing: 0.2,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildModernBackButton() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => Navigator.pop(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Icon(
              Icons.arrow_back_rounded,
              color: Colors.grey.shade700,
              size: 22,
            ),
          ),
        ),
      ),
    );
  }

  bool _checkDeletePermission(QuestionPaper paper) {
    // Hook for permission logic; currently always true
    return true;
  }

  void _showFullScreenImage(String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          body: Stack(
            children: [
              PhotoView(
                imageProvider: NetworkImage(imageUrl),
                minScale: PhotoViewComputedScale.contained,
                maxScale: PhotoViewComputedScale.covered * 3,
                backgroundDecoration: const BoxDecoration(color: Colors.black),
                loadingBuilder: (context, event) => Center(
                  child: CircularProgressIndicator(
                    value: event == null
                        ? null
                        : event.cumulativeBytesLoaded /
                            (event.expectedTotalBytes ?? 1),
                    color: Colors.blue.shade400,
                  ),
                ),
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _downloadPaper(QuestionPaper paper) {
    _showSnackBar('Download feature coming soon!', isSuccess: true);
  }

  void _confirmDelete(QuestionPaper paper) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.orange.shade700,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            const Text(
              'Confirm Delete',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                letterSpacing: -0.3,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this question paper? This action cannot be undone.',
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey.shade600,
            height: 1.5,
            letterSpacing: 0.2,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() => _isDeleting = true);
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.pop(context);
                  _showSnackBar('Paper deleted successfully', isSuccess: true);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  void _showShareDialog(QuestionPaper paper) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.4,
        minChildSize: 0.2,
        maxChildSize: 0.6,
        expand: false,
        builder: (context, scrollController) {
          return Container(
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
            ),
            child: ListView(
              controller: scrollController,
              padding: const EdgeInsets.symmetric(vertical: 12),
              children: [
                Align(
                  alignment: Alignment.center,
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Share Paper',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 8),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Text(
                    paper.subject,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                      letterSpacing: 0.2,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 32),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    spacing: 24,
                    runSpacing: 24,
                    children: [
                      _buildShareOption(
                        icon: Icons.link_rounded,
                        label: 'Copy Link',
                        onTap: () {
                          Navigator.pop(context);
                          _showSnackBar('Link copied!', isSuccess: true);
                        },
                      ),
                      _buildShareOption(
                        icon: Icons.message_rounded,
                        label: 'Message',
                        onTap: () {
                          Navigator.pop(context);
                          _showSnackBar('Share via message', isSuccess: true);
                        },
                      ),
                      _buildShareOption(
                        icon: Icons.more_horiz_rounded,
                        label: 'More',
                        onTap: () {
                          Navigator.pop(context);
                          _showSnackBar('More options', isSuccess: true);
                        },
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildShareOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.blue.shade400, Colors.blue.shade600],
              ),
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue.shade200.withOpacity(0.4),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
          const SizedBox(height: 10),
          Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError
                  ? Icons.error_outline_rounded
                  : isSuccess
                      ? Icons.check_circle_outline_rounded
                      : Icons.info_outline_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? Colors.red.shade600
            : isSuccess
                ? Colors.green.shade600
                : Colors.blue.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
        elevation: 0,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final paperAsync = ref.watch(paperDetailsProvider(widget.paperId));

    return Scaffold(
      body: paperAsync.when(
        data: (paper) {
          if (paper == null) {
            return _buildNotFoundState();
          }
          return _buildPaperDetails(paper);
        },
        loading: () => _buildLoadingState(),
        error: (error, _) => _buildErrorState(error.toString()),
      ),
    );
  }

  Widget _buildPaperDetails(QuestionPaper paper) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.grey.shade50,
            Colors.white,
            Colors.blue.shade50.withOpacity(0.2),
          ],
        ),
      ),
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final double width = constraints.maxWidth;
            final bool isWide = width >= 900;
            final double maxContentWidth = isWide ? 900 : width;

            return Align(
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxContentWidth),
                child: CustomScrollView(
                  physics: const BouncingScrollPhysics(),
                  slivers: [
                    _buildAppBar(paper),
                    SliverToBoxAdapter(
                      child: Column(
                        children: [
                          const SizedBox(height: 8),
                          _buildImageSection(paper, isWide: isWide),
                          _buildInfoSection(paper),
                          _buildActionButtons(paper),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildAppBar(QuestionPaper paper) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: Colors.white.withOpacity(0.95),
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: _buildModernBackButton(),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _showShareDialog(paper),
                borderRadius: BorderRadius.circular(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Icon(
                    Icons.share_rounded,
                    color: Colors.grey.shade700,
                    size: 22,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(QuestionPaper paper, {required bool isWide}) {
    final double horizontalMargin = isWide ? 32 : 20;

    return Hero(
      tag: 'paper_${paper.id}',
      child: GestureDetector(
        onTap: () => _showFullScreenImage(paper.imageUrl),
        child: Container(
          margin: EdgeInsets.symmetric(horizontal: horizontalMargin),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: AspectRatio(
              aspectRatio: isWide ? 16 / 9 : 3 / 4,
              child: Stack(
                children: [
                  Image.network(
                    paper.imageUrl,
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Shimmer.fromColors(
                        baseColor: Colors.grey.shade200,
                        highlightColor: Colors.grey.shade50,
                        child: Container(color: Colors.white),
                      );
                    },
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey.shade100,
                        child: Center(
                          child: Icon(
                            Icons.broken_image_rounded,
                            color: Colors.grey.shade400,
                            size: 64,
                          ),
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 12,
                    right: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.6),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: const [
                          Icon(
                            Icons.zoom_in_rounded,
                            color: Colors.white,
                            size: 16,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Tap to zoom',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoSection(QuestionPaper paper) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paper Details',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade800,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 20),
          _buildDetailRow(
            icon: Icons.menu_book_rounded,
            label: 'Subject',
            value: paper.subject,
          ),
          _buildDetailRow(
            icon: Icons.assignment_rounded,
            label: 'Exam Type',
            value: paper.examType,
          ),
          _buildDetailRow(
            icon: Icons.school_rounded,
            label: 'College',
            value: paper.college,
          ),
          _buildDetailRow(
            icon: Icons.account_tree_rounded,
            label: 'Branch',
            value: paper.branch,
          ),
          _buildDetailRow(
            icon: Icons.calendar_month_rounded,
            label: 'Semester',
            value: paper.semester,
          ),
          _buildDetailRow(
            icon: Icons.access_time_rounded,
            label: 'Upload Date',
            value: DateFormat('MMM dd, yyyy').format(paper.uploadedAt),
          ),
          _buildDetailRow(
            icon: Icons.person_rounded,
            label: 'Paper By',
            value: paper.userName ?? '',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow({
    required IconData icon,
    required String label,
    required String value,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.blue.shade600, size: 20),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.grey.shade800,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.grey.shade200, height: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildActionButtons(QuestionPaper paper) {
    final bool canDelete = _checkDeletePermission(paper);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.download_rounded,
            label: 'Download Paper',
            color: Colors.green.shade600,
            onTap: () => _downloadPaper(paper),
          ),
          if (canDelete) ...[
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.delete_rounded,
              label: _isDeleting ? 'Deleting...' : 'Delete Paper',
              color: Colors.red.shade600,
              onTap: _isDeleting ? null : () => _confirmDelete(paper),
              isLoading: _isDeleting,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 22),
                    const SizedBox(width: 10),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ============================================================================
// PAPER CARD WIDGET
// ============================================================================

class PaperCard extends StatefulWidget {
  final QuestionPaper paper;
  final int index;

  const PaperCard({super.key, required this.paper, required this.index});

  @override
  State<PaperCard> createState() => _PaperCardState();
}

class _PaperCardState extends State<PaperCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 0.9,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    Future.delayed(Duration(milliseconds: widget.index * 60), () {
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
    return ScaleTransition(
      scale: _scaleAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PaperDetailsPage(paperId: widget.paper.id),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.paper.imageUrl.isNotEmpty)
                      Hero(
                        tag: 'paper${widget.paper.id}',
                        child: ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
                          child: AspectRatio(
                            aspectRatio: 16 / 9,
                            child: CachedNetworkImage(
                              imageUrl: widget.paper.imageUrl,
                              fit: BoxFit.cover,
                              placeholder: (context, url) => Shimmer.fromColors(
                                baseColor: Colors.grey.shade200,
                                highlightColor: Colors.grey.shade50,
                                child: Container(color: Colors.white),
                              ),
                              errorWidget: (context, url, error) => Container(
                                color: Colors.grey.shade100,
                                child: Icon(
                                  Icons.description_rounded,
                                  size: 48,
                                  color: Colors.grey.shade400,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.paper.subject,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.grey.shade800,
                              letterSpacing: -0.3,
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _buildInfoChip(
                                widget.paper.examType,
                                Icons.assignment_rounded,
                              ),
                              _buildInfoChip(
                                widget.paper.semester,
                                Icons.calendar_today_rounded,
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.location_on_rounded,
                                  size: 14,
                                  color: Colors.grey.shade600,
                                ),
                                const SizedBox(width: 6),
                                Flexible(
                                  child: Text(
                                    '${widget.paper.branch} • ${widget.paper.college}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                      fontWeight: FontWeight.w500,
                                      letterSpacing: 0.2,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip(String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.blue.shade600),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue.shade700,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FILTER CARD WIDGET (RESPONSIVE)
// ============================================================================

class FilterCard extends StatelessWidget {
  final String? selectedCollege;
  final String? selectedBranch;
  final String? selectedSemester;
  final String? selectedSubject;
  final String? selectedExamType;
  final ValueChanged<String?> onCollegeChanged;
  final ValueChanged<String?> onBranchChanged;
  final ValueChanged<String?> onSemesterChanged;
  final ValueChanged<String?> onSubjectChanged;
  final ValueChanged<String?> onExamTypeChanged;
  final VoidCallback onSearch;

  const FilterCard({
    super.key,
    required this.selectedCollege,
    required this.selectedBranch,
    required this.selectedSemester,
    required this.selectedSubject,
    required this.selectedExamType,
    required this.onCollegeChanged,
    required this.onBranchChanged,
    required this.onSemesterChanged,
    required this.onSubjectChanged,
    required this.onExamTypeChanged,
    required this.onSearch,
  });

  @override
  Widget build(BuildContext context) {
    final branches = selectedCollege != null
        ? collegeData[selectedCollege] ?? []
        : <String>[];
    final List<String> subjects;
    if (selectedBranch != null && selectedSemester != null) {
      subjects = subjectData[selectedBranch!]?[selectedSemester!] ?? <String>[];
    } else {
      subjects = <String>[];
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.filter_list_rounded,
                    size: 20,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Filter Papers',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    letterSpacing: -0.3,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            _buildResponsiveFilters(context, branches, subjects),
            const SizedBox(height: 20),
            SearchButton(isLoading: false, onPressed: onSearch),
          ],
        ),
      ),
    );
  }

  Widget _buildResponsiveFilters(
    BuildContext context,
    List<String> branches,
    List<String> subjects,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool isWide = constraints.maxWidth >= 700;

        if (!isWide) {
          // Mobile / narrow layout
          return Column(
            children: [
              ModernDropdown(
                label: 'College',
                icon: Icons.school_rounded,
                value: selectedCollege,
                items: collegeData.keys.toList(),
                onChanged: onCollegeChanged,
              ),
              const SizedBox(height: 12),
              ModernDropdown(
                label: 'Branch',
                icon: Icons.account_tree_rounded,
                value: selectedBranch,
                items: branches,
                onChanged: onBranchChanged,
              ),
              const SizedBox(height: 12),
              ModernDropdown(
                label: 'Semester',
                icon: Icons.calendar_today_rounded,
                value: selectedSemester,
                items: semesters,
                onChanged: onSemesterChanged,
              ),
              const SizedBox(height: 12),
              ModernDropdown(
                label: 'Subject',
                icon: Icons.book_rounded,
                value: selectedSubject,
                items: subjects,
                onChanged: onSubjectChanged,
              ),
              const SizedBox(height: 12),
              ModernDropdown(
                label: 'Exam Type',
                icon: Icons.assignment_rounded,
                value: selectedExamType,
                items: examTypes,
                onChanged: onExamTypeChanged,
              ),
            ],
          );
        }

        // Tablet / desktop: two-column grid
        final double fieldWidth = (constraints.maxWidth - 12) / 2;

        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(
              width: fieldWidth,
              child: ModernDropdown(
                label: 'College',
                icon: Icons.school_rounded,
                value: selectedCollege,
                items: collegeData.keys.toList(),
                onChanged: onCollegeChanged,
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: ModernDropdown(
                label: 'Branch',
                icon: Icons.account_tree_rounded,
                value: selectedBranch,
                items: branches,
                onChanged: onBranchChanged,
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: ModernDropdown(
                label: 'Semester',
                icon: Icons.calendar_today_rounded,
                value: selectedSemester,
                items: semesters,
                onChanged: onSemesterChanged,
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: ModernDropdown(
                label: 'Subject',
                icon: Icons.book_rounded,
                value: selectedSubject,
                items: subjects,
                onChanged: onSubjectChanged,
              ),
            ),
            SizedBox(
              width: fieldWidth,
              child: ModernDropdown(
                label: 'Exam Type',
                icon: Icons.assignment_rounded,
                value: selectedExamType,
                items: examTypes,
                onChanged: onExamTypeChanged,
              ),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================================
// MODERN DROPDOWN WIDGET
// ============================================================================

class ModernDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  const ModernDropdown({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map(
              (item) => DropdownMenuItem(
                value: item,
                child: Text(
                  item,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey.shade800,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            )
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        isExpanded: true,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(14),
        icon: Icon(
          Icons.expand_more_rounded,
          color: Colors.grey.shade600,
          size: 22,
        ),
      ),
    );
  }
}

// ============================================================================
// SEARCH BUTTON WIDGET
// ============================================================================

class SearchButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SearchButton({
    super.key,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          colors: [Colors.blue.shade600, Colors.blue.shade700],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.shade200.withOpacity(0.5),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.search_rounded, color: Colors.white, size: 20),
                      SizedBox(width: 10),
                      Text(
                        'Search Papers',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

// ============================================================================
// MAIN SEARCH PAGE (RESPONSIVE)
// ============================================================================

class SearchQuestionPaperPage extends ConsumerStatefulWidget {
  const SearchQuestionPaperPage({super.key});

  @override
  ConsumerState<SearchQuestionPaperPage> createState() =>
      _SearchQuestionPaperPageState();
}

class _SearchQuestionPaperPageState
    extends ConsumerState<SearchQuestionPaperPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _filterPanelController;
  late Animation<Offset> _slideAnimation;

  String? _selectedCollege;
  String? _selectedBranch;
  String? _selectedSemester;
  String? _selectedSubject;
  String? _selectedExamType;

  final ScrollController _scrollController = ScrollController();
  List<QuestionPaper> _papers = [];
  DocumentSnapshot? _lastDocument;
  bool _isLoadingMore = false;
  bool _hasMore = true;
  StreamSubscription<List<QuestionPaper>>? _searchSubscription;

  @override
  void initState() {
    super.initState();
    _headerController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
    _filterPanelController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.3), end: Offset.zero).animate(
      CurvedAnimation(
        parent: _filterPanelController,
        curve: Curves.easeOut,
      ),
    );

    _scrollController.addListener(_onScroll);
    _fetchInitialData();
  }

  void _onScroll() {
    if (_scrollController.position.pixels ==
            _scrollController.position.maxScrollExtent &&
        _hasMore &&
        !_isLoadingMore) {
      _loadMorePapers();
    }
  }

  Future<void> _fetchInitialData() async {
    setState(() {
      _papers = [];
      _lastDocument = null;
      _hasMore = true;
    });
    _loadMorePapers();
  }

  Future<void> _loadMorePapers() async {
    if (_isLoadingMore || !_hasMore) return;
    setState(() {
      _isLoadingMore = true;
    });

    await _searchSubscription?.cancel();

    final searchRepository = ref.read(searchRepositoryProvider);
    final stream = searchRepository.searchExamPapers(
      college: _selectedCollege,
      branch: _selectedBranch,
      semester: _selectedSemester,
      subject: _selectedSubject,
      examType: _selectedExamType,
      startAfter: _lastDocument,
    );

    _searchSubscription = stream.listen(
      (newPapers) {
        if (mounted) {
          if (newPapers.length < 20) {
            _hasMore = false;
          }

          if (newPapers.isNotEmpty) {
            FirebaseFirestore.instance
                .collection('submitted_papers')
                .doc(newPapers.last.id)
                .get()
                .then((doc) {
              if (mounted) {
                _lastDocument = doc;
              }
            });
          }

          setState(() {
            _papers.addAll(newPapers);
            _isLoadingMore = false;
          });
        }
      },
      onError: (error) {
        if (mounted) {
          setState(() {
            _isLoadingMore = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error loading papers: $error'),
              backgroundColor: Colors.red.shade600,
            ),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    _searchSubscription?.cancel();
    _headerController.dispose();
    _filterPanelController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onFiltersChanged() {
    _fetchInitialData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: FadeTransition(
          opacity: _headerController,
          child: Text(
            'Search Papers',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 22,
              letterSpacing: -0.5,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        actions: [
          ScaleTransition(
            scale: _headerController,
            child: Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.refresh_rounded,
                    size: 22,
                    color: Colors.grey.shade700,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedCollege = null;
                      _selectedBranch = null;
                      _selectedSemester = null;
                      _selectedSubject = null;
                      _selectedExamType = null;
                    });
                    _onFiltersChanged();
                  },
                  tooltip: 'Reset Filters',
                ),
              ),
            ),
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, Colors.grey.shade50],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;
              final bool isDesktop = width >= 1100;
              final bool isTablet = width >= 700 && width < 1100;

              final double maxContentWidth = isDesktop
                  ? 1100
                  : isTablet
                      ? 900
                      : width;

              final bool useGrid = isTablet || isDesktop;
              final int gridCrossAxisCount = isDesktop ? 3 : 2;

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: CustomScrollView(
                    controller: _scrollController,
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 12, 16, 20),
                            child: FilterCard(
                              selectedCollege: _selectedCollege,
                              selectedBranch: _selectedBranch,
                              selectedSemester: _selectedSemester,
                              selectedSubject: _selectedSubject,
                              selectedExamType: _selectedExamType,
                              onCollegeChanged: (value) {
                                setState(() {
                                  _selectedCollege = value;
                                  _selectedBranch = null;
                                  _selectedSemester = null;
                                  _selectedSubject = null;
                                });
                              },
                              onBranchChanged: (value) {
                                setState(() {
                                  _selectedBranch = value;
                                  _selectedSemester = null;
                                  _selectedSubject = null;
                                });
                              },
                              onSemesterChanged: (value) {
                                setState(() {
                                  _selectedSemester = value;
                                  _selectedSubject = null;
                                });
                              },
                              onSubjectChanged: (value) {
                                setState(() {
                                  _selectedSubject = value;
                                });
                              },
                              onExamTypeChanged: (value) {
                                setState(() {
                                  _selectedExamType = value;
                                });
                              },
                              onSearch: _onFiltersChanged,
                            ),
                          ),
                        ),
                      ),
                      if (_papers.isNotEmpty) ...[
                        SliverToBoxAdapter(
                          child: Padding(
                            padding:
                                const EdgeInsets.fromLTRB(16, 8, 16, 16),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Results',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade800,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.shade50,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    '${_papers.length}',
                                    style: TextStyle(
                                      color: Colors.blue.shade700,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 14,
                                      letterSpacing: 0.2,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding:
                              const EdgeInsets.symmetric(horizontal: 16),
                          sliver: useGrid
                              ? SliverGrid(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final paper = _papers[index];
                                      return PaperCard(
                                        paper: paper,
                                        index: index,
                                      );
                                    },
                                    childCount: _papers.length,
                                  ),
                                  gridDelegate:
                                      SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: gridCrossAxisCount,
                                    crossAxisSpacing: 16,
                                    mainAxisSpacing: 16,
                                    childAspectRatio: 0.85,
                                  ),
                                )
                              : SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final paper = _papers[index];
                                      return PaperCard(
                                        paper: paper,
                                        index: index,
                                      );
                                    },
                                    childCount: _papers.length,
                                  ),
                                ),
                        ),
                        if (_isLoadingMore)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: Center(
                                child: CircularProgressIndicator(
                                  color: Colors.blue.shade600,
                                  strokeWidth: 2.5,
                                ),
                              ),
                            ),
                          ),
                      ] else if (_isLoadingMore)
                        SliverFillRemaining(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.blue.shade600,
                              strokeWidth: 2.5,
                            ),
                          ),
                        )
                      else
                        SliverFillRemaining(
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(24),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.search_rounded,
                                    size: 64,
                                    color: Colors.grey.shade400,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  'No papers found',
                                  style: TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey.shade700,
                                    letterSpacing: -0.3,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Try different filter combinations',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade500,
                                    letterSpacing: 0.2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
