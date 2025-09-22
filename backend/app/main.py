from fastapi import Depends, FastAPI, Header, HTTPException, Request, status
from fastapi.middleware.cors import CORSMiddleware

from .auth import verify_bearer
from .config import get_settings
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


def _require_user(authorization: str=Header(...)) -> dict:
    if not authorization.lower().startswith("bearer "):
        raise HTTPException(status_code=status.HTTP_401_UNAUTHORIZED, detail="Missing Bearer token")
    return verify_bearer(authorization.split(" ", 1)[1])


@app.get("/healthz")
async def healthz(): return {"ok": True, "env": settings.app_env}


@app.get("/usage")
async def usage(user=Depends(_require_user)):
    c, limit_, maxc = get_usage(user["uid"])
    return {"dailyCount": c, "dailyLimit": limit_, "maxChars": maxc}


@app.post("/chat")
async def chat(body: dict, request: Request, user=Depends(_require_user)):
    msg: str = (body.get("message") or "").strip()
    lang: str | None = body.get("lang")
    if not msg: raise HTTPException(400, "message required")

    c, limit_, maxc = get_usage(user["uid"])
    if c >= limit_: raise HTTPException(429, "Daily free limit reached")
    if len(msg) > maxc: raise HTTPException(400, f"Message too long; max {maxc} chars")

    src = lang or await detect_lang(msg)
    en = await to_en(msg, src)
    ans_en = await ask_mara_doctor(en)
    out = await from_en(ans_en, src)
    inc_usage(user["uid"], 1)

    return {"reply": out, "source_lang": src, "target_lang": src, "usage_left": max(0, limit_ - c - 1)}


@app.post("/files/analyze")
async def files_analyze(body: dict, user=Depends(_require_user)):
    # TODO: download from Firebase Storage (signed URL) and pass to Mara Doctor
    return {"status":"received", "file_url": body.get("file_url")}
