# 03 — Code style

**Purpose:** Record verified style rules and prevent invented conventions from being mistaken for project policy.

**Confidence note:** Verified against available Markdown on 2026-11-17. The code wins (see 16); no source code, formatter, or linter configuration exists in this checkout.

## Verified guidance

- `glider-specs/git-guidelines.md` requires imperative, sentence-case commit summaries of at most 50 characters, with a scope and no trailing period. The scope examples still use the template name `code-name`; replace it with the approved project identity before adopting them.
- The same guide says not to credit an AI agent as author of commits, tags, releases, or PRs.
- `handoff.md` asks for reasons beside rules, concrete paths, confidence labels, and preservation/credit of contributor additions in skills documents.

No language style, error handling, logging, comment, formatter, or test naming standard can be confirmed. Once code exists, cite its formatter/linter configuration and representative patterns here. Avoid prescribing a pattern without its failure mode: inconsistent handling would otherwise be guesswork, not project policy.
