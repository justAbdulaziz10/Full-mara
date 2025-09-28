# Mara — System Architecture

Mara is an AI-powered health assistant available as a **mobile app (Flutter)** and an **offline-first smart mirror**.  
This document describes the high-level components, data flows, security model, and deployment topology.

---

## 1) High-Level Overview

**Core goals**
- Safe, multilingual health guidance (text/voice)  
- Privacy-first by design (minimal data, encrypted everywhere)  
- Works online (App) and offline (Mirror)

[Flutter App]  <—HTTPS—>  [FastAPI Backend]  <—>  [AI Services / ask_mara]
|
+—> [Supabase (Postgres, Auth metadata)]
|
+—> [3rd-party trusted health sources*]
|
+—> [Object Storage (secure files/logs)]

[Smart Mirror (Offline mode)]
└─ Local models (NLP, vision, emotion)
└─ Local encrypted store
└─ Optional sync -> Backend (opt-in)

\* Examples: WHO, Mayo, RxList, RxNorm (read-only ingestion or citation where allowed).

---

## 2) Components

### 2.1 Flutter App (`marafinal/`)
- Multilingual UI (RTL/LTR), voice & text input
- Auth with Firebase (ID token) → exchanged to backend session
- Features: symptom guidance, reminders, history (private), basic analytics
- Optional integrations: Calendar, Spotify (later), Email (later)

### 2.2 Backend (FastAPI) (`backend/app/`)
- **Routers/Endpoints**: auth, messages, usage, translation, analytics-lite
- **Services**
  - `ask_mara_doctor`: orchestrates AI Q&A and safety layers
  - `translate`: detect language; route to/from English when needed
  - `usage_store`: per-user quotas/rate limits
  - `logger`: audit and security logging (PII-safe)
- **DB (Supabase / Postgres)**:
  - Users (UID, minimal profile)
  - Usage counters & quotas
  - Optional: consent records, device links
- **Security**
  - Firebase ID token verification
  - RBAC/ABAC for admin ops
  - Input validation & content safety filters
  - Encrypted secrets via `.env`

### 2.3 AI Layer (`mara_client` + local/remote models)
- **ask_mara** wrapper:
  - Normalizes prompts (multi-lang → EN) then answers in user language
  - Adds medical safety/guardrails and cites sources when possible
- **Vision/Emotion (Mirror & future App)**
  - Local real-time face/skin analysis (on-device where possible)
  - Aggregated insights only (no raw frames sent by default)

### 2.4 Smart Mirror (Offline)
- Runs on Raspberry Pi / small PC
- Local pipeline:
  - Wake word / push-to-talk → ASR → NLP → TTS
  - Face/skin/mood detectors (on-device)
  - Local encrypted KV/SQLite for preferences and reminders
- **No cloud dependency** by default. Optional opt-in sync with Backend.

---

## 3) Request Flow (App)

