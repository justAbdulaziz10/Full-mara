# Mara Project Architecture

This document describes the high-level system architecture of the Mara project, covering its components, integrations, and data flow.  
Mara is designed with **privacy, modularity, and scalability** as core principles.

---

## 1. Overview

Mara consists of three major layers:

1. **Frontend (Mobile App & UI Layer)**  
   - Flutter-based mobile application (iOS & Android).  
   - Multilingual interface.  
   - Provides symptom input, chat interaction, health tracking dashboard.  
   - Communicates with backend via secure HTTPS REST APIs.

2. **Backend (Service Layer)**  
   - Built with **FastAPI** (Python).  
   - Handles authentication, request validation, rate limiting, translation, AI inference.  
   - Integrated with external services for analytics and monitoring.  
   - Deployed on **Cloudflare Workers** for scalability and latency reduction.  

3. **AI & Data Layer**  
   - MaraDoctor model: a custom GPT-like model trained on medical datasets (HealthTap, Mayo Clinic Q&A, PubMed, RxNorm, WHO).  
   - PostgreSQL database hosted on **Supabase** for secure storage of metadata, user usage, and analytics.  

---

## 2. Data Flow

1. **User Input**  
   - Text or voice entered through mobile app.  

2. **Backend Processing**  
   - FastAPI validates request → detects input language → translates (if needed).  
   - Queries MaraDoctor for health reasoning.  

3. **Response Delivery**  
   - Results translated back to user’s language.  
   - Delivered via secure JSON response to mobile app.  
   - Stored securely (if user consented) for history & personalization.

---

## 3. Security Principles

- End-to-end encryption (HTTPS).  
- Sensitive data **never logged** in raw format.  
- .env secrets management for keys/tokens.  
- Threat model documented in [THREAT_MODEL.md](THREAT_MODEL.md).  

---

## 4. External Integrations

- **Supabase (PostgreSQL)** → Persistent storage.  
- **RevenueCat** → Subscription & payment management.  
- **Apple Health / Google Fit** → (Future) health data integration.  

---

## 5. Future Plans

- Integration with Saudi SFDA compliance systems.  
- Expansion to support web dashboard.  

---

_Last updated: September 2025_