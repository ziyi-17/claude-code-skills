---
name: vision
description: Use when the current model lacks multimodal vision and the conversation shows [Unsupported Image], [Image: source: ...], or the user asks about an image file that cannot be processed natively
---

# Vision Skill

When the current model cannot process images natively, route them to Gemini 3.5 Flash via the helper script.

## Trigger

- `[Unsupported Image]` in conversation
- `[Image: source: /path/to/file.png]` in user message
- User asks about image content and you cannot see it

## Execution (MANDATORY)

```bash
python3 ~/.claude/scripts/vision.py "<image_path>" "<prompt>"
```

- Extract `image_path` from the `[Image: source: ...]` line in conversation
- Use user's question as `prompt`; if no specific question, use `"请详细描述这张图片的内容"`
- Use script stdout as your answer — do not paraphrase or interject

## Critical Rules

1. **Always re-run**: Every time the user asks anything about an image, you MUST call `vision.py` fresh. Never answer from previous conversation context or cached descriptions — even if you just saw the same image one message ago. Each query goes to the vision model independently.

2. **No hallucination**: The vision model is instructed to describe only what it actually sees. If the image lacks certain details, accept "not visible" or "unclear" — do not fabricate. When you relay the vision model's output, do not embellish or add interpretations beyond what was returned.

## Anti-Patterns

- Asking user to describe the image themselves
- Telling user to switch to a multimodal model
- Checking only file metadata (`ls`, `file`) and giving up
- Saying "I can't process images" without running the script

## Error Handling

| Error | Action |
|-------|--------|
| `GEMINI_API_KEY not set` | Tell user to add it in `~/.claude/settings.json` → `env` |
| `File not found` | Re-check the path from the conversation |
| `HTTP xxx` | Report the error, suggest checking API key validity |