### 3.1 Symptom Q&A (happy path)
```mermaid
sequenceDiagram
    autonumber
    participant U as User (Flutter)
    participant A as App
    participant B as FastAPI
    participant T as Translate
    participant M as ask_mara
    participant S as Supabase

    U->>A: Enter symptom (any language)
    A->>B: POST /ask (Firebase ID token)
    B->>S: Verify user & quota
    B->>T: detect_lang + to_en(if needed)
    T-->>B: normalized prompt (EN)
    B->>M: ask_mara(prompt_en, safety=true)
    M-->>B: clinical-style answer (EN) + metadata
    B->>T: from_en(to user language)
    T-->>B: localized answer
    B->>S: inc_usage(user_id)
    B-->>A: 200 OK (answer + safe tips)
    A-->>U: Show answer

3.2 Authentication
	•	App obtains Firebase ID token
	•	Backend verifies token signature & expiry
	•	Session is stateless (JWT) or short-lived server session

⸻

4) Data Model (minimal)

Users
	•	id (uuid), firebase_uid, created_at

Usage
	•	user_id, date, messages_count, plan (free/monthly/annual)

Consents (optional)
	•	user_id, type, granted_at, version

Device Links (optional)
	•	user_id, mirror_id, last_sync_at

Personally identifying and medical data are minimized; store only what is essential for service & compliance.

⸻

5) Security & Privacy
	•	Transport: HTTPS/TLS 1.3, HSTS
	•	Secrets: .env (never committed), GitHub Encrypted Secrets, per-env vault
	•	Auth: Firebase ID token; server-side verification on each call
	•	Access: Principle of Least Privilege (DB roles, scoped keys)
	•	PII: Avoid logging; structured logs with redaction
	•	Data retention: configurable; default minimum retention
	•	Offline: Mirror stores locally, encrypted; sync is opt-in
	•	Disclosure: see SECURITY.md
	•	Threat model: see THREAT_MODEL.md

⸻

6) Deployment Topology

[Client]
  iOS / Android / Web (Flutter)

[Edge]
  CDN / WAF (DDoS, rate limits, bot protection)

[API]
  FastAPI (Gunicorn/Uvicorn)
  - autoscaling group
  - health checks
  - blue/green deploys

[Data]
  Supabase (Postgres, Row Level Security)
  Object Storage (encrypted at rest)

[Observability]
  Structured logs, metrics, alerts

	•	Environments: dev, staging, prod
	•	Feature flags for risky features
	•	Blue/green or canary for safe releases

⸻

7) CI/CD

GitHub Actions (.github/workflows/ci.yml)
	•	Lint & type checks (Python, Dart)
	•	Tests (pytest, flutter test)
	•	Build artifacts
	•	Secret scan (scripts/secret_scan.sh)
	•	Optionally: container build & push

CODEOWNERS + branch protection
	•	Founders must review before merge
	•	Require passing checks

⸻

8) Config & Env Vars

Backend (.env.example)

APP_NAME=Mara
APP_ORIGINS=["https://iammara.com","http://localhost:5173"]

FIREBASE_PROJECT_ID=
FIREBASE_CLIENT_EMAIL=
FIREBASE_PRIVATE_KEY=

SUPABASE_URL=
SUPABASE_ANON_KEY=
SUPABASE_SERVICE_ROLE_KEY=

RATE_LIMIT_PER_DAY_FREE=200
RATE_LIMIT_PER_DAY_PAID=unlimited
LOG_LEVEL=INFO

App (Flutter)
	•	lib/config.dart reads build-time vars (via flavors)

Mirror
	•	mirror_config.json (locale, wake word, TTS voice, offline model paths)

⸻

9) Error Handling & Safety
	•	Consistent error envelope: { code, message, details?, trace_id }
	•	Safety filters: medical disclaimers, emergency escalation hints
	•	Fallbacks:
	•	If translation fails → respond in original language with safe message
	•	If AI fails → cached FAQ or “try again” with no sensitive leakage

⸻

10) Roadmap Hooks
	•	Analytics: privacy-preserving aggregates (no raw content)
	•	Payments: RevenueCat (entitlements → plan)
	•	Partners: clinics / universities (secure referral flow)
	•	Compliance: SFDA/MOH track; audit-ready logs and consents

⸻

11) Diagrams (Mermaid)

Context Diagram

graph TD
  U[User] -->|Voice/Text| A[Flutter App]
  A -->|HTTPS| B[FastAPI API]
  B --> S[(Supabase/Postgres)]
  B --> M[ask_mara AI]
  A --- O[Smart Mirror (Offline)]
  O -->|Local Models| O
  O -. Opt-in Sync .-> B

Data Lifecycle (App)

flowchart LR
  In[User Input] --> Norm[Normalize/Translate]
  Norm --> Ask[ask_mara]
  Ask --> Saf[Safety Filters]
  Saf --> Out[Localized Answer]
  Out --> Hist[(Minimal Usage Record)]

12) Non-Goals (for clarity)
	•	Not a replacement for licensed medical diagnosis
	•	No selling or sharing of user data
	•	No long-term raw media storage by default

⸻

13) References
	•	SECURITY.md — reporting & disclosure
	•	THREAT_MODEL.md — risks & mitigations
	•	CONTRIBUTING.md — how to contribute
	•	CODE_OF_CONDUCT.md — behavior & contributor terms
	•	CHANGELOG.md — release notes

  