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
      uploadedAt: (data['uploadedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
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
            print('Error fetching paper $paperId: $e');
          }
        }
      }

      // Sort by upload date (newest first)
      papers.sort((a, b) => b.uploadedAt.compareTo(a.uploadedAt));

      return papers;
    } catch (e) {
      print('Error fetching submitted papers: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Submitted Papers'),
        elevation: 2,
      ),
      body: FutureBuilder<List<QuestionPaper>>(
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
                    const Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red,
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(
                    Icons.note_add_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No Submitted Papers',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Upload a paper to see it here',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          // Data state - responsive grid/list
          return LayoutBuilder(
            builder: (context, constraints) {
              final isSmallScreen = constraints.maxWidth < 600;
              final crossAxisCount = isSmallScreen ? 1 : (constraints.maxWidth < 900 ? 2 : 3);

              return RefreshIndicator(
                onRefresh: () async {
                  setState(() {});
                },
                child: GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: isSmallScreen ? 1.2 : 0.9,
                  ),
                  itemCount: papers.length,
                  itemBuilder: (context, index) {
                    return _PaperCard(paper: papers[index]);
                  },
                ),
              );
            },
          );
        },
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
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PaperDetailsPage(paperId: paper.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image section
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
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
            ),
            // Details section
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
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
                            fontWeight: FontWeight.bold,
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
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Chip(
                          label: Text(
                            paper.examType,
                            style: const TextStyle(fontSize: 11),
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Colors.blue[50],
                          labelPadding: const EdgeInsets.symmetric(horizontal: 8),
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
      appBar: AppBar(
        title: const Text('Paper Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('submitted_papers')
            .doc(paperId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData || !snapshot.data!.exists) {
            return const Center(
              child: Text('Failed to load paper details'),
            );
          }

          final paper = QuestionPaper.fromFirestore(snapshot.data!);

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Full image
                CachedNetworkImage(
                  imageUrl: paper.imageUrl,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  placeholder: (context, url) => AspectRatio(
                    aspectRatio: 1,
                    child: Shimmer.fromColors(
                      baseColor: Colors.grey[300]!,
                      highlightColor: Colors.grey[100]!,
                      child: Container(color: Colors.white),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    height: 300,
                    color: Colors.grey[200],
                    child: const Center(
                      child: Icon(Icons.broken_image, size: 64),
                    ),
                  ),
                ),
                // Metadata
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paper.subject,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _DetailRow(label: 'College', value: paper.college),
                      _DetailRow(label: 'Branch', value: paper.branch),
                      _DetailRow(label: 'Semester', value: paper.semester),
                      _DetailRow(label: 'Exam Type', value: paper.examType),
                      _DetailRow(
                        label: 'Uploaded',
                        value: DateFormat('MMMM d, y - h:mm a').format(paper.uploadedAt),
                      ),
                      _DetailRow(label: 'Uploaded By', value: paper.userName),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
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
      padding: const EdgeInsets.only(bottom: 12.0),
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
              style: const TextStyle(fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }
}