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
    StreamProvider.family<List<QuestionPaper>, Map<String, String?>>((
      ref,
      filters,
    ) {
      final searchRepository = ref.watch(searchRepositoryProvider);
      return searchRepository.searchExamPapers(
        college: filters['college'],
        branch: filters['branch'],
        semester: filters['semester'],
        subject: filters['subject'],
        examType: filters['examType'],
      );
    });

// ============================================================================
// PAPER DETAILS PAGE (ENHANCED)
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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();
  }

  Widget _buildLoadingState() {
    return Container(
      color: const Color(0xFF1A1A2E),
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: Color(0xFF667EEA),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 24),
                    Text(
                      'Loading paper details...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
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
      color: const Color(0xFF1A1A2E),
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.search_off_rounded,
                      size: 100,
                      color: Colors.white.withAlpha(77),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Paper Not Found',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'This paper may have been deleted',
                      style: TextStyle(
                        color: Colors.white.withAlpha(179),
                        fontSize: 16,
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
      color: const Color(0xFF1A1A2E),
      child: SafeArea(
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(51),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Colors.white,
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(40),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline_rounded,
                        size: 100,
                        color: Colors.red[300],
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Something Went Wrong',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        error,
                        style: TextStyle(
                          color: Colors.white.withAlpha(179),
                          fontSize: 16,
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

  // Helper Methods

  bool _checkDeletePermission(QuestionPaper paper) {
    // TODO: Implement proper authentication check
    // In production, check if current user ID matches paper.uploadedBy
    // or if user is admin
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
                    color: const Color(0xFF667EEA),
                  ),
                ),
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(128),
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
    // TODO: Implement actual download functionality
    _showSnackBar('Download feature coming soon!', isSuccess: true);
  }

  void _confirmDelete(QuestionPaper paper) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.orange[700], size: 28),
            const SizedBox(width: 12),
            const Text('Confirm Delete'),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this question paper? This action cannot be undone.',
          style: TextStyle(fontSize: 15, color: Colors.grey[700], height: 1.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              // TODO: Implement actual delete functionality
              setState(() => _isDeleting = true);
              // Simulate deletion
              Future.delayed(const Duration(seconds: 2), () {
                if (mounted) {
                  Navigator.pop(context); // Pop details page
                  _showSnackBar('Paper deleted successfully', isSuccess: true);
                }
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text(
              'Delete',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
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
      builder: (context) => Container(
        margin: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Share Paper',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              paper.subject,
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
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
      borderRadius: BorderRadius.circular(20),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withAlpha(77),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1A1A2E),
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
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(message, style: const TextStyle(fontSize: 15)),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFE53935)
            : isSuccess
            ? const Color(0xFF43A047)
            : const Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
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
      backgroundColor: const Color(0xFF1A1A2E),
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
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          _buildAppBar(paper),
          SliverToBoxAdapter(
            child: Column(
              children: [
                _buildImageSection(paper),
                _buildInfoSection(paper),
                _buildActionButtons(paper),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(QuestionPaper paper) {
    return SliverAppBar(
      expandedHeight: 0,
      floating: true,
      pinned: true,
      backgroundColor: const Color(0xFF1A1A2E),
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.white.withAlpha(51),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.white.withAlpha(51),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            onPressed: () => _showShareDialog(paper),
          ),
        ),
      ],
    );
  }

  Widget _buildImageSection(QuestionPaper paper) {
    return Hero(
      tag: 'paper_${paper.id}',
      child: GestureDetector(
        onTap: () => _showFullScreenImage(paper.imageUrl),
        child: Container(
          margin: const EdgeInsets.all(20),
          height: 500,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(77),
                blurRadius: 30,
                offset: const Offset(0, 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
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
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.grey[300]!, Colors.grey[200]!],
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.broken_image_rounded,
                          color: Colors.grey[500],
                          size: 80,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withAlpha(179),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(
                          Icons.zoom_in_rounded,
                          color: Colors.white,
                          size: 18,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Tap to zoom',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
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
    );
  }

  Widget _buildInfoSection(QuestionPaper paper) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withAlpha(102),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Paper Details',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
                color: Colors.white.withAlpha(51),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
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
                      color: Colors.white.withAlpha(179),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 16),
          Divider(color: Colors.white.withAlpha(51), height: 1),
          const SizedBox(height: 16),
        ],
      ],
    );
  }

  Widget _buildActionButtons(QuestionPaper paper) {
    final bool canDelete = _checkDeletePermission(paper);

    return Container(
      margin: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildActionButton(
            icon: Icons.download_rounded,
            label: 'Download Paper',
            gradient: const LinearGradient(
              colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
            ),
            onTap: () => _downloadPaper(paper),
          ),
          if (canDelete) ...[
            const SizedBox(height: 12),
            _buildActionButton(
              icon: Icons.delete_rounded,
              label: _isDeleting ? 'Deleting...' : 'Delete Paper',
              gradient: LinearGradient(
                colors: [Colors.red[700]!, Colors.red[500]!],
              ),
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
    required Gradient gradient,
    required VoidCallback? onTap,
    bool isLoading = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 18),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withAlpha(102),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isLoading
              ? const Center(
                  child: SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, color: Colors.white, size: 24),
                    const SizedBox(width: 12),
                    Text(
                      label,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutBack));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    Future.delayed(Duration(milliseconds: widget.index * 100), () {
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
                // Navigate to enhanced PaperDetailPage
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        PaperDetailsPage(paperId: widget.paper.id),
                  ),
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white.withAlpha(115),
                          Colors.white.withAlpha(64),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withAlpha(102),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withAlpha(20),
                          blurRadius: 24,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (widget.paper.imageUrl.isNotEmpty)
                          Hero(
                            tag: 'paper_${widget.paper.id}',
                            child: AspectRatio(
                              aspectRatio: 16 / 9,
                              child: CachedNetworkImage(
                                imageUrl: widget.paper.imageUrl,
                                fit: BoxFit.cover,
                                placeholder: (context, url) => Container(
                                  color: Colors.grey.shade200,
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.primary,
                                      strokeWidth: 2,
                                    ),
                                  ),
                                ),
                                errorWidget: (context, url, error) => Container(
                                  color: Colors.grey.shade200,
                                  child: Icon(
                                    Icons.description_rounded,
                                    size: 64,
                                    color: Colors.grey.shade400,
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
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 20,
                                    ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  _buildInfoChip(
                                    context,
                                    widget.paper.examType,
                                    Icons.assignment_rounded,
                                  ),
                                  _buildInfoChip(
                                    context,
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
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.secondary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.location_on_rounded,
                                      size: 14,
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.secondary,
                                    ),
                                    const SizedBox(width: 6),
                                    Flexible(
                                      child: Text(
                                        '${widget.paper.branch} • ${widget.paper.college}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.secondary,
                                              fontWeight: FontWeight.w600,
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
        ),
      ),
    );
  }

  Widget _buildInfoChip(BuildContext context, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.25),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// FILTER CARD WIDGET
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

    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.4),
                Colors.white.withOpacity(0.15),
              ],
            ),
            border: Border.all(
              color: Colors.white.withOpacity(0.5),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.08),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Filter Papers',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 20),
                ModernDropdown(
                  label: 'College',
                  icon: Icons.school_rounded,
                  value: selectedCollege,
                  items: collegeData.keys.toList(),
                  onChanged: onCollegeChanged,
                ),
                const SizedBox(height: 16),
                ModernDropdown(
                  label: 'Branch',
                  icon: Icons.account_tree_rounded,
                  value: selectedBranch,
                  items: branches,
                  onChanged: onBranchChanged,
                ),
                const SizedBox(height: 16),
                ModernDropdown(
                  label: 'Semester',
                  icon: Icons.calendar_today_rounded,
                  value: selectedSemester,
                  items: semesters,
                  onChanged: onSemesterChanged,
                ),
                const SizedBox(height: 16),
                ModernDropdown(
                  label: 'Subject',
                  icon: Icons.book_rounded,
                  value: selectedSubject,
                  items: subjects,
                  onChanged: onSubjectChanged,
                ),
                const SizedBox(height: 16),
                ModernDropdown(
                  label: 'Exam Type',
                  icon: Icons.assignment_rounded,
                  value: selectedExamType,
                  items: examTypes,
                  onChanged: onExamTypeChanged,
                ),
                const SizedBox(height: 24),
                SearchButton(isLoading: false, onPressed: onSearch),
              ],
            ),
          ),
        ),
      ),
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
        borderRadius: BorderRadius.circular(14),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.5),
            Colors.white.withOpacity(0.2),
          ],
        ),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(value: item, child: Text(item)))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
          floatingLabelBehavior: FloatingLabelBehavior.never,
        ),
        isExpanded: true,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(14),
        icon: Icon(
          Icons.expand_more_rounded,
          color: Theme.of(context).colorScheme.primary,
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
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Theme.of(context).colorScheme.primary,
            Theme.of(context).colorScheme.secondary,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: isLoading ? null : onPressed,
          child: Center(
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.5,
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.search_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Search Papers',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    )..forward();

    _filterPanelController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, -0.5), end: Offset.zero).animate(
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
            SnackBar(content: Text('Error loading papers: $error')),
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: FadeTransition(
          opacity: _headerController,
          child: const Text(
            'Search Exam Papers',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 24,
              letterSpacing: -0.5,
            ),
          ),
        ),
        actions: [
          ScaleTransition(
            scale: _headerController,
            child: Padding(
              padding: const EdgeInsets.only(right: 16),
              child: IconButton(
                icon: const Icon(Icons.refresh_rounded, size: 24),
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
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.08),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.06),
                  Colors.white,
                ],
                stops: const [0.0, 0.5, 1.0],
              ),
            ),
          ),
          SafeArea(
            child: CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverToBoxAdapter(
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 20,
                      ),
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
                      padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Results',
                            style: Theme.of(context).textTheme.headlineSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.15),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_papers.length}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final paper = _papers[index];
                        return PaperCard(paper: paper, index: index);
                      }, childCount: _papers.length),
                    ),
                  ),
                  if (_isLoadingMore)
                    const SliverToBoxAdapter(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Center(child: CircularProgressIndicator()),
                      ),
                    ),
                ] else if (_isLoadingMore)
                  const SliverFillRemaining(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else
                  SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.search_rounded,
                            size: 80,
                            color: Colors.grey.shade300,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No papers found',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey.shade600,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Try different filter combinations',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
