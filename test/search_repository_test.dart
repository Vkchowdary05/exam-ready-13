import 'package:exam_ready/models/question_paper_model.dart';
import 'package:exam_ready/repositories/search_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

void main() {
  group('SearchRepository', () {
    late FakeFirebaseFirestore fakeFirestore;
    late SearchRepository searchRepository;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      searchRepository = SearchRepository();
    });

    test('searchExamPapers returns filtered results', () async {
      // Add mock data to the fake Firestore instance
      await fakeFirestore.collection('submitted_papers').add({
        'college': 'IIT Hyderabad',
        'branch': 'CSE',
        'semester': 'Sem 1',
        'subject': 'Engineering Mathematics-I',
        'exam_type': 'Mid-1',
        'uploaded_at': DateTime.now(),
        'image_url': '',
        'pdf_url': '',
        'year': '2023',
        'status': 'approved',
        'views': 0,
        'downloads': 0,
      });

      await fakeFirestore.collection('submitted_papers').add({
        'college': 'NIT Warangal',
        'branch': 'ECE',
        'semester': 'Sem 2',
        'subject': 'Network Analysis',
        'exam_type': 'Mid-2',
        'uploaded_at': DateTime.now(),
        'image_url': '',
        'pdf_url': '',
        'year': '2023',
        'status': 'approved',
        'views': 0,
        'downloads': 0,
      });

      // Search for papers with a specific filter
      final stream = searchRepository.searchExamPapers(
        college: 'IIT Hyderabad',
      );

      // Expect that the stream emits a list containing the matching paper
      expect(
        stream,
        emits(
          isA<List<QuestionPaper>>().having((list) => list.length, 'length', 1),
        ),
      );
    });
  });
}
