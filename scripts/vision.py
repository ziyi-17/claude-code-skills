#!/usr/bin/env python3
"""Vision helper — sends image to Gemini 3.5 Flash via OpenAI-compatible API."""

import sys, os, base64, json, urllib.request

MIME_MAP = {
    ".png": "image/png", ".jpg": "image/jpeg", ".jpeg": "image/jpeg",
    ".gif": "image/gif", ".webp": "image/webp", ".bmp": "image/bmp",
}

def analyze_image(image_path, prompt):
    api_key = os.environ.get("GEMINI_API_KEY")
    api_url = os.environ.get("GEMINI_API_URL", "")
    model = os.environ.get("GEMINI_MODEL", "")

    if not api_key:
        return "ERROR: GEMINI_API_KEY not set — add it in ~/.claude/settings.json → env"
    if not api_url:
        return "ERROR: GEMINI_API_URL not set — add it in ~/.claude/settings.json → env"
    if not model:
        return "ERROR: GEMINI_MODEL not set — add it in ~/.claude/settings.json → env"
    if not os.path.exists(image_path):
        return f"ERROR: File not found: {image_path}"

    ext = os.path.splitext(image_path)[1].lower()
    mime_type = MIME_MAP.get(ext, "image/png")

    with open(image_path, "rb") as f:
        b64 = base64.b64encode(f.read()).decode()

    body = {
        "model": model,
        "messages": [
            {
                "role": "system",
                "content": "You are an image description assistant. Describe ONLY what you can actually see in the image. Do NOT guess, fabricate, or invent details that are not clearly visible. If something is ambiguous, blurry, or partially occluded, state that honestly. Do not fill in gaps with assumptions — missing information is better than made-up information."
            },
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": prompt},
                    {"type": "image_url", "image_url": {"url": f"data:{mime_type};base64,{b64}"}}
                ]
            }
        ]
    }

    url = f"{api_url}/v1/chat/completions"
    req = urllib.request.Request(
        url,
        data=json.dumps(body).encode("utf-8"),
        headers={
            "Content-Type": "application/json",
            "Authorization": f"Bearer {api_key}",
            "User-Agent": "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/131.0.0.0 Safari/537.36",
            "Accept": "application/json",
            "Accept-Language": "zh-CN,zh;q=0.9,en;q=0.8",
        }
    )

    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            result = json.loads(resp.read())
    except urllib.error.HTTPError as e:
        body_snippet = e.read().decode("utf-8", errors="replace")[:500] if e.fp else ""
        return f"ERROR: HTTP {e.code}: {body_snippet}"
    except Exception as e:
        return f"ERROR: {e}"

    if "error" in result:
        return f"ERROR: {result['error'].get('message', result['error'])}"

    return result["choices"][0]["message"]["content"]

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print("Usage: python3 vision.py <image_path> [prompt]")
        sys.exit(1)
    prompt = " ".join(sys.argv[2:]) if len(sys.argv) > 2 else "请详细描述这张图片的内容"
    print(analyze_image(sys.argv[1], prompt))
