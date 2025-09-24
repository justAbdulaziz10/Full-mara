import os
from typing import Optional

import firebase_admin
from dotenv import load_dotenv
from fastapi import Header, HTTPException, status

from .config import decode_firebase_credentials, get_settings
from .logger import logger

load_dotenv()

_settings = get_settings()
if _settings.verify_id_token:
    if not firebase_admin._apps:
        cred_json = decode_firebase_credentials(_settings.firebase_credentials_json_base64)
        if cred_json:
            firebase_admin.initialize_app(credentials.Certificate(cred_json), {'projectId': _settings.firebase_project_id})
            logger.info("Firebase Admin initialized")
        else:
            logger.warning("VERIFY_ID_TOKEN=true but Firebase credentials not provided")


def verify_bearer(authorization: str=Header(...)) -> dict:
    if not _settings.verify_id_token:
        return {"uid": "dev-user", "email": "dev@example.com"}

    if not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing Bearer token")

    token = authorization.split(" ", 1)[1].strip()

    try:
        from firebase_admin import auth
        return auth.verify_id_token(token)
    except Exception:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
