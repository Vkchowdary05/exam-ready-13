import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

// Model class for Question Paper
class QuestionPaper {
  final String id;
  final String college;
  final String branch;
  final String semester;
  final String subject;
  final String examType;
  final String imageUrl;
  final DateTime uploadedAt;
  final String userName;
  final String userId;

  QuestionPaper({
    required this.id,
    required this.college,
    required this.branch,
    required this.semester,
    required this.subject,
    required this.examType,
    required this.imageUrl,
    required this.uploadedAt,
    required this.userName,
    required this.userId,
  });

  factory QuestionPaper.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return QuestionPaper(
      id: doc.id,
      college: data['college'] ?? '',
      branch: data['branch'] ?? '',
      semester: data['semester'] ?? '',
      subject: data['subject'] ?? '',
      examType: data['examType'] ?? '',
      imageUrl: data['imageUrl'] ?? '',
      uploadedAt:
          (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      userName: data['userName'] ?? '',
      userId: data['userId'] ?? '',
    );
  }
}

class MySubmittedPapersPage extends StatefulWidget {
  const MySubmittedPapersPage({Key? key}) : super(key: key);

  @override
  State<MySubmittedPapersPage> createState() => _MySubmittedPapersPageState();
}

class _MySubmittedPapersPageState extends State<MySubmittedPapersPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<List<QuestionPaper>> _fetchSubmittedPapers() async {
    try {
      // Step 1: Get current user ID
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        throw Exception('User not logged in');
      }

      // Step 2: Fetch list of paper IDs from user's subcollection
      final submittedPapersSnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('submitted_papers')
          .get();

      if (submittedPapersSnapshot.docs.isEmpty) {
        return [];
      }

      // Step 3 & 4: Extract paperIds and fetch actual papers
      final List<QuestionPaper> papers = [];

      for (final doc in submittedPapersSnapshot.docs) {
        final paperId = doc.data()['paperId'] as String?;

        if (paperId != null && paperId.isNotEmpty) {
          try {
            // Fetch the actual paper document from submitted_papers collection
            final paperDoc = await _firestore
                .collection('submitted_papers')
                .doc(paperId)
                .get();

            if (paperDoc.exists) {
              papers.add(QuestionPaper.fromFirestore(paperDoc));
            }
          } catch (e) {
            // ignore single-item errors but log them
            // (keeps UX relaxed even if one paper fails)
            // ignore: avoid_print
            print('Error fetching paper $paperId: $e');
          }
        }
      }

      // Sort by upload date (newest first)
      papers.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

      return papers;
    } catch (e) {
      // ignore: avoid_print
      print('Error fetching submitted papers: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'My Submitted Papers',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
          ),
        ),
        centerTitle: false,
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
          child: FutureBuilder<List<QuestionPaper>>(
            future: _fetchSubmittedPapers(),
            builder: (context, snapshot) {
              // Loading state
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(height: 16),
                      Text(
                        'Loading your papers...',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                    ],
                  ),
                );
              }

              // Error state
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          size: 64,
                          color: Colors.red.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Failed to load papers',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          snapshot.error.toString(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            setState(() {});
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Retry'),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 12,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final papers = snapshot.data ?? [];

              // Empty state
              if (papers.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.note_add_outlined,
                          size: 80,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Submitted Papers',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Upload a paper to see it here.',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey.shade600,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Data state - responsive grid/list with centered content on large screens
              return LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final bool isSmallScreen = width < 600;
                  final bool isTablet = width >= 600 && width < 1024;
                  final int crossAxisCount =
                      isSmallScreen ? 1 : (isTablet ? 2 : 3);

                  // Limit max width on big screens for a relaxed layout
                  final double maxContentWidth = isSmallScreen
                      ? width
                      : isTablet
                          ? 900
                          : 1100;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: maxContentWidth),
                      child: RefreshIndicator(
                        onRefresh: () async {
                          setState(() {});
                        },
                        child: GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: crossAxisCount,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio:
                                isSmallScreen ? 0.9 : (isTablet ? 1.2 : 1.3),
                          ),
                          itemCount: papers.length,
                          itemBuilder: (context, index) {
                            return _PaperCard(paper: papers[index]);
                          },
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _PaperCard extends StatelessWidget {
  final QuestionPaper paper;

  const _PaperCard({Key? key, required this.paper}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.06),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaperDetailsPage(paperId: paper.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: CachedNetworkImage(
                imageUrl: paper.imageUrl,
                width: double.infinity,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: Colors.grey[300]!,
                  highlightColor: Colors.grey[100]!,
                  child: Container(
                    color: Colors.white,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: Colors.grey[200],
                  child: const Center(
                    child: Icon(
                      Icons.broken_image_outlined,
                      size: 48,
                      color: Colors.grey,
                    ),
                  ),
                ),
              ),
            ),
            // Details section
            Expanded(
              flex: 2,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12.0, vertical: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          paper.subject,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${paper.college} • ${paper.semester}',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          paper.branch,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[500],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text(
                            paper.examType,
                            style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Colors.blue[50],
                          labelPadding:
                              const EdgeInsets.symmetric(horizontal: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        Text(
                          DateFormat('MMM d, y').format(paper.uploadedAt),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey[500],
                          ),
                        ),
                      ],
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
}

