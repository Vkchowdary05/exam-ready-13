# 🎓 Exam Ready — AI-Powered Exam Preparation Platform

**Exam Ready** is a modern, multi-platform Flutter application designed to help students **upload, search, discover, and analyze past exam papers**, powered by:

- **Google ML Kit (OCR)**
- **Groq LLM (Topic Extraction)**
- **Firebase (Auth, Firestore, Storage)**
- **Cloudinary (Image Hosting)**
- **Riverpod (State Management)**

The app aims to centralize exam preparation by allowing students to upload question papers, automatically extract topics, and search through a rich database of structured exam content.

---

## 🏗️ Project Overview

Exam Ready automates the full workflow of:

1. **Uploading question paper images**
2. **Extracting text using OCR**
3. **Uploading images to Cloudinary**
4. **Extracting topics using AI**
5. **Saving structured content to Firestore**
6. **Enabling fast, real-time search & filtering**

The app works across **Android, iOS, Web, Windows, macOS, and Linux** using Flutter’s multi-platform capabilities.

---

# 🚀 Core Features

## 🔐 1. Authentication System
- Firebase Email/Password authentication  
- Google Sign-In integration  
- Auth state persistence  
- Error-handled login/signup flows  

**Key Files**
- `lib/services/auth_service.dart`
- `lib/screens/auth/login_screen.dart`
- `lib/screens/auth/signup_screen.dart`

---

## 📤 2. Automated Question Paper Submission Pipeline

### ✨ End-to-End Flow

User Image → Compress → OCR → Cloudinary Upload → Groq Topic Extraction → Firestore Storage

### 🔍 Steps in Detail

#### 2.1 Image Selection
- From camera or gallery  
- Uses `image_picker` package  

#### 2.2 Image Compression
- Ensures fast upload  
- Reduces bandwidth usage  

#### 2.3 OCR Extraction (Google ML Kit)
- Detects text in uploaded images  
- Structured extraction using ML Kit recognizers  
- Runs fully on-device → fast & private  

#### 2.4 Upload to Cloudinary
- Returns a hosted secure URL  
- Uses `CLOUDINARY_CLOUD_NAME` & `UPLOAD_PRESET`  

#### 2.5 Groq API Topic Extraction (AI-Powered)
- Sends OCR text to an LLM  
- Returns structured JSON list of Part-B topics  
- Used to classify and organize content  

#### 2.6 Firestore Storage
- Stores:
  - image URL  
  - extracted text  
  - extracted topics  
  - metadata (branch, subject, semester, exam type)  

**Key Files**
- `lib/screens/ui/question_paper_submission_page.dart`
- `lib/services/cloudinary_service.dart`
- `lib/services/groq_service.dart`
- `lib/services/firestore_service.dart`

---

## 🔎 3. Powerful Search & Filtering

### Supported Filters:
- **College**
- **Branch**
- **Semester**
- **Subject**
- **Exam Type**
- **Keyword full-text search**

### Real-time Data
- All search results update instantly using Firestore streams  
- Pagination supported  

**Key Files**
- `lib/services/firebase_search_service.dart`
- `lib/repositories/search_repository.dart`
- `lib/riverpod/question_paper_provider.dart`
- `lib/screens/ui/search.dart`

---

## 🤖 4. AI-Driven Topic Extraction (Groq LLM)

The app integrates the Groq API to:
- Extract exact Part-B questions  
- Classify and normalize topic titles  
- Return a structured list  

**Key File**
- `lib/services/groq_service.dart`

---

## 🎨 5. Clean, Modern UI

### Screens Included:
- Entry screen  
- Login screen  
- Signup screen  
- Dashboard  
- Submission form  
- Search page  
- Paper detail page  
- Topic explorer  

### UI Enhancements:
- Lottie animations  
- Smooth gradients  
- Responsive for all screen sizes  

**Key Files**
- `lib/screens/ui/entry_screen.dart`
- `lib/screens/ui/home.dart`
- `lib/screens/ui/search.dart`
- `lib/screens/ui/question_paper_submission_page.dart`

---

# 🏛️ Architecture

## App Architecture (High-Level)
+-------------------------+
| Presentation |
| Flutter UI Screens |
+-----------+-------------+
|
v
+-------------------------+
| State Management |
| Riverpod Providers |
+-----------+-------------+
|
v
+-------------------------+
| Domain & Repos |
| SearchRepository, etc |
+-----------+-------------+
|
v
+-------------------------+
| Services Layer |
| Firebase, Cloudinary, |
| Groq API, OCR, Storage |
+-----------+-------------+
|
v
+-------------------------+
| Firebase Backend |
| Auth, Firestore, |
| Storage, AppCheck |
+-------------------------+


---

# 📁 Directory Breakdown



lib/
├── config/ # Firebase configuration
├── data/ # Static lists (colleges, branches)
├── models/ # Data models (QuestionPaper, etc.)
├── providers/ # Riverpod provider definitions
├── repositories/ # Data-access layer
├── riverpod/ # Generated provider files
├── screens/ # All UI screens
│ ├── auth/
│ ├── ui/
│ └── widgets/
├── services/ # Firebase, Cloudinary, ML, Groq API
├── theme/ # AppTheme colors, fonts
├── utils/ # Helpers, validators
└── main.dart # App entry point


---

# 🔧 Configuration

Create a `.env` file at project root:



GROQ_API_KEY=
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_UPLOAD_PRESET=
RECAPTCHA_V3_SITE_KEY=


Firebase setup uses:
- `lib/firebase_options.dart`
- `lib/config/firebase_config.dart`

Platform-specific files required:



android/app/google-services.json
ios/Runner/GoogleService-Info.plist


---

# 🚀 Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/{your-username}/{your-repo}.git
cd {your-repo}

2. Install Packages
flutter pub get

3. Run the App
flutter run

4. Riverpod Codegen
flutter pub run build_runner build --delete-conflicting-outputs

📸 Screenshots
Login	Dashboard

	
🧪 Testing

Run all tests:

flutter test

📦 Deployment
Android Deployment
flutter build apk --release

iOS Deployment
flutter build ios --release

🛣️ Roadmap

 Offline mode & caching

 Multi-language OCR

 Full-paper topic clustering

 Predictive topic analysis

 Educator dashboard

🤝 Contributing

Pull requests are welcome.
Please follow standard GitHub flow:

Fork the repository

Create a feature branch

Commit changes

Submit a pull request

📄 License

This project is licensed under MIT License.
See LICENSE for details.

📞 Contact

Add your personal contact info or portfolio link here.

📝 Changelog

See CHANGELOG.md for version history and patch notes.


---

