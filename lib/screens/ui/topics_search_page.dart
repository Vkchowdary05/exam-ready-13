// lib/screens/topics_search_page.dart
import 'dart:async';
import 'dart:ui';
import 'package:exam_ready/data/dropdown_data.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_ready/screens/ui/topics_detail_page.dart';

class TopicsSearchPage extends StatefulWidget {
  const TopicsSearchPage({Key? key}) : super(key: key);

  @override
  State<TopicsSearchPage> createState() => _TopicsSearchPageState();
}

class _TopicsSearchPageState extends State<TopicsSearchPage>
    with TickerProviderStateMixin {
  late AnimationController _headerController;
  late AnimationController _filterPanelController;
  late Animation<Offset> _slideAnimation;

  String? _selectedCollege;
  String? _selectedBranch;
  String? _selectedSemester;
  String? _selectedSubject;
  String? _selectedExamType;

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, dynamic>> _questionPapers = [];
  bool _showResults = false;

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
  }

  @override
  void dispose() {
    _headerController.dispose();
    _filterPanelController.dispose();
    super.dispose();
  }

  bool get _canSearch {
    return _selectedCollege != null &&
        _selectedBranch != null &&
        _selectedSemester != null &&
        _selectedSubject != null &&
        _selectedExamType != null;
  }

  Future<void> _searchTopics() async {
    if (!_canSearch) {
      setState(() {
        _errorMessage = 'Please select all filters';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _showResults = false;
    });

    try {
      // Create document name pattern: college_branch_semester_subject_examType
      String documentPattern = '${_selectedCollege}_${_selectedBranch}_${_selectedSemester}_${_selectedSubject}_${_selectedExamType}'
          .replaceAll(' ', '_')
          .toLowerCase();

      // Fetch from questions collection
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('questions')
          .get();

      List<Map<String, dynamic>> papers = [];

      for (var doc in querySnapshot.docs) {
        String docId = doc.id;
        
        // Check if document matches the pattern
        if (docId.toLowerCase().contains(documentPattern.toLowerCase())) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
          
          // Extract topics with their counts
          List<Map<String, dynamic>> topics = [];
          data.forEach((key, value) {
            // Skip metadata fields
            if (key != 'createdAt' && key != 'lastModified' && key != 'updatedAt') {
              topics.add({
                'name': key,
                'count': value is int ? value : 0,
              });
            }
          });

          // Sort topics by count in descending order
          topics.sort((a, b) => (b['count'] as int).compareTo(a['count'] as int));

          papers.add({
            'documentId': docId,
            'topics': topics,
          });
        }
      }

      setState(() {
        _questionPapers = papers;
        _isLoading = false;
        _showResults = true;
        
        if (papers.isEmpty) {
          _errorMessage = 'No question papers found for the selected filters';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error fetching data: ${e.toString()}';
      });
    }
  }

  void _resetFilters() {
    setState(() {
      _selectedCollege = null;
      _selectedBranch = null;
      _selectedSemester = null;
      _selectedSubject = null;
      _selectedExamType = null;
      _errorMessage = null;
      _showResults = false;
      _questionPapers = [];
    });
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
            'Search Important Topics',
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
                onPressed: _resetFilters,
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    SlideTransition(
                      position: _slideAnimation,
                      child: TopicsFilterCard(
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
                            _errorMessage = null;
                            _showResults = false;
                          });
                        },
                        onBranchChanged: (value) {
                          setState(() {
                            _selectedBranch = value;
                            _selectedSemester = null;
                            _selectedSubject = null;
                            _errorMessage = null;
                            _showResults = false;
                          });
                        },
                        onSemesterChanged: (value) {
                          setState(() {
                            _selectedSemester = value;
                            _selectedSubject = null;
                            _errorMessage = null;
                            _showResults = false;
                          });
                        },
                        onSubjectChanged: (value) {
                          setState(() {
                            _selectedSubject = value;
                            _errorMessage = null;
                            _showResults = false;
                          });
                        },
                        onExamTypeChanged: (value) {
                          setState(() {
                            _selectedExamType = value;
                            _errorMessage = null;
                            _showResults = false;
                          });
                        },
                        onSearch: _searchTopics,
                        canSearch: _canSearch,
                        isLoading: _isLoading,
                        errorMessage: _errorMessage,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_showResults && _questionPapers.isNotEmpty)
                      _buildResultsSection(context)
                    else if (!_showResults)
                      _buildInfoSection(context),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.1),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Icon(
                Icons.library_books_rounded,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 12),
              Text(
                'Found ${_questionPapers.length} Question Paper${_questionPapers.length > 1 ? 's' : ''}',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._questionPapers.map((paper) => _buildQuestionPaperCard(context, paper)),
      ],
    );
  }

  Widget _buildQuestionPaperCard(BuildContext context, Map<String, dynamic> paper) {
    List<Map<String, dynamic>> topics = paper['topics'];
    String documentId = paper['documentId'];
    
    // Get top topics based on exam type
    int topicsToShow = _selectedExamType?.toLowerCase().contains('mid') == true ? 10 : 20;
    List<Map<String, dynamic>> topTopics = topics.take(topicsToShow).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white,
            Colors.grey.shade50,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: ExpansionTile(
          tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.description_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          title: Text(
            documentId.replaceAll('_', ' ').toUpperCase(),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              '${topics.length} topics • Top $topicsToShow shown',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 12,
              ),
            ),
          ),
          children: [
            const Divider(height: 1),
            const SizedBox(height: 12),
            ...topTopics.asMap().entries.map((entry) {
              int index = entry.key;
              Map<String, dynamic> topic = entry.value;
              return _buildTopicItem(
                context,
                index + 1,
                topic['name'],
                topic['count'],
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildTopicItem(BuildContext context, int rank, String topicName, int count) {
    MaterialColor rankColor;
    if (rank <= 3) {
      rankColor = Colors.amber;
    } else if (rank <= 5) {
      rankColor = Colors.orange;
    } else {
      rankColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: rankColor.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: rankColor.shade900,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              topicName,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  Theme.of(context).colorScheme.primary.withOpacity(0.2),
                  Theme.of(context).colorScheme.secondary.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 16,
                  color: Theme.of(context).colorScheme.primary,
                ),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.blue.shade50,
            Colors.purple.shade50,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Theme.of(context).colorScheme.primary,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'How it works',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoPoint(
            '📊 Mid Exams',
            'View top 10 most frequently asked topics',
            context,
          ),
          const SizedBox(height: 12),
          _buildInfoPoint(
            '📚 Semester Exams',
            'View top 20 most frequently asked topics',
            context,
          ),
          const SizedBox(height: 12),
          _buildInfoPoint(
            '🔥 Higher Count',
            'Topics with higher count are asked more frequently',
            context,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPoint(String title, String description, BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade700,
            ),
          ),
        ),
      ],
    );
  }
}

