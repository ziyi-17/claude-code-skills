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
