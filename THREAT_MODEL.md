# Mara Threat Model

Mara is an AI-powered health assistant that handles sensitive health information.  
This document outlines potential threats, risks, and mitigations to protect our users.

---

## 📌 Assets at Risk
- **User Data**: health questions, personal info, usage logs.  
- **AI Model Outputs**: medical responses, recommendations.  
- **Authentication & Keys**: Supabase, Firebase, API tokens.  
- **Infrastructure**: backend servers, databases, storage.  

---

## 🔒 Threat Categories
### 1. Data Breach
- **Risk**: Unauthorized access to medical or personal data.  
- **Mitigation**:  
  - Encrypted storage (Postgres on Supabase).  
  - `.env` for secrets, never committed to code.  
  - Role-based access control (RBAC).  

### 2. Man-in-the-Middle (MITM) Attacks
- **Risk**: Interception of user ↔ backend traffic.  
- **Mitigation**:  
  - Enforce HTTPS/TLS 1.3 everywhere.  
  - Certificate pinning in the Flutter app.  

### 3. Model Poisoning / Data Injection
- **Risk**: Adversaries inject malicious training data to corrupt AI outputs.  
- **Mitigation**:  
  - Validate and sanitize all training data.  
  - Keep model training pipeline private and monitored.  

### 4. Unauthorized API Usage
- **Risk**: Abuse of Mara API endpoints.  
- **Mitigation**:  
  - API keys with rate limits.  
  - User authentication with Firebase.  
  - Usage quota enforcement.  

### 5. Insider Threats
- **Risk**: Team members misusing access.  
- **Mitigation**:  
  - Principle of Least Privilege (POLP).  
  - Access logs & monitoring.  
  - Two-person approval (CODEOWNERS + branch protection).  

### 6. Dependency Vulnerabilities
- **Risk**: Security issues in open-source packages.  
- **Mitigation**:  
  - Regular dependency scans (`pip-audit`, `npm audit`).  
  - Dependabot enabled in GitHub.  

---

## 🛡️ Privacy Principles
- No data sold, shared, or logged beyond user consent.  
- Local-only processing on Mara Mirror (offline mode).  
- GDPR & Saudi Data Privacy Law alignment.  

---
