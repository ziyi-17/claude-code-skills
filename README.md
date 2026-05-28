# Claude Code Skills

Personal Claude Code skills collection.

## Skills

### vision
Auto-route image recognition to Gemini 3.5 Flash when the current model lacks multimodal vision.
Works with any OpenAI-compatible API endpoint.

## Install

```bash
git clone https://github.com/ziyi-17/claude-code-skills.git
cd claude-code-skills
./install.sh
```

The installer will ask for:
- **API URL** — your OpenAI-compatible endpoint (e.g. `https://api.ikuncode.cc`)
- **Model name** — the vision model to use (e.g. `gemini-3.5-flash`)
- **API key** — your API key

All values can also be pre-set via environment variables: `GEMINI_API_URL`, `GEMINI_MODEL`, `GEMINI_API_KEY`.

## Update

```bash
cd claude-code-skills
git pull
./install.sh
```

## Requirements

- Python 3 (built into macOS / most Linux distros)
- An OpenAI-compatible vision API endpoint with a supported model
