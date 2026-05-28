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

python3 "$@" <<'PYEOF'
import json, os

settings_file = os.path.expanduser("~/.claude/settings.json")

with open(settings_file) as f:
    config = json.load(f)

env = config.setdefault("env", {})

def ask(label, env_var, required=True, default=""):
    if env_var in env:
        print(f"[OK] {env_var} already configured")
        return
    val = os.environ.get(env_var, "")
    if val:
        env[env_var] = val
        print(f"[OK] {env_var}={val} (from environment)")
        return
    hint = f" [default: {default}]" if default else ""
    while True:
        val = input(f"Enter {label}{hint}: ").strip()
        if not val and default:
            val = default
        if val or not required:
            break
        print(f"  {label} is required.")
    if val:
        env[env_var] = val
        print(f"[OK] {env_var}={val}")
    else:
        print(f"[SKIP] {env_var} not set")

print("\n--- API Configuration ---\n")

ask("API URL (OpenAI-compatible endpoint)", "GEMINI_API_URL", default="https://api.ikuncode.cc")
ask("Model name", "GEMINI_MODEL", default="gemini-3.5-flash")
ask("API key", "GEMINI_API_KEY")

with open(settings_file, "w") as f:
    json.dump(config, f, indent=2, ensure_ascii=False)
    f.write("\n")

print("\n--- All required values configured ---")
PYEOF

echo ""
echo "=== Done! ==="
