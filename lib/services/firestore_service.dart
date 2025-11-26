import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> submitQuestionPaper({
    required String college,
    required String branch,
    required String semester,
    required String subject,
    required String examType,
    required String imageUrl,
  }) async {
    await _firestore.collection('submitted_papers').add({
      'college': college,
      'branch': branch,
      'semester': semester,
      'subject': subject,
      'exam_type': examType,
      'image_url': imageUrl, // Cloudinary URL
      'uploaded_at': FieldValue.serverTimestamp(),
      'status': 'pending', // For admin review
    });
  }

  // Compatibility wrappers used by UI code
  Future<void> submitToSubmittedPapers({
    required String college,
    required String branch,
    required String semester,
    required String subject,
    required String examType,
    required String imageUrl,
  }) async {
    return submitQuestionPaper(
      college: college,
      branch: branch,
      semester: semester,
      subject: subject,
      examType: examType,
      imageUrl: imageUrl,
    );
  }

  Future<void> submitToQuestionPapers({
    required String college,
    required String branch,
    required String semester,
    required String subject,
    required String examType,
    required List<String> topics,
  }) async {
    final doc = {
      'college': college,
      'branch': branch,
      'semester': semester,
      'subject': subject,
      'exam_type': examType,
      'topics': topics,
      'created_at': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('question_papers').add(doc);
  }

  /// Update topic frequency counts in `questions` collection.
  /// The `documentName` parameter is used as the document id under `questions`.
  /// This method writes topic entries in the form:
  ///   "TOPIC NAME": { "display": "TOPIC NAME\n<count>\n(number)", "count": <count> }
  /// and timestamps:
  ///   createdAt  -> human-readable IST (preserved if already present)
  ///   lastModified -> ISO 8601 UTC string
  ///   updatedAt -> human-readable IST
  Future<void> updateQuestionsCollection({
    required String documentName,
    required List<String> topics,
  }) async {
    final DocumentReference docRef = _firestore
        .collection('questions')
        .doc(documentName);

    // 1) Compute frequencies from the topics list (preserve original casing)
    final Map<String, int> freq = {};
    for (final t in topics) {
      final key = t.trim();
      if (key.isEmpty) continue;
      freq[key] = (freq[key] ?? 0) + 1;
    }

    // 2) Prepare timestamps
    final DateTime nowUtc = DateTime.now().toUtc();
    final DateTime nowIst = nowUtc.add(const Duration(hours: 5, minutes: 30));
    final String lastModifiedIso = nowUtc.toIso8601String();
    final String humanIst = _formatHumanReadableIST(nowIst);

    // 3) Run transaction: if doc exists -> increment each topic field by freq
    //    if doc doesn't exist -> create with counts and createdAt/updatedAt/lastModified
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);

      if (snapshot.exists) {
        // Build increment map
        final Map<String, dynamic> increments = {};
        for (final entry in freq.entries) {
          // Use the topic string as a top-level field name
          increments[entry.key] = FieldValue.increment(entry.value);
        }

        // Ensure we also update lastModified and updatedAt (human-readable)
        increments['lastModified'] = lastModifiedIso;
        increments['updatedAt'] = humanIst;

        transaction.update(docRef, increments);
      } else {
        // Document doesn't exist: build initial map with counts
        final Map<String, dynamic> initial = {};
        for (final entry in freq.entries) {
          initial[entry.key] = entry.value;
        }

        // set createdAt (human-readable IST), lastModified (iso UTC), updatedAt (human-readable)
        initial['createdAt'] = humanIst;
        initial['lastModified'] = lastModifiedIso;
        initial['updatedAt'] = humanIst;

        transaction.set(docRef, initial);
      }
    });
  }

  /// Helper to format IST human-readable as in your screenshot:
  /// "24 November 2025 at 23:24:59 UTC+5:30"
  String _formatHumanReadableIST(DateTime dt) {
    final months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];
    final day = dt.day.toString().padLeft(2, '0');
    final month = months[dt.month - 1];
    final year = dt.year;
    final hour = dt.hour.toString().padLeft(2, '0');
    final minute = dt.minute.toString().padLeft(2, '0');
    final second = dt.second.toString().padLeft(2, '0');

    return '$day $month $year at $hour:$minute:$second UTC+5:30';
  }
}
