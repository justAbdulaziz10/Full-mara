# Firestore-backed daily counter with in-memory fallback
from datetime import datetime
from typing import Tuple

from .config import get_settings
from .logger import logger

_settings = get_settings()
try:
    from google.cloud import firestore
    _db = firestore.Client(project=_settings.firebase_project_id) if _settings.firebase_project_id else None
except Exception:
    _db = None

_inmem: dict[str, int] = {}


def _day_key() -> str: return datetime.utcnow().strftime("%Y-%m-%d")


def get_usage(uid: str) -> Tuple[int, int, int]:
    limit_, max_chars = _settings.free_daily_messages, _settings.free_max_chars
    key = f"{uid}:{_day_key()}"
    if _db is None:
        return (_inmem.get(key, 0), limit_, max_chars)
    doc = _db.collection("usage").document(uid).collection("daily").document(_day_key()).get()
    cnt = doc.to_dict().get("count", 0) if doc.exists else 0
    return (cnt, limit_, max_chars)


def inc_usage(uid: str, n: int=1) -> None:
    key = f"{uid}:{_day_key()}"
    if _db is None:
        _inmem[key] = _inmem.get(key, 0) + n
        return
    ref = _db.collection("usage").document(uid).collection("daily").document(_day_key())
    _db.run_transaction(lambda tx: _inc_tx(tx, ref, n))


def _inc_tx(tx, ref, n):
    snap = tx.get(ref)
    data = snap.to_dict() if snap.exists else {}
    data["count"] = int(data.get("count", 0)) + n
    tx.set(ref, data)
