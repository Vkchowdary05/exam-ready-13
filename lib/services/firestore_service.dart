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
}