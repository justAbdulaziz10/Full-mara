# Mara Backend (FastAPI)
Endpoints:
- GET  /healthz
- GET  /usage
- POST /chat
- POST /files/analyze  (optional)
Auth: Bearer Firebase ID token (can be disabled via VERIFY_ID_TOKEN=false).
Run (dev):
  pip install -r requirements.txt
  cp .env.example .env  # fill values
  uvicorn app.main:app --reload
Prod:
  gunicorn -k uvicorn.workers.UvicornWorker -c gunicorn_conf.py app.main:app
