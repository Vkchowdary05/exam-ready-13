
import 'package:exam_ready/repositories/search_repository.dart';
import 'package:exam_ready/screens/ui/search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

class MockSearchRepository extends Mock implements SearchRepository {}

void main() {
  group('SearchQuestionPaperPage', () {
    late MockSearchRepository mockSearchRepository;

    setUp(() {
      mockSearchRepository = MockSearchRepository();
    });

    testWidgets('should call searchExamPapers when a filter is changed', (WidgetTester tester) async {
      // Override the provider with the mock repository
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            searchRepositoryProvider.overrideWithValue(mockSearchRepository),
          ],
          child: const MaterialApp(
            home: SearchQuestionPaperPage(),
          ),
        ),
      );

      // Stub the searchExamPapers method to return an empty stream
      when(mockSearchRepository.searchExamPapers(
        college: anyNamed('college'),
        branch: anyNamed('branch'),
        semester: anyNamed('semester'),
        subject: anyNamed('subject'),
        examType: anyNamed('examType'),
      )).thenAnswer((_) => Stream.value([]));

      // Open the college dropdown
      await tester.tap(find.text('College'));
      await tester.pumpAndSettle();

      // Select a college
      await tester.tap(find.text('IIT Hyderabad').last);
      await tester.pumpAndSettle();

      // Verify that searchExamPapers was called with the correct college
      verify(mockSearchRepository.searchExamPapers(
        college: 'IIT Hyderabad',
      )).called(1);
    });
  });
}
