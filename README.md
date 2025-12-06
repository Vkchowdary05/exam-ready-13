<p align="center"> <img src="assets/images/logo.png" height="140" alt="Exam Ready Logo"/> </p> <p align="center"> <strong>A modern, AI-powered Flutter application to help students find, upload, and analyze past exam papers.</strong> </p> <p align="center"> <img src="https://img.shields.io/github/actions/workflow/status/{your-github-username}/{your-repo-name}/main.yml?branch=main"/> <img src="https://img.shields.io/github/license/{your-github-username}/{your-repo-name}"/> <img src="https://img.shields.io/github/v/release/{your-github-username}/{your-repo-name}"/> <img src="https://img.shields.io/codecov/c/github/{your-github-username}/{your-repo-name}"/> </p>
✨ About the Project

Exam Ready is a multi-platform Flutter application designed to simplify exam preparation.
With powerful AI topic extraction, Firebase services, intuitive UI, and seamless uploads, this app helps students gain insights from past question papers faster than ever.

🚀 Core Features
🔐 Authentication (Firebase Auth + Google Sign-In)

Secure login & signup via email/password or Google.

Implemented in lib/services/auth_service.dart

Automatically initializes with Firebase on app launch.

☁️ Cloud-Powered Document Management

Upload question paper images (camera/gallery)

Automatic image compression

OCR text extraction using ML Kit

Cloudinary image hosting

Firestore storage of metadata & extracted topics

🔍 Smart Search & Filtering

Filter papers by college, branch, semester, subject, and exam type.

Real-time queries powered by Firestore streams.

Popular and recently uploaded papers surfaced automatically.

🤖 AI Topic Extraction (Groq API + LLM)

Extracts Part-B High-Weightage Topics from uploaded papers.

Converts OCR text → JSON topic list

Implemented in lib/services/groq_service.dart

💫 Modern UI & Screens

Clean entry screen & dashboard

Search page, paper detail page, submission flow

Reactive UI using Riverpod state management

Smooth animations (Lottie + Flutter Animate)

🔗 Third-Party Integrations

Cloudinary for media hosting

Firebase (Auth, Firestore, Storage, App Check)

Google ML Kit for OCR

Riverpod + Bloc for state management

🧠 Tech Stack
Category	Technologies
Frontend	Flutter
Backend Services	Firebase Auth, Firestore, Storage
AI Integration	Groq LLM API
OCR	Google ML Kit
State Management	Riverpod, Bloc
Media Storage	Cloudinary
Animations	Lottie, Flutter Animate
📸 Screenshots
Login Screen	Dashboard

	
⚡ Getting Started
✔️ Prerequisites

Flutter SDK (>= 3.9.2)

Firebase CLI

Code editor (VS Code, Android Studio)

📥 Installation
git clone https://github.com/{your-github-username}/{your-repo-name}.git
cd {your-repo-name}
flutter pub get

🔧 Firebase Setup

Place:

google-services.json → android/app/

GoogleService-Info.plist → ios/Runner/

🗝️ Environment Variables (.env)
GROQ_API_KEY=
CLOUDINARY_CLOUD_NAME=
CLOUDINARY_UPLOAD_PRESET=
RECAPTCHA_V3_SITE_KEY=

📱 Usage

Run the project:

flutter run

🌟 Main User Flows

Login/Signup

Submit Paper
→ OCR → Cloudinary → Firestore → AI Topic Extraction

Search Papers via filters or keywords

🏗️ Project Structure
lib/
├── config/
├── data/
├── models/
├── providers/
├── repositories/
├── riverpod/
├── screens/
├── services/
├── theme/
├── utils/
├── widgets/
└── main.dart

🧑‍💻 Development
Generate Riverpod Files
flutter pub run build_runner watch --delete-conflicting-outputs

Run Tests
flutter test

📦 Deployment

📱 Android → Build & upload to Google Play

🍎 iOS → Archive & publish through Xcode

Official Flutter deployment docs recommended.

🛣️ Roadmap

 User analytics

 Offline exam paper caching

 Improved AI topic clustering

 Multi-language question classification

🤝 Contributing

Fork repo

Create feature branch

Submit PR with clear description

See CONTRIBUTING.md.

📄 License

Licensed under MIT — see the LICENSE file.

📞 Contact

Add your contact info here.
Project Link:
https://github.com/{your-github-username}/{your-repo-name}

📝 Changelog

See CHANGELOG.md for version history.
