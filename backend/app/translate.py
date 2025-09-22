import httpx

from .config import get_settings

_settings = get_settings()


async def detect_lang(text: str) -> str:
    return await _call_openai(f"Detect ISO 639-1 code only for this text:\n{text}", "You output ONLY the two-letter code.")


async def to_en(text: str, src: str | None=None) -> str:
    return await _call_openai(f"Translate to English, keep meaning, no extra text.\nText: {text}")


async def from_en(text: str, target: str) -> str:
    return await _call_openai(f"Translate the following English text into {target}.\nText: {text}")


async def _call_openai(prompt: str, system: str | None=None) -> str:
    if not _settings.openai_api_key: return prompt
    headers = {"Authorization": f"Bearer {_settings.openai_api_key}"}
    async with httpx.AsyncClient(timeout=30) as client:
        r = await client.post("https://api.openai.com/v1/responses", headers=headers, json={
            "model": _settings.openai_model,
            "input": prompt,
            "temperature": 0.2
        })
        r.raise_for_status()
        data = r.json()
        return data["output"][0]["content"][0]["text"] if "output" in data else data["choices"][0]["message"]["content"]
