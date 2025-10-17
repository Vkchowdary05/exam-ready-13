import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloudinary_public/cloudinary_public.dart';
import 'package:exam_ready/models/question_paper_model.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collectionName = 'question_papers';

  late final CloudinaryPublic _cloudinary;

  FirebaseService() {
    _cloudinary = CloudinaryPublic(
      dotenv.env['CLOUDINARY_CLOUD_NAME']!,
      dotenv.env['CLOUDINARY_UPLOAD_PRESET']!,
      cache: false,
    );
  }

  Future<FilterOptions> getFilterOptions() async {
    try {
      final snapshot = await _firestore.collection(_collectionName).get();

      final Set<String> colleges = {};
      final Set<String> branches = {};
      final Set<String> semesters = {};
      final Set<String> subjects = {};
      final Set<String> examTypes = {};

      for (var doc in snapshot.docs) {
        final data = doc.data();

        if (data['college'] != null) colleges.add(data['college']);
        if (data['branch'] != null) branches.add(data['branch']);
        if (data['semester'] != null) semesters.add(data['semester']);
        if (data['subject'] != null) subjects.add(data['subject']);
        if (data['exam_type'] != null) examTypes.add(data['exam_type']);
      }

      return FilterOptions(
        colleges: colleges.toList()..sort(),
        branches: branches.toList()..sort(),
        semesters: semesters.toList()..sort(),
        subjects: subjects.toList()..sort(),
        examTypes: examTypes.toList()..sort(),
      );
    } catch (e) {
      throw Exception('Failed to fetch filter options: $e');
    }
  }

  Future<List<QuestionPaper>> searchQuestionPapers({
    String? college,
    String? branch,
    String? semester,
    String? subject,
    String? examType,
  }) async {
    try {
      Query query = _firestore.collection(_collectionName);

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

      query = query.orderBy('uploaded_at', descending: true).limit(100);

      final snapshot = await query.get();

      return snapshot.docs
          .map((doc) => QuestionPaper.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Search failed: $e');
    }
  }

  Future<QuestionPaper?> getPaperById(String paperId) async {
    try {
      final doc = await _firestore.collection(_collectionName).doc(paperId).get();

      if (doc.exists) {
        return QuestionPaper.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to fetch paper: $e');
    }
  }

  Future<String> uploadPaper({
    required String college,
    required String branch,
    required String semester,
    required String subject,
    required String examType,
    required String imagePath,
  }) async {
    try {
      final response = await _cloudinary.uploadFile(
        CloudinaryFile.fromFile(
          imagePath,
          folder: 'question_papers',
          resourceType: CloudinaryResourceType.Image,
        ),
      );

      final docRef = await _firestore.collection(_collectionName).add({
        'college': college,
        'branch': branch,
        'semester': semester,
        'subject': subject,
        'exam_type': examType,
        'image_url': response.secureUrl,
        'uploaded_at': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      throw Exception('Failed to upload paper: $e');
    }
  }

  Stream<List<QuestionPaper>> streamPapers({
    String? college,
    String? branch,
    String? semester,
  }) {
    Query query = _firestore.collection(_collectionName);

    if (college != null) query = query.where('college', isEqualTo: college);
    if (branch != null) query = query.where('branch', isEqualTo: branch);
    if (semester != null) query = query.where('semester', isEqualTo: semester);

    query = query.orderBy('uploaded_at', descending: true).limit(50);

    return query.snapshots().map((snapshot) {
      return snapshot.docs
          .map((doc) => QuestionPaper.fromFirestore(doc))
          .toList();
    });
  }
}
