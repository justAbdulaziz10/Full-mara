Mara

Mara is a next-generation AI-powered health assistant designed to empower people worldwide with safe, accessible, and personalized medical insights. The project consists of:
	•	📱 Mara Final (Flutter app) → Mobile client for Android & iOS
	•	⚙️ Backend (Python / FastAPI + Gunicorn) → API, AI model integration, authentication, subscription services
	•	🔒 Firebase + RevenueCat → Authentication, payments, and analytics

⸻

📂 Project Structure

.
├── backend/                  # Python backend (APIs, AI model serving)
│   ├── app/                  # FastAPI app source code
│   ├── requirements.txt      # Python dependencies
│   ├── gunicorn_conf.py      # Gunicorn config for deployment
│   └── README.md             # Backend-specific docs
│
├── marafinal/                # Flutter frontend
│   ├── android/              # Android-specific build files
│   ├── ios/                  # iOS-specific build files
│   ├── lib/                  # Flutter Dart source code
│   │   ├── main.dart         # App entry point
│   │   ├── splash_screen.dart
│   │   ├── auth_gate.dart
│   │   └── firebase_options.dart
│   ├── assets/               # App icons and images
│   │   ├── logo_light.png
│   │   ├── logo_dark.png
│   │   ├── apple.png
│   │   ├── google.png
│   │   └── icon.png
│   ├── pubspec.yaml          # Flutter dependencies
│   └── test/                 # Unit & widget tests
│
├── firebase.json             # Firebase config
├── pubspec.lock              # Dependency lockfile
├── analysis_options.yaml     # Dart analysis settings
├── devtools_options.yaml     # DevTools settings
└── README.md                 # (You are here)

2. Frontend (Flutter)

Requirements:
	•	Flutter SDK (>=3.0)
	•	Dart (>=2.19)
	•	Android Studio / Xcode (for builds)
	•	Firebase CLI

3. Backend (FastAPI + Gunicorn)

Requirements:
	•	Python 3.10+
	•	pip / venv
	•	PostgreSQL (via Supabase)
	•	FastAPI
	•	Gunicorn


🔐 Authentication & Payments
	•	Firebase Auth → Email, Google, Apple login
	•	RevenueCat → Subscription management

⸻

🌍 Features
	•	AI-powered medical Q&A (Mara Doctor)
	•	Multilingual support (all major languages)
	•	Secure user onboarding (name, age, blood type, etc.)
	•	Symptom guidance with personalized recommendations
	•	Health data integration (Apple Health, Google Fit)
	•	Smart reminders & health insights
	•	Offline-first mode (for the smart mirror integration)

⸻

📦 Deployment
	•	Frontend: iOS App Store / Google Play
	•	Backend: Cloudflare Workers + Supabase (Postgres)
	•	CI/CD: GitHub Actions (tests, build, deploy)

⸻

🛠️ Tech Stack
	•	Frontend: Flutter (Dart)
	•	Backend: FastAPI, Python, Gunicorn
	•	Database: PostgreSQL (Supabase)
	•	Auth/Payments: Firebase, RevenueCat
	•	AI: Custom Transformer models trained on medical data
	•	Infra: Cloudflare Workers, Docker (future)

⸻

👥 Team
	•	Abdulaziz Alkhlaiwe – Co-founder, Dev, AI/Backend
	•	Omar [Full Name] – Co-founder, Dev, Frontend

⸻

📜 License

This project is licensed under the MIT License. See LICENSE for details.

⸻

📬 Contact

🌐 Website: www.iammara.com
✉️ Email: contact@iammara.com
