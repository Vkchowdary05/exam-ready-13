// lib/screens/ui/topics_detail_page.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';

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

  // =========================
  // AI STUDY PROMPT BUILDER
  // =========================
  String _buildAiStudyPrompt() {
    final isMidExam = widget.examType.toLowerCase().contains('mid');

    // Marks and word ranges
    final int marksPerQuestion = isMidExam ? 5 : 10;
    final int minWords = isMidExam ? 400 : 600;
    final int maxWords = isMidExam ? 500 : 700;

    final topicsList = _topics.keys.toList();

    if (topicsList.isEmpty) {
      final fallback = {
        "version": "1.0",
        "type": "exam_study_prompt",
        "note":
            "No topics were provided. Ask the user to paste or provide a list of topics first, then generate exam-focused answers.",
      };
      return jsonEncode(fallback);
    }

    final prompt = {
      "version": "2.0",
      "type": "exam_study_prompt",
      "description":
          "JSON prompt for an AI tutor to generate structured, exam-focused answers with images and explanations.",
      "exam_context": {
        "college": widget.college,
        "branch": widget.branch,
        "semester": widget.semester,
        "subject": widget.subject,
        "exam_type": widget.examType,
        "marks_per_question": marksPerQuestion,
        "word_range_per_answer": {"min": minWords, "max": maxWords},
        "expected_topic_count": topicsList.length,
      },
      "role_instructions": {
        "role":
            "You are an expert B.Tech tutor helping a student prepare for their exam.",
        "audience_level":
            "Average B.Tech student who needs clear, exam-oriented explanations.",
        "main_goal":
            "For EACH topic, generate a full-mark, exam-ready answer with simple language, strong structure, and visual explanation.",
      },
      "answer_style": {
        "language": "Simple, clear English – no unnecessary jargon.",
        "tone": "Supportive, teacher-like, exam-focused.",
        "depth":
            "Explain deeply enough to justify full marks for a {marks_per_question}-mark answer within the given word range.",
        "structure_per_topic": [
          "Heading: 'Q{n}. {TOPIC_NAME}'",
          "Definition or short introduction",
          "Detailed explanation with key points (bullets or numbered steps when useful)",
          "Google image search & visual explanation (see image_guidelines)",
          "Simple real-world example or scenario",
          "Short summary / key takeaway points",
        ],
        "word_range_hint":
            "Each answer should be between $minWords and $maxWords words. Do not go significantly below the minimum.",
      },
      "image_guidelines": {
        "goal":
            "Use web images (e.g., from Google Images or similar) to visually explain concepts, then describe and connect them to the topic.",
        "instructions": [
          "For EACH topic, if you have access to the open internet or image search tools (e.g., Google Images, web_with_bing, or similar), search for 1–2 simple, relevant images.",
          "Choose images that make the concept easier to understand (e.g., architectures, diagrams, flow charts, tables).",
          "DO NOT just give the image URL; instead, describe the image clearly in text.",
          "Explain what is shown in the image and how it relates to the topic step by step.",
          "If you DO NOT have access to the internet or image tools, create a simple imaginary diagram and describe it as if it were an image.",
          "Use a small XML-like structure to represent the diagram or image contents, for example:",
          "<diagram name=\"CLIENT_SERVER_ARCHITECTURE\">\\n  <node role=\"client\" />\\n  <node role=\"application_server\" />\\n  <node role=\"database_server\" />\\n</diagram>",
          "Keep XML diagrams short, readable, and focused on key components only.",
        ],
      },
      "per_topic_answer_template": {
        "heading_example": "Q1. TOPIC NAME",
        "sections": [
          {
            "name": "definition",
            "description":
                "1–3 sentences that define the topic and set context in simple words.",
          },
          {
            "name": "explanation",
            "description":
                "Main body: key points, subheadings, bullet lists, comparisons, pros/cons, steps, etc.",
          },
          {
            "name": "image_or_diagram_explanation",
            "description":
                "If image search is available, imagine you have opened 1–2 Google images for this topic. Describe what those images show and how they explain the concept. If no real image search is available, create a simple XML-style pseudo-diagram and explain it in text.",
          },
          {
            "name": "example",
            "description":
                "A very simple, concrete example or use case: code snippet, real-world scenario, or short story that grounds the concept.",
          },
          {
            "name": "summary",
            "description":
                "2–4 bullet points summarizing the main ideas that should be remembered for the exam.",
          },
        ],
      },
      "output_requirements": {
        "topic_order":
            "Answer ALL topics in the same order as they appear in the list below.",
        "naming":
            "For each topic, use a heading like 'Q{n}. {TOPIC_NAME}' as a title.",
        "coverage":
            "Do NOT skip any topic. Generate answers for every topic provided.",
        "formatting":
            "Use clear headings, subheadings, and bullet lists for readability.",
        "consistency":
            "Apply the same structure to every topic, adapting where necessary.",
      },
      "topics": List.generate(
        topicsList.length,
        (index) => {"number": index + 1, "title": topicsList[index]},
      ),
      "final_instruction":
          "Now, using all the information above, generate the answers for ALL topics in 'topics' in order (Q1, Q2, Q3, ...). For each topic, follow the structure, word range, and image/diagram explanation rules strictly.",
    };

    return jsonEncode(prompt);
  }

  Widget _buildAiStudyHelperCard() {
    final isMidExam = widget.examType.toLowerCase().contains('mid');

    final int marksPerQuestion = isMidExam ? 5 : 10;
    final String targetWords = isMidExam ? '400–500' : '600–700';

    final int topicsCount = _topics.length;
    final bool hasTopics = topicsCount > 0;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.indigo.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.indigo.shade100),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.indigo.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.smart_toy_outlined,
                  color: Colors.indigo.shade700,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Study Helper',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey.shade900,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasTopics
                          ? 'Copy a powerful JSON-based AI prompt to generate detailed exam answers for all $topicsCount topics. '
                              '\n• ${marksPerQuestion}-mark answers (${targetWords} words each)'
                              '\n• Includes Google image explanation instructions'
                              '\n• Works with ChatGPT, Claude, Gemini, Groq, etc.'
                          : 'Topics are not available yet. Once topics appear, you can copy a ready-made JSON AI prompt for this paper.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade700,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton.icon(
              onPressed: hasTopics
                  ? () {
                      final prompt = _buildAiStudyPrompt();
                      Clipboard.setData(ClipboardData(text: prompt));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("JSON AI study prompt copied"),
                          behavior: SnackBarBehavior.floating,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    }
                  : null,
              icon: const Icon(Icons.copy_rounded, size: 18),
              label: const Text(
                'Copy JSON Prompt',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 12,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // =========================
  // RESPONSIVE BUILD
  // =========================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        centerTitle: false,
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
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double width = constraints.maxWidth;

              // Simple breakpoint strategy
              final bool isDesktop = width >= 1024;
              final bool isTablet = width >= 600 && width < 1024;
              final bool useGridForTopics = isDesktop; // grid on big screens

              // Constrain content width on larger screens for a relaxed feel
              final double maxContentWidth = isDesktop
                  ? 900
                  : isTablet
                      ? 720
                      : width;

              // Softer padding on mobile, a bit more breathing room on big screens
              final double horizontalPadding = isDesktop
                  ? 32
                  : isTablet
                      ? 24
                      : 16;

              if (_isLoading) {
                return Center(
                  child: CircularProgressIndicator(
                    color: Colors.blue.shade600,
                    strokeWidth: 2.5,
                  ),
                );
              }

              return Align(
                alignment: Alignment.topCenter,
                child: ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxContentWidth),
                  child: _documentExists
                      ? FadeTransition(
                          opacity: _fadeAnimation,
                          child: SlideTransition(
                            position: _slideAnimation,
                            child: _buildMainScrollView(
                              horizontalPadding: horizontalPadding,
                              useGridForTopics: useGridForTopics,
                            ),
                          ),
                        )
                      : Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: horizontalPadding,
                            vertical: 24,
                          ),
                          child: _buildNoDataView(),
                        ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildMainScrollView({
    required double horizontalPadding,
    required bool useGridForTopics,
  }) {
    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              16,
              horizontalPadding,
              16,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDetailsCard(),
                const SizedBox(height: 20),
                _buildStatsCard(),
                const SizedBox(height: 20),
                _buildAiStudyHelperCard(),
                const SizedBox(height: 20),
                _buildSectionHeader(),
              ],
            ),
          ),
        ),
        if (useGridForTopics)
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
            sliver: SliverGrid(
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
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 3.2,
              ),
            ),
          )
        else
          SliverPadding(
            padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
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
        const SliverToBoxAdapter(child: SizedBox(height: 24)),
      ],
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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final bool isNarrow = constraints.maxWidth < 360;
          if (isNarrow) {
            // Stack vertically on very small screens to avoid feeling cramped
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildStatItem(
                  Icons.quiz_rounded,
                  'Total\nQuestions',
                  totalPapers.toString(),
                  Colors.blue.shade600,
                ),
                const SizedBox(height: 12),
                _buildStatItem(
                  Icons.topic_rounded,
                  'Unique\nTopics',
                  totalTopics.toString(),
                  Colors.purple.shade600,
                ),
                const SizedBox(height: 12),
                _buildStatItem(
                  Icons.trending_up_rounded,
                  'Max\nFrequency',
                  maxCount.toString(),
                  Colors.green.shade600,
                ),
              ],
            );
          }
          return Row(
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
          );
        },
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
