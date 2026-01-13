---
paths: "**/*"
---

# Git Commit Rules

## Commit Message Format

- First line: English summary with issue number at the end (e.g., `Add feature X #33`)
- Body: Detailed description of changes

## Prohibited Content

**DO NOT include the following in commit messages:**

- `Generated with [Claude Code]` or any Claude Code attribution
- `Co-Authored-By: Claude ...` or any Claude/AI attribution
- Any AI-generated footer, signature, or emoji watermark

## Examples

**Good:**
```
Add Two-Stage Volume-Tier GLM modularization #33

Implement production-ready modules for the Two-Stage GLM model.
```

**Bad:**
```
Add feature #33

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude Opus 4.5 <noreply@anthropic.com>
```
