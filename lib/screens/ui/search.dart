import 'dart:async';
import 'dart:ui';
import 'package:exam_ready/data/dropdown_data.dart';
import 'package:exam_ready/models/question_paper_model.dart';
import 'package:exam_ready/repositories/search_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cached_network_image/cached_network_image.dart';

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

class SearchQuestionPaperPage extends ConsumerStatefulWidget {
  const SearchQuestionPaperPage({Key? key}) : super(key: key);

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

  // Stream management for memory leak prevention
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

    // Cancel previous subscription to prevent memory leaks
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

    // Use subscription for proper stream management
    _searchSubscription = stream.listen(
      (newPapers) {
        if (mounted) {
          if (newPapers.length < 20) {
            _hasMore = false;
          }

          if (newPapers.isNotEmpty) {
            // Update last document for pagination
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
          // Handle error appropriately
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error loading papers: $error')),
          );
        }
      },
    );
  }

  @override
  void dispose() {
    // Cancel stream subscription to prevent memory leaks
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
    Key? key,
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
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final branches = selectedCollege != null
        ? collegeData[selectedCollege] ?? []
        : <String>[];

    // Replace the original ternary that caused analyzer confusion with an explicit check
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
                SearchButton(
                  isLoading: false, // This is now handled by the main widget
                  onPressed: onSearch,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Modern Dropdown, Search Button, Paper Card and Paper Detail Page widgets remain the same as in the original file.
// I am not including them here for brevity, but they should be kept in the file.
// Make sure to copy the ModernDropdown, SearchButton, PaperCard, and PaperDetailPage widgets from the old search.dart file.

// Modern Dropdown Widget
class ModernDropdown extends StatelessWidget {
  final String label;
  final IconData icon;
  final String? value;
  final List<String> items;
  final ValueChanged<String?>? onChanged;

  const ModernDropdown({
    Key? key,
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.onChanged,
  }) : super(key: key);

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

// Search Button Widget
class SearchButton extends StatelessWidget {
  final bool isLoading;
  final VoidCallback onPressed;

  const SearchButton({
    Key? key,
    required this.isLoading,
    required this.onPressed,
  }) : super(key: key);

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

// Paper Card Widget
class PaperCard extends StatefulWidget {
  final QuestionPaper paper;
  final int index;

  const PaperCard({Key? key, required this.paper, required this.index})
    : super(key: key);

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
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PaperDetailPage(paper: widget.paper),
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
                          Colors.white.withValues(alpha: 0.45),
                          Colors.white.withValues(alpha: 0.25),
                        ],
                      ),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.08),
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
                              aspectRatio: 16 / 9, // Responsive aspect ratio
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

// Paper Detail Page
class PaperDetailPage extends StatelessWidget {
  final QuestionPaper paper;

  const PaperDetailPage({Key? key, required this.paper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8),
              ],
            ),
            child: const Icon(Icons.arrow_back, color: Colors.black87),
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (paper.imageUrl.isNotEmpty)
              Hero(
                tag: 'paper_${paper.id}',
                child: Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: CachedNetworkImage(
                    imageUrl: paper.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey.shade200,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey.shade200,
                      child: Icon(
                        Icons.description_rounded,
                        size: 100,
                        color: Colors.grey.shade400,
                      ),
                    ),
                  ),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    paper.subject,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildDetailCard(
                    context,
                    'College',
                    paper.college,
                    Icons.school_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    context,
                    'Branch',
                    paper.branch,
                    Icons.account_tree_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    context,
                    'Semester',
                    paper.semester,
                    Icons.calendar_today_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    context,
                    'Exam Type',
                    paper.examType,
                    Icons.assignment_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    context,
                    'Uploaded',
                    _formatDate(paper.uploadedAt),
                    Icons.access_time_rounded,
                  ),
                  const SizedBox(height: 12),
                  _buildDetailCard(
                    context,
                    'Status',
                    paper.status.toUpperCase(),
                    Icons.check_circle_rounded,
                    statusColor: paper.status == 'approved'
                        ? Colors.green
                        : Colors.orange,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailCard(
    BuildContext context,
    String label,
    String value,
    IconData icon, {
    Color? statusColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: (statusColor ?? Theme.of(context).colorScheme.primary)
                  .withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: statusColor ?? Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}
