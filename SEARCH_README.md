
## Search Functionality

The search functionality allows users to find exam papers based on various filters. The search is performed in real-time and supports pagination.

### Dropdown Data

The dropdown options for the filters are located in `lib/data/dropdown_data.dart`. To add or remove options, simply modify the following data structures in this file:

- `collegeData`: A map of colleges to their respective branches.
- `subjectData`: A nested map of branches to semesters to subjects.
- `semesters`: A list of semesters.
- `examTypes`: A list of exam types.

### Search Query and Indexing

The search query is built dynamically in `lib/repositories/search_repository.dart`. The `searchExamPapers` method constructs a Firestore query based on the selected filters.

To ensure the performance of the search queries, you may need to create composite indexes in Firestore. If a query requires an index, Firestore will provide a link in the error message to create it automatically. Alternatively, you can create the indexes manually using the `gcloud` command-line tool. Here are some examples of indexes you might need:

```bash
gcloud firestore indexes composite create --collection-group=submitted_papers --field-configurations='[{"fieldPath":"college","order":"ASCENDING"},{"fieldPath":"uploaded_at","order":"DESCENDING"}]'
gcloud firestore indexes composite create --collection-group=submitted_papers --field-configurations='[{"fieldPath":"college","order":"ASCENDING"},{"fieldPath":"branch","order":"ASCENDING"},{"fieldPath":"uploaded_at","order":"DESCENDING"}]'
gcloud firestore indexes composite create --collection-group=submitted_papers --field-configurations='[{"fieldPath":"college","order":"ASCENDING"},{"fieldPath":"branch","order":"ASCENDING"},{"fieldPath":"semester","order":"ASCENDING"},{"fieldPath":"uploaded_at","order":"DESCENDING"}]'
gcloud firestore indexes composite create --collection-group=submitted_papers --field-configurations='[{"fieldPath":"college","order":"ASCENDING"},{"fieldPath":"branch","order":"ASCENDING"},{"fieldPath":"semester","order":"ASCENDING"},{"fieldPath":"subject","order":"ASCENDING"},{"fieldPath":"uploaded_at","order":"DESCENDING"}]'
```

### Testing

The search functionality is tested with both unit and widget tests.

- **Unit Tests**: The unit tests for the `SearchRepository` are located in `test/search_repository_test.dart`. These tests use the `fake_cloud_firestore` package to mock Firestore and verify that the queries are built correctly.

- **Widget Tests**: The widget tests for the `SearchQuestionPaperPage` are located in `test/search_page_widget_test.dart`. These tests use the `mockito` package to mock the `SearchRepository` and verify that the UI behaves as expected.

To run the tests, use the following command:

```bash
flutter test
```

### Seeding the Emulator for Integration Tests

For integration testing, it is recommended to use the Firebase Emulator Suite. You can seed the emulator with sample data to test the search functionality in a local environment.

1.  Install the Firebase CLI and set up the Firebase Emulator Suite.
2.  Create a script to populate the `submitted_papers` collection in the emulator. You can use the Firebase Admin SDK for this.
3.  Run the emulator and your app, and verify that the search results are correct.
