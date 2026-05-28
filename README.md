# Claude Code Skills

Personal Claude Code skills collection. Currently includes:

### vision
Auto-route image recognition to Gemini 3.5 Flash when the current model lacks multimodal vision. Works with any OpenAI-compatible API endpoint.

## Install

```bash
git clone https://github.com/ziyi-17/claude-code-skills.git
cd claude-code-skills
./install.sh
```

The installer will:
1. Copy skill definitions to `~/.claude/skills/`
2. Copy helper scripts to `~/.claude/scripts/`
3. Configure environment variables in `~/.claude/settings.json`
4. Prompt for your Gemini API key (or read from `GEMINI_API_KEY` env var)

## Update

```bash
cd claude-code-skills
git pull
./install.sh
```

## Requirements

- Python 3 (built into macOS / most Linux distros)
- Gemini API key (or any OpenAI-compatible vision API endpoint)
