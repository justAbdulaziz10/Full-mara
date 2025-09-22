import base64
import json
import os
from functools import lru_cache

from pydantic import BaseModel


class Settings(BaseModel):
    app_env: str = os.getenv("APP_ENV", "dev")
    app_name: str = os.getenv("APP_NAME", "Mara Backend")
    app_origins: list[str] = os.getenv("APP_ORIGINS", "").split(",") if os.getenv("APP_ORIGINS") else ["*"]
    port: int = int(os.getenv("PORT", "8000"))
    verify_id_token: bool = os.getenv("VERIFY_ID_TOKEN", "true").lower() == "true"

    firebase_project_id: str | None = os.getenv("FIREBASE_PROJECT_ID")
    firebase_credentials_json_base64: str | None = os.getenv("FIREBASE_CREDENTIALS_JSON_BASE64")

    openai_api_key: str | None = os.getenv("OPENAI_API_KEY")
    openai_model: str = os.getenv("OPENAI_MODEL", "gpt-4o-mini")

    hf_api_token: str | None = os.getenv("HF_API_TOKEN")
    hf_inference_url: str | None = os.getenv("HF_INFERENCE_URL")

    free_daily_messages: int = int(os.getenv("FREE_DAILY_MESSAGES", "10"))
    free_max_chars: int = int(os.getenv("FREE_MAX_CHARS", "500"))


@lru_cache
def get_settings() -> Settings: return Settings()


def decode_firebase_credentials(b64: str | None):
    if not b64: return None
    return json.loads(base64.b64decode(b64).decode("utf-8"))
