import httpx

from .config import get_settings

_settings = get_settings()


async def ask_mara_doctor(en_text: str) -> str:
    if not _settings.hf_inference_url:
        return "Mara endpoint not configured."
    headers = {"Authorization": f"Bearer {_settings.hf_api_token}"} if _settings.hf_api_token else {}
    async with httpx.AsyncClient(timeout=60) as client:
        r = await client.post(_settings.hf_inference_url, headers=headers, json={"inputs": en_text})
        r.raise_for_status()
        js = r.json()
        return js.get("answer") or js.get("generated_text") or str(js)
