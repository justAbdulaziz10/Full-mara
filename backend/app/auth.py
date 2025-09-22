import firebase_admin
from fastapi import HTTPException, status
from firebase_admin import auth, credentials

from .config import decode_firebase_credentials, get_settings
from .logger import logger

_settings = get_settings()
if _settings.verify_id_token:
    if not firebase_admin._apps:
        cred_json = decode_firebase_credentials(_settings.firebase_credentials_json_base64)
        if cred_json:
            firebase_admin.initialize_app(credentials.Certificate(cred_json), {'projectId': _settings.firebase_project_id})
            logger.info("Firebase Admin initialized")
        else:
            logger.warning("VERIFY_ID_TOKEN=true but Firebase credentials not provided")


def verify_bearer(token: str) -> dict:
    if not _settings.verify_id_token:
        # DEV ONLY: accept token and return a fake user
        return {"uid":"dev-user", "email":"dev@example.com"}
    try:
        return auth.verify_id_token(token)
    except Exception:
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token")
