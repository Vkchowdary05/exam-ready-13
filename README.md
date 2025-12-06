# Exam Ready 📚✨

![Build Status](https://img.shields.io/github/actions/workflow/status/{your-github-username}/{your-repo-name}/main.yml?branch=main)
![License](https://img.shields.io/github/license/{your-github-username}/{your-repo-name})
![Latest Release](https://img.shields.io/github/v/release/{your-github-username}/{your-repo-name})
![Coverage](https://img.shields.io/codecov/c/github/{your-github-username}/{your-repo-name})

A modern, feature-rich Flutter application designed to help users prepare for exams. This project leverages Firebase for backend services and Riverpod for state management, providing a seamless and reactive user experience.

---

## 📖 Table of Contents

- [About the Project](#about-the-project)
  - [Core Features](#core-features)
  - [Tech Stack](#tech-stack)
- [📸 Screenshots](#-screenshots)
- [🚀 Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Installation](#installation)
- [💻 Usage](#-usage)
- [🏗️ Project Structure](#️-project-structure)
- [🧑‍💻 Development](#-development)
  - [Running Tests](#running-tests)
- [📦 Deployment](#-deployment)
- [🗺️ Roadmap](#️-roadmap)
- [🤝 Contributing](#-contributing)
- [📄 License](#-license)
- [📞 Contact](#-contact)
- [📝 Changelog](#-changelog)

---

## About the Project

**Exam Ready** is a Flutter app to help students find, upload, and analyze past question papers. The app is a client-first mobile/web/desktop Flutter project that integrates Firebase for auth, Firestore and Storage, Cloudinary for image hosting, and an LLM-backed service for topic extraction.

## Features

### Core features

- **Firebase-backed Authentication:** Email/password plus Google Sign-In for user accounts. **Implemented in:** `lib/services/auth_service.dart` (class `AuthService`). **Usage:** sign up / sign in via the app UI (login/signup screens). **Env:** none required for basic auth; see Configuration for optional OAuth keys.
  - Evidence: `lib/services/auth_service.dart` lines ~1-20 (GoogleSignIn instance) and lines ~228-238 (Google Sign-In flow).
- **Centralized Firebase Initialization & AppCheck:** Initializes Firebase and activates App Check (ReCAPTCHA V3 on web / Play Integrity on Android). **Implemented in:** `lib/services/firebase_service.dart` (static `initialize()` method). **Usage:** called from `lib/main.dart` before `runApp()`. **Env:** `RECAPTCHA_V3_SITE_KEY` for web App Check.
  - Evidence: `lib/main.dart` (calls `await FirebaseService.initialize();`) and `lib/services/firebase_service.dart` lines ~31-36 (initialize + AppCheck activation).
- **Upload & Submit Question Papers:** Upload images (camera/gallery), compress, OCR text (ML Kit), upload to Cloudinary, save metadata to Firestore, and update topic frequency. **Implemented in:** `lib/screens/ui/question_paper_submission_page.dart`, `lib/services/cloudinary_service.dart`, `lib/services/firestore_service.dart`, `lib/services/firebase_storage_service.dart`.
  - Usage example (in-app flow): select image → submit → app runs OCR, uploads image, extracts topics, saves to `submitted_papers` and `question_papers`.
  - Env: `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_UPLOAD_PRESET` (Cloudinary upload); see Configuration.
  - Evidence: `lib/screens/ui/question_paper_submission_page.dart` (image pick / `_submitPaper()` flow, calls Cloudinary + Firestore + Groq), `lib/services/cloudinary_service.dart` lines ~1-20.

### Search & Discovery

- **Firestore-backed search & filters:** Stream-based queries for submitted papers with filters (college, branch, semester, subject, exam type), pagination, popular/recent lists. **Implemented in:** `lib/repositories/search_repository.dart`, `lib/services/firebase_search_service.dart`, `lib/riverpod/question_paper_provider.dart`.
  - Usage examples (client API): call `SearchRepository.searchExamPapers(...)` or use providers like `recentPapersProvider` and `textSearchProvider` in UI.
  - Evidence: `lib/services/firebase_search_service.dart` (methods `searchQuestionPapers`, `getColleges`, etc.) and `lib/repositories/search_repository.dart` (searchExamPapers implementation).

### AI / LLM Integration

- **Topic extraction (Groq API wrapper):** Sends extracted text to an LLM (Groq API) to extract Part B topics (returns JSON array). **Implemented in:** `lib/services/groq_service.dart` (method `extractPartBTopics`). **Env:** `GROQ_API_KEY` (in `.env`).
  - Evidence: `lib/services/groq_service.dart` lines ~1-30 (apiKey loading and `extractPartBTopics` signature) and usage in `question_paper_submission_page.dart` where `extractPartBTopics` is called.

### UI / Frontend

- **Modern multi-screen UI:** Entry screen, Dashboard, Search pages, Profile, Paper detail, Topic search, submission flow. **Implemented in:** `lib/screens/*` (e.g., `lib/screens/ui/entry_screen.dart`, `lib/screens/ui/home.dart`, `lib/screens/ui/search.dart`, `lib/screens/ui/question_paper_submission_page.dart`).
  - Evidence: `lib/screens/ui/entry_screen.dart` (Entry UI and navigation buttons) and `lib/screens/ui/home.dart` (Dashboard with stats and navigation to search/submission pages).

### Integrations

- **Cloudinary**: image hosting used during submission. **Implemented in:** `lib/services/cloudinary_service.dart`. **Env:** `CLOUDINARY_CLOUD_NAME`, `CLOUDINARY_UPLOAD_PRESET`.
- **Firebase (Auth, Firestore, Storage, App Check)**: used across app for auth, persistent storage, and security. **Implemented in:** `lib/services/firebase_service.dart`, `lib/services/firestore_service.dart`, `lib/services/firebase_storage_service.dart`.
- **ML Kit (Text Recognition)**: OCR for extracting text from uploaded images. **Implemented in:** `lib/screens/ui/question_paper_submission_page.dart` (uses `google_mlkit_text_recognition`).

## Quick Start

- **Prerequisites:** `flutter` SDK (>= 3.9.2), a Firebase project (for Auth/Firestore/Storage), optional Cloudinary account and Groq API key for topic extraction.
- **Install dependencies:**

```bash
flutter pub get
```

- **Run (debug):**

```bash
flutter run
```

- **Codegen (Riverpod):**

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

## Usage

- App entrypoint: `lib/main.dart` — loads `.env`, initializes Firebase via `FirebaseService.initialize()`, and runs `MyApp()`.
- Main flows (in-app):
  - Login / Sign up: use the UI in `lib/screens/auth/login_screen.dart` and `lib/screens/auth/signup_screen.dart`.
  - Submit Paper: `QuestionPaperSubmissionPage` (select image → OCR → Cloudinary upload → Firestore writes → Groq topic extraction).
  - Search Papers: `SearchQuestionPaperPage` and repository/provider APIs under `lib/repositories` and `lib/riverpod`.

### Example (what happens when you submit a paper)

1. User selects image (camera/gallery) in the app UI (`QuestionPaperSubmissionPage`).
2. App compresses image, runs OCR (`google_mlkit_text_recognition`), uploads image to Cloudinary (`CloudinaryService.uploadImage`).
3. The app saves a document in the `submitted_papers` collection via `FirestoreService.submitToSubmittedPapers` and saves extracted topics in `question_papers`.
4. Topic counts are updated in `questions` collection via `FirestoreService.updateQuestionsCollection`.

## Configuration

- Environment file: the app expects a `.env` file at project root (the file is included in `pubspec.yaml` assets). Key variables used in code:

```text
GROQ_API_KEY                 # used by lib/services/groq_service.dart
CLOUDINARY_CLOUD_NAME        # used by lib/services/cloudinary_service.dart
CLOUDINARY_UPLOAD_PRESET     # used by lib/services/cloudinary_service.dart
RECAPTCHA_V3_SITE_KEY        # used by Firebase App Check in lib/services/firebase_service.dart
```

- Firebase configuration: `lib/firebase_options.dart` and `lib/config/firebase_config.dart` contain generated FirebaseOptions (projectId `exam-ready-13`) for supported platforms. Replace or configure via the FlutterFire CLI or `google-services.json` / `GoogleService-Info.plist` for platform-specific setups.

## Development & Tests

- Run tests with:

```bash
flutter test
```

- Integration tests: there are firebase-related integration tests under `test/` (e.g. `firebase_integration_test.dart`) which call `FirebaseTestHelper.initializeFirebase()`.

## Detected Files (scanned evidence)

Below are the main files scanned and the evidence snippets used to build the Features/Usage sections. For inferred items the note `Inferred — check` appears.

- `lib/main.dart` (entrypoint)

  - snippet: `await FirebaseService.initialize();` (initialization call)

- `lib/services/firebase_service.dart`
  - snippet (initialize + App Check):

```dart
await Firebase.initializeApp(
  options: DefaultFirebaseOptions.currentPlatform,
);
await FirebaseAppCheck.instance.activate(
  webProvider: ReCaptchaV3Provider(dotenv.env['RECAPTCHA_V3_SITE_KEY']!),
  androidProvider: AndroidProvider.playIntegrity,
);
```

- `lib/services/auth_service.dart`
  - snippet (Google Sign-In & auth flows):

```dart
final GoogleSignIn _googleSignIn = GoogleSignIn();
final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
```

- `lib/screens/ui/question_paper_submission_page.dart`
  - snippets (OCR, Cloudinary upload, Firestore writes, Groq usage):

```dart
final TextRecognizer _textRecognizer = TextRecognizer();
final List<String> topics = await _chatGPTService.extractPartBTopics(extractedText);
String? imageUrl = await _cloudinaryService.uploadImage(selectedImage!);
final String docId = await _firestore_service.submitToSubmittedPapers(...);
```

- `lib/services/cloudinary_service.dart`

  - snippet (env usage): `final cloudinary = CloudinaryPublic(dotenv.env['CLOUDINARY_CLOUD_NAME']!, dotenv.env['CLOUDINARY_UPLOAD_PRESET']!, cache: false);`

- `lib/services/groq_service.dart`

  - snippet (env & function): `static final String apiKey = dotenv.env['GROQ_API_KEY'] ?? '';` and `Future<List<String>> extractPartBTopics(String extractedText)`

- `lib/repositories/search_repository.dart` and `lib/services/firebase_search_service.dart`

  - snippet: search and pagination functions (`searchExamPapers`, `searchQuestionPapers`, `getColleges`, etc.)

- `pubspec.yaml`
  - dependency list (Firebase packages, Cloudinary, Google ML Kit, Riverpod, flutter_bloc, etc.)

---

## TODO / Notes

- Inferred — check: Some project-level CI badges in the README are placeholders and should be replaced with real URLs if CI is configured (existing badges in the top of the file use `{your-github-username}` placeholders).
- TODO: If you want, I can also generate a `.env.example` listing the variables above.

### Tech Stack

- **Frontend:** [Flutter](https://flutter.dev/)
- **Backend:** [Firebase](https://firebase.google.com/) (Authentication, Firestore, Storage)
- **State Management:** [Riverpod](https://riverpod.dev/), [Bloc](https://bloclibrary.dev/)
- **Image & Media:** [Cloudinary](https://cloudinary.com/), [Image Picker](https://pub.dev/packages/image_picker)
- **UI/Animations:** [Lottie](https://pub.dev/packages/lottie), [Flutter Animate](https://pub.dev/packages/flutter_animate)

---

## 📸 Screenshots

Here are some previews of the _Exam Ready_ app:

| Login Screen                           | Home Screen                              |
| -------------------------------------- | ---------------------------------------- |
| ![Login Screen](assets/Login_page.jpg) | ![Home Screen](assets/dashbord_page.jpg) |

---

## 🚀 Getting Started

Follow these instructions to get a copy of the project up and running on your local machine for development and testing purposes.

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (version 3.9.2 or higher)
- [Firebase CLI](https://firebase.google.com/docs/cli#install_the_firebase_cli)
- An editor like [VS Code](https://code.visualstudio.com/) or [Android Studio](https://developer.android.com/studio)

### Installation

1.  **Clone the repository:**

    ```bash
    git clone https://github.com/{your-github-username}/{your-repo-name}.git
    cd {your-repo-name}
    ```

2.  **Set up Firebase:**

    - Create a new project on the [Firebase Console](https://console.firebase.google.com/).
    - Add an Android and/or iOS app to your Firebase project.
    - Follow the instructions to download the `google-services.json` file for Android and `GoogleService-Info.plist` for iOS.
    - Place `google-services.json` in the `android/app/` directory.
    - Place `GoogleService-Info.plist` in the `ios/Runner/` directory.

3.  **Create a `.env` file:**

    Create a `.env` file in the root of the project and add the necessary environment variables. See the `.env.example` section below.

4.  **Install dependencies:**

    ```bash
    flutter pub get
    ```

---

## 💻 Usage

To run the application, use the following command:

```bash
flutter run
```

This will launch the app on your connected device or simulator.

---

## 🏗️ Project Structure

```
exam_ready/
├── android/
├── assets/
│   ├── lottie/
│   └── images/
├── ios/
├── lib/
│   ├── config/
│   ├── data/
│   ├── models/
│   ├── providers/
│   ├── repositories/
│   ├── riverpod/
│   ├── screens/
│   ├── services/
│   ├── theme/
│   ├── utils/
│   ├── widgets/
│   └── main.dart
├── test/
└── pubspec.yaml
```

### Assets Management

All static assets (images, animations, etc.) are stored in the `assets/` directory:

- **`assets/lottie/`** - Lottie animation JSON files (login, signup, etc.)
- **`assets/images/`** - PNG, JPG, and other image files for the UI

To use an image in your code:

```dart
Image.asset('assets/images/logo.png')
```

All assets must be declared in `pubspec.yaml` under the `flutter.assets` section.

---

## 🧑‍💻 Development

This project uses `riverpod_generator` for code generation. When you create or modify providers, run the following command to generate the necessary files:

```bash
flutter pub run build_runner watch --delete-conflicting-outputs
```

### Running Tests

To run the test suite, use the following command:

```bash
flutter test
```

---

## 📦 Deployment

This project is set up for mobile app deployment on the Google Play Store and Apple App Store.

- **Android:** Follow the official Flutter documentation for [building and releasing an Android app](https://flutter.dev/docs/deployment/android).
- **iOS:** Follow the official Flutter documentation for [building and releasing an iOS app](https://flutter.dev/docs/deployment/ios).

---

## 🗺️ Roadmap

_(This section is a placeholder. Outline the future plans for the project here.)_

- [ ] Feature A
- [ ] Feature B
- [ ] Feature C

---

## 🤝 Contributing

Contributions are what make the open-source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

Please see the `CONTRIBUTING.md` file for details on our code of conduct, and the process for submitting pull requests to us.

---

## 📄 License

This project is licensed under the MIT License - see the `LICENSE` file for details.

---

## 📞 Contact

_(This section is a placeholder. Add your contact information here.)_

Project Link: [https://github.com/{your-github-username}/{your-repo-name}](https://github.com/{your-github-username}/{your-repo-name})

---

## 📝 Changelog

All notable changes to this project will be documented in this file. See `CHANGELOG.md` for more information.
