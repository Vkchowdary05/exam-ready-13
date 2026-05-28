<div align="center">
  <h1>🚀 EXAM READY</h1>
  <p><b>Know what matters. Your AI-powered exam preparation companion.</b></p>
  <p>
    <img src="https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Firebase-FFCA28?style=for-the-badge&logo=firebase&logoColor=black" alt="Firebase" />
    <img src="https://img.shields.io/badge/Node.js-43853D?style=for-the-badge&logo=node.js&logoColor=white" alt="Node.js" />
    <img src="https://img.shields.io/badge/Groq-000000?style=for-the-badge&logo=groq&logoColor=white" alt="Groq AI" />
  </p>
</div>

---

## 📖 1. Project Overview

**Exam Ready** is an AI-powered, community-driven exam preparation platform tailored for university students (especially B.Tech students in India). 

### The Problem It Solves
Students often waste hours searching WhatsApp groups and college forums for Previous Year Question (PYQ) papers. Furthermore, knowing *what* to study from those papers is a manual, tedious process of counting repeated topics.

### The Solution
Exam Ready centralizes thousands of question papers and uses **Generative AI** to automatically read uploaded papers, extract key topics, and generate heatmaps of the most frequently asked questions. 

**Target Audience:** University students, Engineering (B.Tech) scholars, and educators looking to identify curriculum patterns.

---

## ✨ 2. Features

### Core Features
*   **Question Paper Repository:** Browse, search, and bookmark previous year papers by college, branch, and semester.
*   **Topic Analysis & Heatmaps:** See exactly how many times a topic has appeared in past exams.
*   **Study Groups:** Create or join Pomodoro-based study sessions with peers. Includes real-time topic checklists.
*   **Doubts Q&A Forum:** Ask questions anonymously, provide answers, and upvote the best explanations.
*   **Gamified Leaderboard:** Earn XP by uploading papers and receiving upvotes. Compete on college, branch, and global leaderboards.
*   **User Profiles:** Track your study streaks, unlocked badges, and bookmarks.