// Paper Details Page
class PaperDetailsPage extends StatelessWidget {
  final String paperId;

  const PaperDetailsPage({Key? key, required this.paperId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0.5,
        title: const Text(
          'Paper Details',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 20,
            letterSpacing: -0.3,
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
          child: FutureBuilder<DocumentSnapshot>(
            future: FirebaseFirestore.instance
                .collection('submitted_papers')
                .doc(paperId)
                .get(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError ||
                  !snapshot.hasData ||
                  !snapshot.data!.exists) {
                return const Center(
                  child: Text('Failed to load paper details'),
                );
              }

              final paper = QuestionPaper.fromFirestore(snapshot.data!);

              return LayoutBuilder(
                builder: (context, constraints) {
                  final double width = constraints.maxWidth;
                  final bool isWide = width >= 900;
                  final double maxContentWidth = isWide ? 900 : width;

                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints:
                          BoxConstraints(maxWidth: maxContentWidth),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.only(bottom: 24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // Full image with relaxed padding on wide screens
                            Padding(
                              padding: EdgeInsets.all(isWide ? 16 : 0),
                              child: ClipRRect(
                                borderRadius: BorderRadius.only(
                                  bottomLeft: Radius.circular(isWide ? 18 : 0),
                                  bottomRight:
                                      Radius.circular(isWide ? 18 : 0),
                                ),
                                child: CachedNetworkImage(
                                  imageUrl: paper.imageUrl,
                                  width: double.infinity,
                                  fit: BoxFit.contain,
                                  placeholder: (context, url) =>
                                      AspectRatio(
                                    aspectRatio: 1,
                                    child: Shimmer.fromColors(
                                      baseColor: Colors.grey[300]!,
                                      highlightColor: Colors.grey[100]!,
                                      child:
                                          Container(color: Colors.white),
                                    ),
                                  ),
                                  errorWidget: (context, url, error) =>
                                      Container(
                                    height: 300,
                                    color: Colors.grey[200],
                                    child: const Center(
                                      child: Icon(Icons.broken_image,
                                          size: 64),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            // Metadata inside a modern card
                            Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: isWide ? 16 : 12,
                                vertical: 16,
                              ),
                              child: Card(
                                elevation: 3,
                                shadowColor:
                                    Colors.black.withOpacity(0.05),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        paper.subject,
                                        style: const TextStyle(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        '${paper.college} • ${paper.branch} • ${paper.semester}',
                                        style: TextStyle(
                                          fontSize: 13,
                                          color: Colors.grey.shade600,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Wrap(
                                        spacing: 8,
                                        runSpacing: 8,
                                        children: [
                                          Chip(
                                            label: Text(
                                              paper.examType,
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            backgroundColor:
                                                Colors.blue.shade50,
                                          ),
                                          Chip(
                                            label: Text(
                                              'Uploaded: ${DateFormat('MMM d, y').format(paper.uploadedAt)}',
                                              style:
                                                  const TextStyle(fontSize: 12),
                                            ),
                                            backgroundColor:
                                                Colors.grey.shade100,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      _DetailRow(
                                        label: 'College',
                                        value: paper.college,
                                      ),
                                      _DetailRow(
                                        label: 'Branch',
                                        value: paper.branch,
                                      ),
                                      _DetailRow(
                                        label: 'Semester',
                                        value: paper.semester,
                                      ),
                                      _DetailRow(
                                        label: 'Exam Type',
                                        value: paper.examType,
                                      ),
                                      _DetailRow(
                                        label: 'Uploaded',
                                        value: DateFormat(
                                                'MMMM d, y - h:mm a')
                                            .format(paper.uploadedAt),
                                      ),
                                      _DetailRow(
                                        label: 'Uploaded By',
                                        value: paper.userName,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({Key? key, required this.label, required this.value})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
