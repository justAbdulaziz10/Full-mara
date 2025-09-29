# Mara API Reference

FastAPI backend for the Mara health assistant.  
All endpoints are JSON over HTTPS.

- **Base URL (prod)**: `https://api.iammara.com`  
- **Base URL (dev)**: `http://127.0.0.1:8000`

Auth is via **Firebase ID token** in the `Authorization` header:

```
Authorization: Bearer <FIREBASE_ID_TOKEN>
Content-Type: application/json
```

---

## Versioning

- Header: `X-Mara-Version: 0.1.0`  
- Semantic versioning; breaking changes bump **major**.

---

## Error Envelope

```json
{
  "code": "RATE_LIMIT_EXCEEDED",
  "message": "Daily message quota reached for your plan.",
  "trace_id": "f9b1e6e0-2b2a-4b1f-a0d1-2268b0c6b2a1",
  "details": { "limit": 200 }
}
```

| Field     | Type   | Notes                               |
|-----------|--------|-------------------------------------|
| code      | string | Machine-readable error code         |
| message   | string | Human-readable message              |
| trace_id  | string | For support/log correlation         |
| details   | object | Optional, context-specific          |

Common codes: `UNAUTHORIZED`, `FORBIDDEN`, `RATE_LIMIT_EXCEEDED`, `VALIDATION_ERROR`, `SERVER_ERROR`, `TRANSLATION_FAILED`, `AI_TIMEOUT`.

---

## Health & Meta

### `GET /healthz`
Check API health.

**Auth**: not required  

**200 Response**
```json
{ "status": "ok", "uptime_s": 12345, "commit": "abc123" }
```

---

### `GET /version`
Get API and model versions.

**Auth**: not required  

**200 Response**
```json
{ "api": "0.1.0", "model": "maraDoctor-gpt2-2025-07", "build_time": "2025-09-28T20:00:00Z" }
```

---

## Authentication

### `POST /auth/verify`
Verify a Firebase ID token and return a Mara user.

**Request**
```json
{ "id_token": "<FIREBASE_ID_TOKEN>" }
```

**200 Response**
```json
{
  "user": {
    "id": "7d8c7c1a-7c7f-4d39-9a3b-0e6b6e35c111",
    "firebase_uid": "8jS3...xY",
    "created_at": "2025-09-20T19:55:12Z",
    "plan": "free"
  }
}
```

**401** if invalid or expired.

---

## Q&A (Mara Doctor)

### `POST /ask`
Ask a health question in any language.  
Backend normalizes → EN → model → original language.

**Request**
```json
{
  "query": "صداع شديد من يومين وغثيان",
  "context": {
    "age": 21,
    "sex": "male",
    "known_conditions": ["allergy"],
    "medications": [],
    "locale": "ar-SA"
  },
  "safety": { "disclaimers": true, "triage_hints": true },
  "metadata": { "client": "flutter-1.0.3", "platform": "ios" }
}
```

**200 Response**
```json
{
  "answer": "قد يكون الصداع مرتبطًا بالتوتر أو الجفاف...",
  "language": "ar",
  "sources": [
    { "name": "Mayo Clinic", "type": "reference" },
    { "name": "WHO", "type": "reference" }
  ],
  "extras": {
    "triage": "Seek urgent care if severe neck stiffness, fever, or vision loss.",
    "disclaimer": "Mara is not a replacement for a licensed clinician."
  },
  "usage": { "remaining_today": 9, "plan": "free" },
  "trace_id": "a4e5c6fa-1b21-4c67-94fb-4b3e6d2f2e11"
}
```

**429** if quota exceeded.

---

## Translation Utilities

### `POST /translate/detect`
Detect text language.

**Request**
```json
{ "text": "Tengo dolor de cabeza" }
```

**200 Response**
```json
{ "language": "es", "confidence": 0.98 }
```

---

### `POST /translate/to_en`
Translate text → English.

**Request**
```json
{ "text": "صداع وغثيان", "source_lang": "auto" }
```

**200 Response**
```json
{ "text_en": "Headache and nausea", "detected": "ar" }
```

---

### `POST /translate/from_en`
Translate English → target language.

**Request**
```json
{ "text_en": "Increase water intake.", "target_lang": "ar" }
```

**200 Response**
```json
{ "text": "زِد من شرب الماء.", "target_lang": "ar" }
```

---

## Usage & Plans

### `GET /me/usage`
Get today’s usage and plan.

**200 Response**
```json
{
  "date": "2025-09-28",
  "messages_today": 1,
  "plan": "free",
  "limits": { "daily_messages": 10 }
}
```

---

### `POST /me/plan/sync`
Sync plan entitlements from RevenueCat.

**Request**
```json
{ "external_user_id": "firebaseUid", "entitlement": "pro_monthly" }
```

**200 Response**
```json
{ "plan": "paid_monthly", "updated_at": "2025-09-28T20:05:00Z" }
```

---

## Analytics

### `POST /telemetry/event`
Log anonymous events (no PHI).

**Request**
```json
{
  "event": "ask_opened",
  "properties": { "platform": "ios", "app_version": "1.0.3" }
}
```

**200 Response**
```json
{ "ok": true }
```

---

## Admin (Restricted)

### `GET /admin/users`
List users.

**200 Response**
```json
{
  "items": [
    { "id": "uuid-1", "plan": "free", "created_at": "..." },
    { "id": "uuid-2", "plan": "paid_monthly", "created_at": "..." }
  ],
  "page": 1,
  "page_size": 50,
  "total": 1234
}
```

---

### `GET /admin/usage/daily?date=2025-09-28`
Daily usage summary.

**200 Response**
```json
{ "date": "2025-09-28", "total_messages": 842, "active_users": 311 }
```

---

## Rate Limiting

Headers on `/ask`:

```
X-RateLimit-Limit: 10
X-RateLimit-Remaining: 9
X-RateLimit-Reset: 2025-09-28T23:59:59Z
```

---

## OpenAPI

FastAPI auto-docs:

- Swagger UI: `/docs`  
- ReDoc: `/redoc`  
- JSON spec: `/openapi.json`

---

## Deprecation Policy

- Deprecated endpoints include:  
  `Deprecation: true`  
  `Sunset: <RFC3339 timestamp>`

---