class TopicsFilterCard extends StatelessWidget {
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
  final bool canSearch;
  final bool isLoading;
  final String? errorMessage;

  const TopicsFilterCard({
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
    required this.canSearch,
    required this.isLoading,
    this.errorMessage,
  }) : super(key: key);

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
                Row(
                  children: [
                    Icon(
                      Icons.auto_graph_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Find Important Topics',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                    ),
                  ],
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
                if (errorMessage != null) ...[
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.red.shade200,
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: Colors.red.shade700,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            errorMessage!,
                            style: TextStyle(
                              color: Colors.red.shade700,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                SearchTopicsButton(
                  isLoading: isLoading,
                  enabled: canSearch,
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

class SearchTopicsButton extends StatelessWidget {
  final bool isLoading;
  final bool enabled;
  final VoidCallback onPressed;

  const SearchTopicsButton({
    Key? key,
    required this.isLoading,
    required this.enabled,
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
        gradient: enabled
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Theme.of(context).colorScheme.primary,
                  Theme.of(context).colorScheme.secondary,
                ],
              )
            : LinearGradient(
                colors: [
                  Colors.grey.shade300,
                  Colors.grey.shade400,
                ],
              ),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.4),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: enabled && !isLoading ? onPressed : null,
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
                      Icon(
                        enabled
                            ? Icons.auto_graph_rounded
                            : Icons.lock_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'View Important Topics',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
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