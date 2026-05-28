#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CLAUDE_DIR="${HOME}/.claude"
SKILLS_DIR="${CLAUDE_DIR}/skills/vision"
SCRIPTS_DIR="${CLAUDE_DIR}/scripts"
SETTINGS_FILE="${CLAUDE_DIR}/settings.json"

echo "=== Claude Code Vision Skill Installer ==="
echo ""

# 1. Create directories
mkdir -p "${SKILLS_DIR}" "${SCRIPTS_DIR}"

# 2. Copy skill definition
cp "${SCRIPT_DIR}/skills/vision/SKILL.md" "${SKILLS_DIR}/SKILL.md"
echo "[OK] Installed skill: ${SKILLS_DIR}/SKILL.md"

# 3. Copy vision script
cp "${SCRIPT_DIR}/scripts/vision.py" "${SCRIPTS_DIR}/vision.py"
chmod +x "${SCRIPTS_DIR}/vision.py"
echo "[OK] Installed script: ${SCRIPTS_DIR}/vision.py"

# 4. Configure settings.json
if [ ! -f "${SETTINGS_FILE}" ]; then
    echo '{}' > "${SETTINGS_FILE}"
fi

python3 - "$@" <<'PYEOF'
import json, os, sys

settings_file = os.path.expanduser("~/.claude/settings.json")

with open(settings_file) as f:
    config = json.load(f)

env = config.setdefault("env", {})

# API Key
if "GEMINI_API_KEY" not in env:
    key = os.environ.get("GEMINI_API_KEY", "")
    if not key:
        key = input("Enter your Gemini API key (or press Enter to skip): ").strip()
    if key:
        env["GEMINI_API_KEY"] = key
        print(f"[OK] Set GEMINI_API_KEY")
    else:
        print("[SKIP] GEMINI_API_KEY not set — add it manually in ~/.claude/settings.json")
else:
    print("[OK] GEMINI_API_KEY already configured")

# API URL
if "GEMINI_API_URL" not in env:
    url = os.environ.get("GEMINI_API_URL", "https://api.ikuncode.cc")
    env["GEMINI_API_URL"] = url
    print(f"[OK] Set GEMINI_API_URL={url}")
else:
    print("[OK] GEMINI_API_URL already configured")

# Model
if "GEMINI_MODEL" not in env:
    model = os.environ.get("GEMINI_MODEL", "gemini-3.5-flash")
    env["GEMINI_MODEL"] = model
    print(f"[OK] Set GEMINI_MODEL={model}")
else:
    print("[OK] GEMINI_MODEL already configured")

with open(settings_file, "w") as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
    f.write("\n")
PYEOF

echo ""
echo "=== Done! ==="
echo "If you didn't enter an API key, add it manually:"
echo "  In ~/.claude/settings.json → env, set GEMINI_API_KEY"
