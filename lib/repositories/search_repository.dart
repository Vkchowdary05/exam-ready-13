
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:exam_ready/models/question_paper_model.dart';

class SearchRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<QuestionPaper>> searchExamPapers({
    String? college,
    String? branch,
    String? semester,
    String? subject,
    String? examType,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) {
    Query<Map<String, dynamic>> query =
        _firestore.collection('submitted_papers');

    if (college != null && college.isNotEmpty) {
      query = query.where('college', isEqualTo: college);
    }
    if (branch != null && branch.isNotEmpty) {
      query = query.where('branch', isEqualTo: branch);
    }
    if (semester != null && semester.isNotEmpty) {
      query = query.where('semester', isEqualTo: semester);
    }
    if (subject != null && subject.isNotEmpty) {
      query = query.where('subject', isEqualTo: subject);
    }
    if (examType != null && examType.isNotEmpty) {
      query = query.where('exam_type', isEqualTo: examType);
    }

    query = query.orderBy('uploaded_at', descending: true).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => QuestionPaper.fromFirestore(doc))
          .toList();
    });
  }
}
