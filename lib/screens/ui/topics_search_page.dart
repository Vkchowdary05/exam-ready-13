// lib/screens/topics_search_page.dart
import 'dart:async';
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
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();

    _filterPanelController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    )..forward();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.3),
      end: Offset.zero,
    ).animate(
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
      String documentPattern = '${_selectedCollege}_${_selectedBranch}_${_selectedSemester}_${_selectedSubject}_${_selectedExamType}'
          .replaceAll(' ', '_')
          .toLowerCase();

      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('questions')
          .get();

      List<Map<String, dynamic>> papers = [];

      for (var doc in querySnapshot.docs) {
        String docId = doc.id;

        if (docId.toLowerCase().contains(documentPattern.toLowerCase())) {
          Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

          List<Map<String, dynamic>> topics = [];
          data.forEach((key, value) {
            if (key != 'createdAt' &&
                key != 'lastModified' &&
                key != 'updatedAt') {
              topics.add({
                'name': key,
                'count': value is int ? value : 0,
              });
            }
          });

          topics.sort((a, b) =>
              (b['count'] as int).compareTo(a['count'] as int));

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

  void _navigateToDetails(String documentId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TopicsDetailPage(
          documentName: documentId,
          college: _selectedCollege!,
          branch: _selectedBranch!,
          semester: _selectedSemester!,
          subject: _selectedSubject!,
          examType: _selectedExamType!,
        ),
      ),
    );
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
            'Important Topics',
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
                  onPressed: _resetFilters,
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
            colors: [
              Colors.white,
              Colors.grey.shade50,
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
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
                  const SizedBox(height: 24),
                  if (_showResults && _questionPapers.isNotEmpty)
                    _buildResultsSection(context)
                  else if (!_showResults)
                    _buildInfoSection(context),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.library_books_rounded,
                  color: Colors.blue.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Found ${_questionPapers.length} Paper${_questionPapers.length > 1 ? 's' : ''}',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        ..._questionPapers.map(
          (paper) => _buildQuestionPaperCard(context, paper),
        ),
      ],
    );
  }

  Widget _buildQuestionPaperCard(
      BuildContext context, Map<String, dynamic> paper) {
    List<Map<String, dynamic>> topics = paper['topics'];
    String documentId = paper['documentId'];

    int topicsToShow = _selectedExamType?.toLowerCase().contains('mid') == true
        ? 10
        : 20;
    List<Map<String, dynamic>> topTopics =
        topics.take(topicsToShow).toList();

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Theme(
          data: Theme.of(context).copyWith(
            dividerColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.all(20),
            childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            leading: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.description_rounded,
                color: Colors.blue.shade600,
                size: 22,
              ),
            ),
            title: Text(
              documentId.replaceAll('_', ' ').toUpperCase(),
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: Colors.grey.shade800,
                letterSpacing: 0.2,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '${topics.length} topics • Top $topicsToShow shown',
                style: TextStyle(
                  color: Colors.grey.shade500,
                  fontSize: 12,
                  letterSpacing: 0.2,
                ),
              ),
            ),
            children: [
              Divider(color: Colors.grey.shade200, height: 1),
              const SizedBox(height: 16),
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
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () => _navigateToDetails(documentId),
                  icon: const Icon(Icons.analytics_rounded, size: 20),
                  label: const Text(
                    'View Detailed Analysis',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      letterSpacing: 0.2,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopicItem(
      BuildContext context, int rank, String topicName, int count) {
    Color rankColor;
    if (rank <= 3) {
      rankColor = Colors.amber.shade600;
    } else if (rank <= 5) {
      rankColor = Colors.orange.shade600;
    } else {
      rankColor = Colors.grey.shade600;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
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
              color: rankColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                '$rank',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: rankColor,
                  fontSize: 14,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              topicName,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade800,
                letterSpacing: 0.2,
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.blue.shade50,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.trending_up_rounded,
                  size: 14,
                  color: Colors.blue.shade600,
                ),
                const SizedBox(width: 4),
                Text(
                  '$count',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: Colors.blue.shade700,
                    letterSpacing: 0.2,
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.blue.shade100,
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.info_outline_rounded,
                  color: Colors.blue.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'How it works',
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
          _buildInfoPoint(
            '📊',
            'Mid Exams',
            'View top 10 most frequently asked topics',
          ),
          const SizedBox(height: 14),
          _buildInfoPoint(
            '📚',
            'Semester Exams',
            'View top 20 most frequently asked topics',
          ),
          const SizedBox(height: 14),
          _buildInfoPoint(
            '🔥',
            'Higher Count',
            'Topics with higher count are asked more frequently',
          ),
          const SizedBox(height: 14),
          _buildInfoPoint(
            '📈',
            'Detailed View',
            'Tap "View Detailed Analysis" for comprehensive statistics',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoPoint(String emoji, String title, String description) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          emoji,
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                  height: 1.4,
                  letterSpacing: 0.2,
                ),
              ),
            ],
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
      subjects =
          subjectData[selectedBranch!]?[selectedSemester!] ?? <String>[];
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
                    Icons.auto_graph_rounded,
                    color: Colors.blue.shade600,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Find Important Topics',
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
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        errorMessage!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            SearchTopicsButton(
              isLoading: isLoading,
              enabled: canSearch,
              onPressed: onSearch,
            ),
          ],
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
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
      ),
      child: DropdownButtonFormField<String>(
        value: value,
        items: items
            .map((item) => DropdownMenuItem(
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
                ))
            .toList(),
        onChanged: onChanged,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          prefixIcon: Icon(
            icon,
            color: Colors.grey.shade600,
            size: 20,
          ),
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
      height: 54,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: enabled
            ? LinearGradient(
                colors: [
                  Colors.blue.shade600,
                  Colors.blue.shade700,
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
                  color: Colors.blue.shade200.withOpacity(0.5),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: enabled && !isLoading ? onPressed : null,
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
                    children: [
                      Icon(
                        enabled
                            ? Icons.auto_graph_rounded
                            : Icons.lock_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'View Important Topics',
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