### Advanced AI Integrations
*   **AI Topic Extraction:** Integrates with the lightning-fast **Groq API** (Llama 3) to automatically parse OCR text from uploaded question papers and extract structured educational topics.
*   **Smart Categorization:** AI assigns priority badges like "🔥 Hot" (repeated often) and "⚡ Due" (hasn't appeared recently but historically important).

### Security & Infrastructure
*   **Firebase Authentication** (Email & Google).
*   **Backend Proxy Architecture:** No sensitive API keys are exposed to the client app. All AI and Storage integrations route securely through Firebase Cloud Functions.
*   **Role-Based Security:** Hardened Firestore rules prevent unauthorized access or data tampering.

---

## 🛠️ 3. Tech Stack

| Category | Technologies / Tools |
| :--- | :--- |
| **Frontend** | Flutter (Dart), Riverpod (State Management), Google Fonts |
| **Backend** | Firebase Cloud Functions (Node.js) |
| **Database** | Firebase Firestore (NoSQL) |
| **Storage** | Firebase Storage, Cloudinary (via Signed Uploads) |
| **Authentication** | Firebase Auth (Email/Password, Google Sign-In) |
| **AI / Machine Learning** | Groq API (Llama 3 70B) for Text Extraction |
| **Design System** | Custom BRIK® Design (Deep teal, cream, lavender) |
| **Deployment** | Firebase Hosting (Functions), Android APK |

---

## 🏗️ 4. Project Architecture

Exam Ready follows a **Client-Server Proxy Architecture**:

1.  **Frontend (Flutter App):** Handles the UI (built with the BRIK design system) and local state management using Riverpod 3.0+.
2.  **Backend Proxy (Cloud Functions):** The Flutter app does **not** communicate directly with third-party APIs (Groq, Cloudinary) to prevent API key leakage. Instead, it calls secure Firebase Cloud Functions.
3.  **Data Flow:**
    *   *Upload:* User selects a photo -> App requests a signed Cloudinary URL from Cloud Functions -> App uploads to Cloudinary securely.
    *   *AI Extraction:* App sends OCR text to Cloud Function -> Function securely calls Groq API -> Function returns JSON topics to App.
4.  **Database (Firestore):** Stores Users, Papers, Topics, Doubts, and Groups. Protected by strict `firestore.rules`.

### Folder Responsibilities
*   `lib/models/`: Data schema and serialization.
*   `lib/providers/`: Riverpod state managers (auto-disposed to prevent memory leaks).
*   `lib/screens/`: UI Views (Auth, Dashboard, Analysis, Doubts).
*   `lib/services/`: Firebase, AI, and Network interaction layers.
*   `lib/utils/`: Security sanitizers, error handlers, and UI constants.
*   `lib/theme/`: Centralized typography and color palettes.
*   `functions/`: Node.js backend logic and secure API proxies.

---

## 📂 5. Folder Structure

```text
exam_ready/
 ├── functions/                      # Node.js Backend (Cloud Functions)
 │   ├── index.js                    # Core backend logic & API proxies
 │   ├── package.json                # Backend dependencies
 ├── lib/                            # Flutter Frontend Source Code
 │   ├── data/
 │   │   └── dropdown_data.dart      # Static college/branch data
 │   ├── models/                     # Data schemas (QuestionPaper, User, Topic)
 │   ├── providers/                  # Riverpod State Management
 │   ├── screens/                    # User Interface
 │   │   ├── auth/                   # Login, Signup, Onboarding
 │   │   └── ui/                     # Dashboard, Leaderboard, Doubts, Profile
 │   ├── services/                   # API and Firebase connection layers
 │   ├── theme/                      # AppTheme (Colors, Typography)
 │   ├── utils/                      # PII Sanitizers, Error Handlers, Strings
 │   └── main.dart                   # Entry point of the application
 ├── firestore.rules                 # Security rules for the database
 ├── pubspec.yaml                    # Flutter dependencies
 └── README.md                       # Documentation
```

---

## 🚀 6. Installation & Setup Guide

Follow these steps to run the project from scratch.

### Prerequisites
*   [Flutter SDK](https://docs.flutter.dev/get-started/install) (v3.19.0 or higher)
*   [Node.js](https://nodejs.org/) (v18.0.0 or higher) - Required for Cloud Functions
*   [Firebase CLI](https://firebase.google.com/docs/cli) installed (`npm install -g firebase-tools`)
*   A [Firebase Project](https://console.firebase.google.com/)
*   A [Groq API Key](https://console.groq.com/keys)
*   A [Cloudinary Account](https://cloudinary.com/)

### Step 1: Clone the Repository
```bash
git clone https://github.com/yourusername/exam-ready.git
cd exam-ready
```

### Step 2: Frontend Setup
Install Flutter dependencies:
```bash
flutter pub get
```

### Step 3: Firebase Project Initialization
1.  Log in to Firebase CLI:
    ```bash
    firebase login
    ```
2.  Connect your local project to your Firebase project:
    ```bash
    firebase use --add YOUR_FIREBASE_PROJECT_ID
    ```
3.  Configure FlutterFire (Generates `firebase_options.dart`):
    ```bash
    dart pub global activate flutterfire_cli
    flutterfire configure
    ```

### Step 4: Backend (Cloud Functions) Setup
1.  Navigate to the functions directory:
    ```bash
    cd functions
    npm install
    ```
2.  Set up environment variables securely in Firebase:
    ```bash
    firebase functions:config:set groq.api_key="YOUR_GROQ_KEY"
    firebase functions:config:set cloudinary.cloud_name="YOUR_CLOUD_NAME"
    firebase functions:config:set cloudinary.api_key="YOUR_CLOUDINARY_API_KEY"
    firebase functions:config:set cloudinary.api_secret="YOUR_CLOUDINARY_SECRET"
    ```
3.  Deploy the Cloud Functions and Firestore Rules:
    ```bash
    firebase deploy --only functions,firestore:rules
    ```

### Step 5: Run the App
```bash
cd ..
flutter run
```

---


## 🔐 7. Environment Variables & Security

**Crucial Note:** This project does **NOT** use a `.env` file in the Flutter client for security reasons. Bundling API keys in `.env` exposes them to decompilation. 

Instead, all secrets are stored securely in **Firebase Functions Config** (as shown in Step 4). The Flutter app relies entirely on the Cloud Functions to proxy requests to Groq and Cloudinary.

---

## ⚙️ 8. Backend Setup (Cloud Functions)

The backend (`functions/index.js`) serves as a secure proxy and trigger system.

### Key Cloud Functions:
1.  `extractTopics` (HTTPS Callable): Receives OCR text from the app, securely calls the Groq LLM using the hidden API key, and returns formatted JSON.
2.  `getUploadSignature` (HTTPS Callable): Generates a secure, timestamped signature using the hidden Cloudinary Secret, allowing the client to upload images safely.
3.  `onPaperCreated` (Firestore Trigger): When a new paper is added, this automatically calculates XP for the user, increments total counts, and triggers notifications.
4.  `onPaperVoted` (Firestore Trigger): Monitors downvotes. If a paper hits a score of -5, it is automatically flagged for admin review.

---

## 🖥️ 9. Frontend Setup (Flutter)

The frontend is built with **Riverpod** for reactive, memory-safe state management.

### Key Concepts:
*   **AutoDispose:** All `StreamProviders` (like the dashboard stats and real-time feeds) use `.autoDispose` to automatically cancel Firebase listeners when the user navigates away, preventing memory leaks.
*   **AuthGuard:** A custom widget (`lib/utils/auth_guard.dart`) wraps protected routes, ensuring that unauthenticated users or those without verified emails cannot access the dashboard.
*   **Sanitization:** The `InputSanitizer` utility strips PII (Phone numbers, Emails, Roll Numbers, Aadhaar) from any OCR text before it is sent to the AI.

---

## 🗄️ 10. Database Setup (Firestore)

The NoSQL schema is optimized for fast reads.

### Core Collections:
*   `users`: Profiles, XP, level, bookmarks, college/branch details.
*   `question_papers`: The actual papers. Includes upvotes, views, verified badges, and OCR confidence scores.
*   `topics`: Tracks frequency across papers to generate heatmaps.
*   `study_groups`: Contains group members and topic progress checklists.
*   `doubts`: Q&A forum entries with an `answers` sub-collection.
*   `notifications`: Real-time alerts for users (e.g., "Your paper was verified!").

### Firestore Rules (`firestore.rules`)
Strict rules ensure that:
*   Users can only edit/delete their **own** uploads.
*   XP and levels can only be modified by the server (Cloud Functions), preventing cheating.
*   PII fields remain private.

---

## 📡 11. API Documentation (Cloud Functions)

### 1. `extractTopics`
*   **Method:** POST (Firebase Callable)
*   **Description:** Extracts educational topics from raw OCR text.
*   **Payload:** `{ "text": "raw OCR string", "subject": "Mathematics" }`
*   **Response:** `{ "topics": ["Calculus", "Linear Algebra"] }`

### 2. `getUploadSignature`
*   **Method:** POST (Firebase Callable)
*   **Description:** Returns credentials for a direct Cloudinary upload.
*   **Payload:** `{}` (Requires authenticated user)
*   **Response:** `{ "signature": "xxx", "timestamp": 12345, "apiKey": "xxx", "cloudName": "xxx" }`

---

## 🧠 12. AI/ML Implementation

The app uses **Generative AI (Groq API / Llama 3)** to understand unstructured exam papers.

**The Pipeline:**
1.  **Image Capture:** User takes a photo of an exam paper.
2.  **Local OCR:** On-device ML kit extracts raw, messy text from the image.
3.  **Sanitization:** RegEx algorithms remove personal data (names, roll numbers) from the text.
4.  **AI Extraction:** The sanitized text is sent to the Cloud Function, which prompts Llama 3 with strict formatting instructions (JSON output only) to identify core syllabus topics.
5.  **Aggregation:** The extracted topics are merged into Firestore, updating the "Heatmap" for that subject.

---

## 🛡️ 13. Authentication & Security

*   **Provider:** Firebase Authentication (Email/Password).
*   **Verification:** Mandatory email verification ensures valid user accounts.
*   **Data Protection:** Client-side `.env` files were eliminated. All external API communication happens Server-to-Server.
*   **Spam Prevention:** Papers with net-negative votes (-5) are automatically hidden/flagged.

---

## 🚀 14. Deployment Guide

### Android (APK / App Bundle)
1.  Update the `version` in `pubspec.yaml`.
2.  Run the flutter build command:
    ```bash
    flutter build apk --release
    # Or for Play Store:
    flutter build appbundle --release
    ```

### Backend (Cloud Functions)
Any changes to `functions/index.js` require deployment:
```bash
firebase deploy --only functions
```

---

## 📱 15. Screenshots / UI Preview

| Splash & Onboarding | Dashboard | Topic Analysis (AI) |
| :---: | :---: | :---: |
| ![Splash](https://via.placeholder.com/250x500.png?text=Splash+Screen) | ![Dashboard](https://via.placeholder.com/250x500.png?text=Dashboard) | ![Heatmap](https://via.placeholder.com/250x500.png?text=Topic+Analysis) |

| Leaderboard | Doubts Q&A | Study Groups |
| :---: | :---: | :---: |
| ![Leaderboard](https://via.placeholder.com/250x500.png?text=Leaderboard) | ![Doubts](https://via.placeholder.com/250x500.png?text=Doubts+Forum) | ![Groups](https://via.placeholder.com/250x500.png?text=Study+Groups) |

*(Note: Replace placeholders with actual application screenshots)*

---

## 🎮 16. Usage Guide

**Example Workflow: Analyzing a Exam Paper**
1.  **Sign Up:** Create an account and select your College, Branch, and Semester.
2.  **Upload:** Tap the floating "+" button, snap a picture of a past exam paper.
3.  **AI Magic:** Wait a few seconds while the AI reads the paper and tags the topics.
4.  **Analyze:** Go to the "Topic Analysis" tab. You will see a heatmap showing exactly which topics from that paper appear most frequently across all years.
5.  **Collaborate:** Create a Study Group and add those "Hot Topics" to your group's checklist.

---

## 🧪 17. Testing

The project is built to support Flutter's testing frameworks.

To run unit and widget tests:
```bash
flutter test
```

To run the Dart static analyzer to catch potential bugs:
```bash
flutter analyze
```

---

## ⚡ 18. Performance Optimizations

*   **Riverpod `autoDispose`:** Ensures streams (like real-time leaderboards) are closed when not on screen, saving battery and memory.
*   **Image Caching:** Uses `cached_network_image` to save downloaded exam papers to local storage, reducing bandwidth and load times on subsequent views.
*   **Pagination:** Firestore queries for Doubts and Papers are paginated (limit 20) to ensure fast load times regardless of database size.

---

## 🗺️ 19. Future Enhancements

*   [ ] **PDF Support:** Allow users to upload multi-page PDFs alongside images.
*   [ ] **AI Tutor Chat:** Allow users to chat with an AI regarding a specific question paper to get explanations.
*   [ ] **Web Version:** Deploy a Flutter Web portal for easier desktop viewing.
*   [ ] **Push Notifications:** Implement FCM (Firebase Cloud Messaging) to alert users when their doubt is answered.

---

## 🛠️ 20. Troubleshooting

**Common Issues:**

1.  **Cloudinary Uploads Failing?**
    *   *Fix:* Ensure you have set the Cloudinary credentials in Firebase Functions Config, and that you have deployed the functions.
2.  **AI Topic Extraction Returning Empty?**
    *   *Fix:* Check your Groq API key limits. If the API is rate-limiting you, the Cloud Function will catch the error and log it in the Firebase Console.
3.  **App crashes on launch (Firebase Error)?**
    *   *Fix:* Ensure you ran `flutterfire configure` and that your `google-services.json` (Android) / `GoogleService-Info.plist` (iOS) are correctly placed.

---

## ❓ 21. FAQ

**Q: Why was the `.env` file removed?**  
A: Putting API keys in a `.env` file inside a mobile app is a security risk. Malicious users can reverse-engineer the APK and steal the keys. We moved them to the backend.

**Q: Is the AI extraction free?**  
A: The Groq API currently offers generous free tiers, making it ideal for this educational use case.

---

## 🤝 22. Contributing Guide

We welcome contributions! 

1.  **Fork** the repository.
2.  **Create a branch:** `git checkout -b feature/awesome-feature`
3.  **Commit changes:** `git commit -m 'Add awesome feature'`
4.  **Push:** `git push origin feature/awesome-feature`
5.  Open a **Pull Request**.

Please ensure your code passes `flutter analyze` and follows the existing BRIK® design system patterns.

---

## 📄 23. License

This project is licensed under the MIT License - see the LICENSE file for details.

---

## 👏 24. Author & Credits

*   **Project Creator & Maintainer:** Papas / Exam Ready Team
*   **AI Models:** [Groq](https://groq.com/) (Llama 3)
*   **Backend:** [Firebase](https://firebase.google.com/)
*   **Image Hosting:** [Cloudinary](https://cloudinary.com/)
*   **UI Framework:** [Flutter](https://flutter.dev/)

---
<div align="center">
  <p>Built with ❤️ for students, by students.</p>
</div>

