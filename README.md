<div align="center">
	<img src="marafinal/assets/logo.png" alt="Mara Logo" width="120" />
  
	             Mara | مَرَا
	**AI‑powered personal health assistant** delivering safe, multilingual and privacy‑aware medical insights.
	<br/>
	<strong>Mobile App (Flutter) · FastAPI Backend · Firebase · RevenueCat · AI Inference</strong>
</div>

---

## � Overview
Mara combines a Flutter mobile client with a Python (FastAPI) backend that mediates authentication, usage quotas, multilingual processing, AI reasoning, and (future) record/file analysis. Subscriptions & entitlements are handled through RevenueCat; authentication and basic user metadata through Firebase. PostgreSQL (via Supabase) or future storage layers can back persistent analytics and usage.

## � Project Structure
```
.
├── backend/                 # FastAPI service (API, auth, translation, AI calls)
│   ├── app/
│   │   ├── main.py          # FastAPI entrypoints & routes
│   │   ├── auth.py          # Firebase token verification
│   │   ├── config.py        # Settings (env-driven)
│   │   ├── mara_client.py   # ask_mara_doctor() abstraction
│   │   ├── translate.py     # Language detection & translation helpers
│   │   └── usage_store.py   # Simple in-memory / placeholder usage tracking
│   ├── requirements.txt
│   └── gunicorn_conf.py
├── marafinal/               # Flutter app root
│   ├── lib/
│   │   ├── main.dart
│   │   ├── splash_screen.dart
│   │   ├── auth_gate.dart
│   │   └── firebase_options.dart
│   ├── assets/              # Logos & images
│   ├── android/             # Android build config
│   ├── ios/                 # iOS project
│   ├── pubspec.yaml
│   └── test/
├── serviceAccount.json (optional local dev Firebase creds)
└── README.md (you are here)
```

## ✨ Core Features
- AI medical Q&A (contextual, multilingual)
- Automatic language detection & translation pipeline
- Usage quotas (daily free messages & character limits)
- Secure auth: Email / Google / Apple via Firebase
- Subscription & entitlement management (RevenueCat)
- Planned: File / lab report analysis, health device integrations, smart mirror offline mode

## 🛠 Tech Stack
| Layer        | Technology |
|--------------|------------|
| Mobile       | Flutter (Dart) |
| Backend API  | FastAPI + Uvicorn/Gunicorn |
| AI Models    | OpenAI / Hugging Face inference (configurable) |
| Auth         | Firebase Auth |
| Payments     | RevenueCat |
| Data / Future| PostgreSQL (Supabase) |
| Infra (future)| Docker, Cloudflare Workers / Edge |

## 🔐 Authentication & Authorization
Clients send a Firebase ID token as a Bearer token. Verification can be disabled for local development with `VERIFY_ID_TOKEN=false` (not recommended in production). Entitlement / subscription state is expected to be checked client‑side (RevenueCat) and optionally asserted server‑side in future versions.

## 📡 API Summary (Current)
| Method | Path              | Description                              | Auth |
|--------|-------------------|------------------------------------------|------|
| GET    | /healthz          | Liveness/env check                       | No   |
| GET    | /usage            | Returns daily count & limits             | Yes  |
| POST   | /chat             | Ask Mara (message, optional lang)        | Yes  |
| POST   | /files/analyze    | Placeholder for file URL analysis        | Yes  |

Example `POST /chat` body:
```json
{ "message": "Tengo dolor de cabeza y fiebre", "lang": "es" }
```
Response (simplified):
```json
{ "reply": "...", "source_lang": "es", "usage_left": 7 }
```

## ⚙️ Configuration (Backend Environment Variables)
| Variable | Purpose | Default |
|----------|---------|---------|
| APP_ENV | Environment label | dev |
| APP_NAME | Service title | Mara Backend |
| APP_ORIGINS | Comma list of CORS origins | * |
| PORT | HTTP port | 8000 |
| VERIFY_ID_TOKEN | Enforce Firebase ID token verification | true |
| FIREBASE_PROJECT_ID | Firebase project id | — |
| FIREBASE_CREDENTIALS_JSON_BASE64 | Base64 service account JSON | — |
| OPENAI_API_KEY | OpenAI key (if using OpenAI) | — |
| OPENAI_MODEL | Model name | gpt-4o-mini |
| HF_API_TOKEN | Hugging Face token | — |
| HF_INFERENCE_URL | Custom HF inference endpoint | — |
| FREE_DAILY_MESSAGES | Free quota messages | 10 |
| FREE_MAX_CHARS | Max characters per message | 500 |

Local secret management: create `.env` and export before running or use a process manager that loads env vars.

## 🧩 Backend: Run Locally
```
cd backend
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
cp .env.example .env  # (create one if not present) and fill values
uvicorn app.main:app --reload
```
Visit: http://localhost:8000/healthz

Prod (example):
```
gunicorn -k uvicorn.workers.UvicornWorker -c gunicorn_conf.py app.main:app
```

## 📱 Flutter App: Run Locally
Prerequisites: Flutter SDK (3.x), Xcode (iOS), Android Studio (Android), Firebase CLI.
```
cd marafinal
flutter pub get
flutter run  # select device
```
Make sure `firebase_options.dart` is generated (FlutterFire CLI) and `GoogleService-Info.plist` / `google-services.json` are present.

## 🧪 Testing
Flutter widget tests:
```
cd marafinal
flutter test
```
Backend (add tests folder in future): pytest (planned).

## 🔄 Quotas & Usage
`usage_store.py` currently uses an in-memory or placeholder approach; replace with persistent storage (Redis/Postgres) for production scaling and multi‑instance deployments.

## 🗺 Roadmap (High Level)
- [ ] Persistent usage + analytics storage
- [ ] File / lab report ingestion & structured extraction
- [ ] Enhanced risk triage prompts
- [ ] Subscription tier differentiation (limits & premium models)
- [ ] Edge / serverless deployment (Cloudflare Workers adapter or container)
- [ ] Offline smart mirror mode (local distilled model)

## 🤝 Contributing
1. Fork & branch (`feat/your-topic`)
2. Keep changes scoped & documented
3. Add/update tests where applicable
4. Open PR with description, screenshots (UI) or sample responses (API)

## � Security
Do not commit secrets. Rotate compromised keys immediately. For disclosures, email: `security@iammara.com`.

## 📜 License
MIT License. See `LICENSE` (add if missing).

## 👥 Team
- Abdulaziz Alkhlaiwe – Co‑founder, AI/Backend
- Omar – Co‑founder, Frontend

## 📬 Contact
Website: https://www.iammara.com
Email: contact@iammara.com

---
Made with care to make health knowledge more accessible.
