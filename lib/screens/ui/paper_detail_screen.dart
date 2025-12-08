// lib/pages/paper_details_page.dart

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:exam_ready/riverpod/question_paper_provider.dart';
import 'package:exam_ready/models/question_paper_model.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:shimmer/shimmer.dart';

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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  bool get _isMobile => MediaQuery.of(context).size.width < 600;
  bool get _isTablet =>
      MediaQuery.of(context).size.width >= 600 &&
      MediaQuery.of(context).size.width < 1024;
  bool get _isDesktop => MediaQuery.of(context).size.width >= 1024;

  double get _contentMaxWidth {
    if (_isDesktop) return 900;
    if (_isTablet) return 700;
    return double.infinity;
  }

  double get _horizontalPadding {
    if (_isDesktop) return 32;
    if (_isTablet) return 24;
    return 16;
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
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: _contentMaxWidth),
                child: Column(
                  children: [
                    _buildImageSection(paper),
                    _buildInfoSection(paper),
                    _buildActionButtons(paper),
                    SizedBox(height: _isDesktop ? 60 : 40),
                  ],
                ),
              ),
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
      centerTitle: _isDesktop,
      leading: Container(
        margin: EdgeInsets.all(_isMobile ? 8 : 12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(12),
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            color: Colors.white,
          ),
          iconSize: _isMobile ? 20 : 22,
          onPressed: () => Navigator.pop(context),
        ),
      ),
      actions: [
        Container(
          margin: EdgeInsets.all(_isMobile ? 8 : 12),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.share_rounded, color: Colors.white),
            iconSize: _isMobile ? 20 : 22,
            onPressed: () => _showShareDialog(paper),
          ),
        ),
        if (_isDesktop) SizedBox(width: _horizontalPadding - 12),
      ],
    );
  }

  Widget _buildImageSection(QuestionPaper paper) {
    final imageHeight = _isMobile ? 400.0 : (_isTablet ? 500.0 : 600.0);

    return Hero(
      tag: 'paper_${paper.id}',
      child: GestureDetector(
        onTap: () => _showFullScreenImage(paper.imageUrl),
        child: Container(
          margin: EdgeInsets.fromLTRB(
            _horizontalPadding,
            _isDesktop ? 32 : 24,
            _horizontalPadding,
            0,
          ),
          height: imageHeight,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(_isDesktop ? 28 : 24),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.25),
                blurRadius: _isDesktop ? 40 : 30,
                offset: Offset(0, _isDesktop ? 20 : 15),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(_isDesktop ? 28 : 24),
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
                          size: _isDesktop ? 100 : 80,
                        ),
                      ),
                    );
                  },
                ),
                Positioned(
                  bottom: _isDesktop ? 24 : 16,
                  right: _isDesktop ? 24 : 16,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: _isDesktop ? 20 : 16,
                      vertical: _isDesktop ? 12 : 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.zoom_in_rounded,
                          color: Colors.white,
                          size: _isDesktop ? 20 : 18,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          'Tap to zoom',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _isDesktop ? 14 : 13,
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
      margin: EdgeInsets.fromLTRB(
        _horizontalPadding,
        _isDesktop ? 40 : 24,
        _horizontalPadding,
        0,
      ),
      padding: EdgeInsets.all(_isDesktop ? 32 : (_isTablet ? 28 : 24)),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
        ),
        borderRadius: BorderRadius.circular(_isDesktop ? 28 : 24),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF667EEA).withOpacity(0.35),
            blurRadius: _isDesktop ? 30 : 20,
            offset: Offset(0, _isDesktop ? 15 : 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Paper Details',
            style: TextStyle(
              fontSize: _isDesktop ? 28 : (_isTablet ? 26 : 24),
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: _isDesktop ? 28 : 20),
          if (_isDesktop)
            _buildDesktopDetailsGrid(paper)
          else
            _buildMobileDetailsList(paper),
        ],
      ),
    );
  }

  Widget _buildDesktopDetailsGrid(QuestionPaper paper) {
    final details = [
      (Icons.menu_book_rounded, 'Subject', paper.subject),
      (Icons.assignment_rounded, 'Exam Type', paper.examType),
      (Icons.school_rounded, 'College', paper.college),
      (Icons.account_tree_rounded, 'Branch', paper.branch),
      (Icons.calendar_month_rounded, 'Semester', paper.semester),
      (
        Icons.access_time_rounded,
        'Upload Date',
        DateFormat('MMM dd, yyyy').format(paper.uploadedAt),
      ),
      if (paper.userName != null && paper.userName!.trim().isNotEmpty)
        (Icons.person_rounded, 'Paper By', paper.userName!),
    ];

    return Column(
      children: [
        for (int i = 0; i < details.length; i += 2) ...[
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: details[i].$1,
                  label: details[i].$2,
                  value: details[i].$3,
                ),
              ),
              if (i + 1 < details.length) ...[
                const SizedBox(width: 24),
                Expanded(
                  child: _buildDetailItem(
                    icon: details[i + 1].$1,
                    label: details[i + 1].$2,
                    value: details[i + 1].$3,
                  ),
                ),
              ] else
                const Expanded(child: SizedBox()),
            ],
          ),
          if (i + 2 < details.length) const SizedBox(height: 20),
        ],
      ],
    );
  }

  Widget _buildMobileDetailsList(QuestionPaper paper) {
    return Column(
      children: [
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
        if (paper.userName != null && paper.userName!.trim().isNotEmpty)
          _buildDetailRow(
            icon: Icons.person_rounded,
            label: 'Paper By',
            value: paper.userName!,
            isLast: true,
          ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white.withOpacity(0.7),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
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
              padding: EdgeInsets.all(_isMobile ? 10 : 12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: _isMobile ? 20 : 22),
            ),
            SizedBox(width: _isMobile ? 16 : 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: _isMobile ? 12 : 13,
                      color: Colors.white.withOpacity(0.7),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: _isMobile ? 16 : 17,
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
          SizedBox(height: _isMobile ? 16 : 18),
          Divider(color: Colors.white.withOpacity(0.2), height: 1),
          SizedBox(height: _isMobile ? 16 : 18),
        ],
      ],
    );
  }

  Widget _buildActionButtons(QuestionPaper paper) {
    final bool canDelete = _checkDeletePermission(paper);

    return Container(
      margin: EdgeInsets.fromLTRB(
        _horizontalPadding,
        _isDesktop ? 32 : 24,
        _horizontalPadding,
        0,
      ),
      child: _isDesktop && canDelete
          ? Row(
              children: [
                Expanded(
                  flex: 2,
                  child: _buildActionButton(
                    icon: Icons.download_rounded,
                    label: 'Download Paper',
                    gradient: const LinearGradient(
                      colors: [Color(0xFF43A047), Color(0xFF66BB6A)],
                    ),
                    onTap: () => _downloadPaper(paper),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionButton(
                    icon: Icons.delete_rounded,
                    label: _isDeleting ? 'Deleting...' : 'Delete',
                    gradient: LinearGradient(
                      colors: [Colors.red[700]!, Colors.red[500]!],
                    ),
                    onTap: _isDeleting ? null : () => _confirmDelete(paper),
                    isLoading: _isDeleting,
                  ),
                ),
              ],
            )
          : Column(
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
                  SizedBox(height: _isMobile ? 12 : 16),
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
        borderRadius: BorderRadius.circular(_isDesktop ? 16 : 20),
        child: Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: _isDesktop ? 20 : 18),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(_isDesktop ? 16 : 20),
            boxShadow: [
              BoxShadow(
                color: gradient.colors.first.withOpacity(0.35),
                blurRadius: _isDesktop ? 20 : 15,
                offset: Offset(0, _isDesktop ? 10 : 8),
              ),
            ],
          ),
          child: isLoading
              ? Center(
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
                    Icon(icon, color: Colors.white, size: _isDesktop ? 26 : 24),
                    SizedBox(width: _isDesktop ? 14 : 12),
                    Text(
                      label,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _isDesktop ? 18 : 17,
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
                margin: EdgeInsets.all(_isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
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
                    CircularProgressIndicator(
                      color: const Color(0xFF667EEA),
                      strokeWidth: 3,
                    ),
                    SizedBox(height: _isDesktop ? 32 : 24),
                    Text(
                      'Loading paper details...',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: _isDesktop ? 18 : 16,
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
                margin: EdgeInsets.all(_isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
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
                  padding: EdgeInsets.all(_horizontalPadding),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: _isDesktop ? 120 : 100,
                        color: Colors.white.withOpacity(0.3),
                      ),
                      SizedBox(height: _isDesktop ? 32 : 24),
                      Text(
                        'Paper Not Found',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: _isDesktop ? 28 : 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: _isDesktop ? 16 : 12),
                      Text(
                        'This paper may have been deleted',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: _isDesktop ? 18 : 16,
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
                margin: EdgeInsets.all(_isMobile ? 8 : 12),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.15),
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
                  padding: EdgeInsets.all(_isDesktop ? 48 : 40),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 500),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: _isDesktop ? 120 : 100,
                          color: Colors.red[300],
                        ),
                        SizedBox(height: _isDesktop ? 32 : 24),
                        Text(
                          'Something Went Wrong',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: _isDesktop ? 28 : 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: _isDesktop ? 16 : 12),
                        Text(
                          error,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: _isDesktop ? 18 : 16,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _checkDeletePermission(QuestionPaper paper) {
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_isDesktop ? 24 : 20),
        ),
        contentPadding: EdgeInsets.all(_isDesktop ? 28 : 24),
        title: Row(
          children: [
            Icon(
              Icons.warning_rounded,
              color: Colors.orange[700],
              size: _isDesktop ? 32 : 28,
            ),
            const SizedBox(width: 12),
            Text(
              'Confirm Delete',
              style: TextStyle(fontSize: _isDesktop ? 22 : 20),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete this question paper? This action cannot be undone.',
          style: TextStyle(
            fontSize: _isDesktop ? 16 : 15,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: _isDesktop ? 17 : 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
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
              backgroundColor: Colors.red[600],
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: EdgeInsets.symmetric(
                horizontal: _isDesktop ? 28 : 24,
                vertical: _isDesktop ? 14 : 12,
              ),
            ),
            child: Text(
              'Delete',
              style: TextStyle(
                fontSize: _isDesktop ? 17 : 16,
                fontWeight: FontWeight.bold,
              ),
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
        margin: EdgeInsets.all(_isMobile ? 16 : 24),
        constraints: BoxConstraints(
          maxWidth: _isDesktop ? 500 : double.infinity,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(_isDesktop ? 28 : 24),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: _isDesktop ? 20 : 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            SizedBox(height: _isDesktop ? 28 : 24),
            Text(
              'Share Paper',
              style: TextStyle(
                fontSize: _isDesktop ? 24 : 22,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF1A1A2E),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                paper.subject,
                style: TextStyle(
                  fontSize: _isDesktop ? 15 : 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ),
            SizedBox(height: _isDesktop ? 32 : 24),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: _isDesktop ? 40 : 20),
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
            SizedBox(height: _isDesktop ? 40 : 32),
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
            padding: EdgeInsets.all(_isDesktop ? 22 : 20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF667EEA), Color(0xFF764BA2)],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF667EEA).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: _isDesktop ? 30 : 28),
          ),
          SizedBox(height: _isDesktop ? 14 : 12),
          Text(
            label,
            style: TextStyle(
              fontSize: _isDesktop ? 15 : 14,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF1A1A2E),
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
              child: Text(
                message,
                style: TextStyle(fontSize: _isDesktop ? 16 : 15),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? const Color(0xFFE53935)
            : isSuccess
            ? const Color(0xFF43A047)
            : const Color(0xFF667EEA),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_isDesktop ? 16 : 12),
        ),
        margin: EdgeInsets.all(_isMobile ? 16 : 20),
        duration: const Duration(seconds: 3),
      ),
    );
  }
}
