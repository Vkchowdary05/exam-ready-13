// lib/screens/ui/topics_detail_page.dart
import 'dart:ui';
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
    Key? key,
    required this.documentName,
    required this.college,
    required this.branch,
    required this.semester,
    required this.subject,
    required this.examType,
  }) : super(key: key);

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
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
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

        // Remove metadata fields and extract topics
        Map<String, int> topicsMap = {};
        data.forEach((key, value) {
          if (key != 'createdAt' &&
              key != 'updatedAt' &&
              key != 'lastModified' &&
              value is int) {
            topicsMap[key] = value;
          }
        });

        // Sort by count (descending)
        var sortedEntries = topicsMap.entries.toList()
          ..sort((a, b) => b.value.compareTo(a.value));

        // Get top topics based on exam type
        int topCount = _isMiddleExam() ? 10 : 20;
        var topTopics = Map.fromEntries(
          sortedEntries.take(topCount),
        );

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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Important Topics',
          style: TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 24,
            letterSpacing: -0.5,
          ),
        ),
      ),
      body: Stack(
        children: [
          // Background gradient
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
            child: _isLoading
                ? const Center(
                    child: CircularProgressIndicator(),
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
                                      const SizedBox(height: 24),
                                      _buildStatsCard(),
                                      const SizedBox(height: 24),
                                      _buildSectionHeader(),
                                    ],
                                  ),
                                ),
                              ),
                              SliverPadding(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) {
                                      final entry = _topics.entries.elementAt(index);
                                      return _buildTopicCard(
                                        entry.key,
                                        entry.value,
                                        index + 1,
                                      );
                                    },
                                    childCount: _topics.length,
                                  ),
                                ),
                              ),
                              const SliverToBoxAdapter(
                                child: SizedBox(height: 24),
                              ),
                            ],
                          ),
                        ),
                      ),
          ),
        ],
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
            Icon(
              Icons.search_off_rounded,
              size: 100,
              color: Colors.grey.shade300,
            ),
            const SizedBox(height: 24),
            Text(
              'No Topics Found',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
            ),
            const SizedBox(height: 12),
            Text(
              _errorMessage ?? 'No question papers have been uploaded for this combination yet.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Go Back'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsCard() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.white.withOpacity(0.4),
                Colors.white.withOpacity(0.15),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.description_rounded,
                    color: Theme.of(context).colorScheme.primary,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Paper Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontSize: 20,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildDetailRow(Icons.school_rounded, 'College', widget.college),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.account_tree_rounded, 'Branch', widget.branch),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.calendar_today_rounded, 'Semester', widget.semester),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.book_rounded, 'Subject', widget.subject),
              const SizedBox(height: 12),
              _buildDetailRow(Icons.assignment_rounded, 'Exam Type', widget.examType),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 18,
            color: Theme.of(context).colorScheme.primary,
          ),
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
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
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
    int maxCount = _topics.values.isEmpty ? 0 : _topics.values.reduce((a, b) => a > b ? a : b);

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Theme.of(context).colorScheme.primary.withOpacity(0.15),
                Theme.of(context).colorScheme.secondary.withOpacity(0.1),
              ],
            ),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.3),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                Icons.quiz_rounded,
                'Total\nQuestions',
                totalPapers.toString(),
                Colors.blue,
              ),
              Container(
                height: 50,
                width: 1,
                color: Colors.grey.shade300,
              ),
              _buildStatItem(
                Icons.topic_rounded,
                'Unique\nTopics',
                totalTopics.toString(),
                Colors.purple,
              ),
              Container(
                height: 50,
                width: 1,
                color: Colors.grey.shade300,
              ),
              _buildStatItem(
                Icons.trending_up_rounded,
                'Max\nFrequency',
                maxCount.toString(),
                Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(height: 8),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade700,
            fontWeight: FontWeight.w500,
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
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              'Most frequently asked questions',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                Icons.emoji_events_rounded,
                size: 16,
                color: Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Text(
                'Top ${_topics.length}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
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
      rankColor = const Color(0xFFFFD700); // Gold
      rankIcon = Icons.emoji_events_rounded;
    } else if (rank <= 5) {
      rankColor = const Color(0xFFC0C0C0); // Silver
      rankIcon = Icons.star_rounded;
    } else {
      rankColor = Colors.grey.shade400;
      rankIcon = Icons.circle_rounded;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.white.withOpacity(0.4),
                  Colors.white.withOpacity(0.2),
                ],
              ),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: rank <= 3
                    ? rankColor.withOpacity(0.5)
                    : Colors.white.withOpacity(0.3),
                width: rank <= 3 ? 2 : 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 15,
                  offset: const Offset(0, 5),
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
                          color: rankColor.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: rankColor,
                            width: 2,
                          ),
                        ),
                        child: Center(
                          child: rank <= 3
                              ? Icon(rankIcon, color: rankColor, size: 20)
                              : Text(
                                  '#$rank',
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: rankColor,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              topic,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(
                                  Icons.bar_chart_rounded,
                                  size: 16,
                                  color: Theme.of(context).colorScheme.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  'Asked $count ${count == 1 ? "time" : "times"}',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey.shade700,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Theme.of(context)
                              .colorScheme
                              .primary
                              .withOpacity(0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          '${percentage.toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.primary,
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
                      minHeight: 8,
                      backgroundColor: Colors.grey.shade200,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        rank <= 3
                            ? rankColor
                            : Theme.of(context).colorScheme.primary,
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
}