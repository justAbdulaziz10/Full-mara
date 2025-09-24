# app/main.py
from fastapi import Body, Depends, FastAPI, HTTPException, Request
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from .auth import verify_bearer
from .config import get_settings
from .db import supabase
from .mara_client import ask_mara_doctor
from .translate import detect_lang, from_en, to_en
from .usage_store import get_usage, inc_usage

settings = get_settings()
app = FastAPI(title=settings.app_name)

app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.app_origins,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


# -------- Models --------
class ProfileIn(BaseModel):
    name: str | None = None
    age: int | None = None
    gender: str | None = None
    blood_type: str | None = None
    height: float | None = None
    weight: float | None = None
    subscription: str | None = None


class HealthIn(BaseModel):
    metric: str
    value: float | None = None
    unit: str | None = None
    source: str | None = None
    meta: dict | None = None


# -------- Basic --------
@app.get("/")
def root():
    return {"message": "Hello Mara 👋"}


@app.get("/healthz")
async def healthz():
    return {"ok": True, "env": settings.app_env}


# -------- Auth / Profile --------
@app.post("/auth/sync")
def sync_user(user=Depends(verify_bearer)):
    uid = user["uid"]
    email = user.get("email")
    supabase.table("users").upsert({"id": uid, "email": email}).execute()
    return {"status": "ok", "uid": uid, "email": email}


@app.get("/profile/me")
def get_my_profile(user=Depends(verify_bearer)):
    uid = user["uid"]
    res = supabase.table("users").select("*").eq("id", uid).single().execute()
    return res.data


@app.put("/profile/me")
def update_my_profile(payload: ProfileIn, user=Depends(verify_bearer)):
    uid = user["uid"]

    patch_src = payload.model_dump if hasattr(payload, "model_dump") else payload.dict
    patch = {k: v for k, v in patch_src().items() if v is not None}
    if not patch:
        raise HTTPException(status_code=400, detail="Nothing to update")
    patch["id"] = uid
    supabase.table("users").upsert(patch).execute()
    return {"status": "updated"}


# -------- Usage / Chat --------
@app.get("/usage")
async def usage(user=Depends(verify_bearer)):
    c, limit_, maxc = get_usage(user["uid"])
    return {"dailyCount": c, "dailyLimit": limit_, "maxChars": maxc}


@app.post("/chat")
async def chat(body: dict, request: Request, user=Depends(verify_bearer)):
    msg: str = (body.get("message") or "").strip()
    lang: str | None = body.get("lang")

    if not msg:
        raise HTTPException(status_code=400, detail="message required")

    c, limit_, maxc = get_usage(user["uid"])
    if c >= limit_:
        raise HTTPException(status_code=429, detail="Daily free limit reached")
    if len(msg) > maxc:
        raise HTTPException(status_code=400, detail=f"Message too long; max {maxc} chars")

    src = lang or await detect_lang(msg)
    en = await to_en(msg, src)
    ans_en = await ask_mara_doctor(en)
    out = await from_en(ans_en, src)
    inc_usage(user["uid"], 1)

    return {
        "reply": out,
        "source_lang": src,
        "target_lang": src,
        "usage_left": max(0, limit_ - c - 1),
    }


# -------- Conversations --------
@app.post("/conversations/send")
def add_message(
    role: str=Body(..., embed=True),
    message: str=Body(..., embed=True),
    user=Depends(verify_bearer),
):
    uid = user["uid"]
    if role not in ("user", "assistant", "system"):
        raise HTTPException(status_code=400, detail="role must be user/assistant/system")

    supabase.table("conversations").insert({
        "user_id": uid,
        "role": role,
        "message": message
    }).execute()
    return {"status": "stored"}


@app.get("/conversations/history")
def list_messages(limit: int=50, user=Depends(verify_bearer)):
    uid = user["uid"]
    res = (
        supabase.table("conversations")
        .select("*")
        .eq("user_id", uid)
        .order("created_at", desc=True)
        .limit(limit)
        .execute()
    )
    return res.data


# -------- Health Data --------
@app.post("/health/add")
def add_health_point(payload: HealthIn, user=Depends(verify_bearer)):
    uid = user["uid"]
    payload_src = payload.model_dump if hasattr(payload, "model_dump") else payload.dict
    supabase.table("health_data").insert({"user_id": uid, **payload_src()}).execute()
    return {"status": "stored"}


@app.get("/health/recent")
def health_recent(metric: str | None=None, limit: int=50, user=Depends(verify_bearer)):
    uid = user["uid"]
    q = (
        supabase.table("health_data")
        .select("*")
        .eq("user_id", uid)
        .order("timestamp", desc=True)
        .limit(limit)
    )
    if metric:
        q = q.eq("metric", metric)
    return q.execute().data


# -------- Files --------
@app.post("/files/analyze")
async def files_analyze(body: dict, user=Depends(verify_bearer)):
    # TODO: download from Firebase Storage (signed URL) and pass to Mara Doctor
    return {"status": "received", "file_url": body.get("file_url")}
