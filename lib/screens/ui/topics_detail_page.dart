// lib/screens/ui/topics_detail_page.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TopicsDetailPage extends StatefulWidget {
  final String documentName;
  final String college;
  final String branch;
  final String semester;
  final String subject;
  final String examType;

  const TopicsDetailPage({
    super.key,
    required this.documentName,
    required this.college,
    required this.branch,
    required this.semester,
    required this.subject,
    required this.examType,
  });

  @override
  State<TopicsDetailPage> createState() => _TopicsDetailPageState();
}

class _TopicsDetailPageState extends State<TopicsDetailPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  bool _documentExists = false;
  Map<String, int> _topics = {};
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));
    _fetchTopics();
  }

  Future<void> _fetchTopics() async {
    try {
      final docSnapshot = await FirebaseFirestore.instance
          .collection('questions')
          .doc(widget.documentName)
          .get();
      if (!mounted) return;

      if (docSnapshot.exists) {
        final data = docSnapshot.data() as Map<String, dynamic>;

        Map<String, int> topicsMap = {};
        data.forEach((key, value) {
          if (key != 'createdAt' &&
              key != 'updatedAt' &&
              key != 'lastModified' &&
              value is int) {
            topicsMap[key] = value;
          }
        });

        var sortedEntries = topicsMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        int topCount = _isMiddleExam() ? 10 : 20;
        var topTopics = Map.fromEntries(sortedEntries.take(topCount));

        setState(() {
          _topics = topTopics;
          _documentExists = true;
          _isLoading = false;
        });

        _controller.forward();
      } else {
        setState(() {
          _documentExists = false;
          _isLoading = false;
          _errorMessage = 'No data found for this combination';
        });
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
        _errorMessage = 'Error loading topics: $e';
      });
    }
  }

  bool _isMiddleExam() {
    return widget.examType.toLowerCase().contains('mid');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          'Important Topics',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 22,
            letterSpacing: -0.5,
            color: Colors.grey.shade800,
          ),
        ),
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
          child: _isLoading
              ? Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue.shade600,
                    strokeWidth: 2.5,
                  ),
                )
              : !_documentExists
              ? _buildNoDataView()
              : FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: CustomScrollView(
                      physics: const BouncingScrollPhysics(),
                      slivers: [
                        SliverToBoxAdapter(
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildDetailsCard(),
                                const SizedBox(height: 20),
                                _buildStatsCard(),
                                const SizedBox(height: 20),
                                _buildSectionHeader(),
                              ],
                            ),
                          ),
                        ),
                        SliverPadding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          sliver: SliverList(
                            delegate: SliverChildBuilderDelegate((
                              context,
                              index,
                            ) {
                              final entry = _topics.entries.elementAt(index);
                              return _buildTopicCard(
                                entry.key,
                                entry.value,
                                index + 1,
                              );
                            }, childCount: _topics.length),
                          ),
                        ),
                        const SliverToBoxAdapter(child: SizedBox(height: 24)),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
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
                Icons.search_off_rounded,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'No Topics Found',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ??
                  'No question papers have been uploaded for this combination yet.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 15,
                color: Colors.grey.shade600,
                height: 1.5,
                letterSpacing: 0.2,
              ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded, size: 20),
              label: const Text(
                'Go Back',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
                elevation: 0,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
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
              const SizedBox(width: 12),
              Text(
                'Paper Details',
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
          _buildDetailRow(Icons.school_rounded, 'College', widget.college),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.account_tree_rounded, 'Branch', widget.branch),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.calendar_today_rounded,
            'Semester',
            widget.semester,
          ),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.book_rounded, 'Subject', widget.subject),
          const SizedBox(height: 12),
          _buildDetailRow(
            Icons.assignment_rounded,
            'Exam Type',
            widget.examType,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, size: 18, color: Colors.blue.shade600),
        ),
        const SizedBox(width: 12),
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
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsCard() {
    int totalPapers = _topics.values.fold(0, (sum, count) => sum + count);
    int totalTopics = _topics.length;
    int maxCount = _topics.values.isEmpty
        ? 0
        : _topics.values.reduce((a, b) => a > b ? a : b);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue.shade50.withOpacity(0.5),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.quiz_rounded,
            'Total\nQuestions',
            totalPapers.toString(),
            Colors.blue.shade600,
          ),
          Container(height: 50, width: 1, color: Colors.grey.shade300),
          _buildStatItem(
            Icons.topic_rounded,
            'Unique\nTopics',
            totalTopics.toString(),
            Colors.purple.shade600,
          ),
          Container(height: 50, width: 1, color: Colors.grey.shade300),
          _buildStatItem(
            Icons.trending_up_rounded,
            'Max\nFrequency',
            maxCount.toString(),
            Colors.green.shade600,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w700,
            color: color,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
            height: 1.3,
            letterSpacing: 0.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Top ${_isMiddleExam() ? "10" : "20"} Topics',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade800,
                letterSpacing: -0.3,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Most frequently asked questions',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade500,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: 16,
                color: Colors.blue.shade600,
              ),
              const SizedBox(width: 6),
              Text(
                'Top ${_topics.length}',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue.shade700,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTopicCard(String topic, int count, int rank) {
    int maxCount = _topics.values.reduce((a, b) => a > b ? a : b);
    double percentage = (count / maxCount) * 100;
    Color rankColor;
    IconData rankIcon;
    if (rank <= 3) {
      rankColor = Colors.amber.shade600;
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank <= 5) {
      rankColor = Colors.orange.shade600;
      rankIcon = Icons.star_rounded;
    } else {
      rankColor = Colors.grey.shade500;
      rankIcon = Icons.circle_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: rank <= 3 ? rankColor.withOpacity(0.3) : Colors.grey.shade200,
          width: rank <= 3 ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: rankColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: rankColor.withOpacity(0.4),
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: rank <= 3
                        ? Icon(rankIcon, color: rankColor, size: 20)
                        : Text(
                            '#$rank',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: rankColor,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.grey.shade800,
                          letterSpacing: 0.2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(
                            Icons.bar_chart_rounded,
                            size: 14,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Asked $count ${count == 1 ? "time" : "times"}',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${percentage.toStringAsFixed(0)}%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.blue.shade700,
                      letterSpacing: 0.2,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: percentage / 100,
                minHeight: 6,
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                  rank <= 3 ? rankColor : Colors.blue.shade600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
