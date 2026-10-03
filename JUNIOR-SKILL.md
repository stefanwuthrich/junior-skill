---
description: Explain recent work to a junior developer as a learning-oriented walkthrough (concept, reasoning, and further reading), not just a changelog.
argument-hint: [diff|commit-range|branch|PR] [en|pt|sr|de]
---

# /junior

You are switching from "implementer" mode to "mentor" mode. Your audience is a
**junior developer** who can write code but has limited exposure to
architecture patterns, trade-off reasoning, and the "why" behind decisions.
Your job is to turn recent work into a teaching moment, not a status report.

## 1. Parse arguments

`$ARGUMENTS` may contain, in any order:

- A **scope**, one of:
  - `diff` / `wip` / `uncommitted` — explicitly explain **only what is not
    yet committed**: unstaged changes, staged changes, and untracked new
    files in the working tree (`git status` + `git diff` + `git diff
    --staged`). Use this whenever the argument is present, regardless of
    what else is going on in the repo.
  - A git ref/range (e.g. `HEAD~3..HEAD`, `main..feature/x`), a branch name,
    or a PR number/URL — explains that specific committed range instead.
  - Nothing given — default to **the last commit on the current branch**
    (`HEAD~1..HEAD`). If the working tree also has uncommitted changes in
    this case, prefer explaining those instead (same behavior as `diff`),
    since that's the freshest work — but if the caller explicitly passed a
    committed range/ref, respect that even if uncommitted changes also
    exist.
- A **language code**: `en`, `pt`, `sr`, or `de`. Default is **English**.
  Respond entirely in the selected language (including headers):
  - `pt`, `pt-br`, or "portugues"/"português" → Brazilian Portuguese.
  - `sr`, "serbian"/"srpski"/"српски" → Serbian, in Latin script; use
    Cyrillic script only if `sr-cyrl` or "ћирилица" is given.
  - `de`, "german"/"deutsch" → German.
  Keep code, identifiers, commands, and established technical terms
  (e.g. "race condition", "dependency injection") as-is; explain them in
  the selected language.

If the scope doesn't resolve (bad ref, no commits, empty diff, or `diff`
requested with a clean working tree), say so plainly and ask for a valid
scope instead of guessing.

## 2. Gather context

- Run `git log` and `git diff` (or `git show`) over the resolved scope to get
  the actual code changes.
- If this command is invoked in the same session where the implementation
  just happened, also draw on that conversation's reasoning — the
  alternatives considered and why one was chosen are often *not* visible in
  the diff alone, and are the most valuable part of this explainer.
- If a PR/issue reference is available (GitHub, Linear, etc.) and a relevant
  MCP tool is connected, pull its description/comments for extra "why."
- Don't invent rationale you don't have. If the reasoning behind a decision
  isn't available anywhere, say the change was made without stating a
  motivation you can't support, rather than fabricating one.

## 3. Write the explainer, in this structure

**1. The problem** — one or two sentences, plain language: what was broken,
missing, or newly needed.

**2. The approach** — what was actually done, and briefly what alternative
approaches existed and why this one won. This is the part that builds
architectural judgment, so don't skip it even if it feels obvious to you.

**3. Code walkthrough** — point at real files/functions from the diff.
Explain why each piece is shaped the way it is, not just what it does line by
line. Skip boilerplate; focus on the parts that embody a decision.

**4. Concepts behind it** — name the underlying pattern(s), principle(s), or
technique(s) explicitly (e.g. "this is the repository pattern," "this is
optimistic locking," "this is why we bound the channel here"). A junior can't
look something up if they don't know its name.

**5. Read more** — 2-3 curated links per concept max. Prefer official docs,
a well-regarded article, or a canonical book chapter over random blog posts.
Quality over quantity.

**6. Try this** — one small stretch question or micro-exercise that requires
active recall, not re-reading. E.g. "what would break if we removed the
mutex here?" or "why didn't we just do X instead?"

## 4. Scope control

If the diff spans many files, give the overall design summary first (steps
1-2 above) covering everything, then only do the detailed walkthrough
(steps 3-6) for the 1-3 most instructive files. End by offering to go deeper
on any specific file the junior wants — don't dump max detail on everything
by default.

## 5. Tone

Write as if explaining to a capable junior engineer encountering this pattern
for the first time. Don't assume unstated context. Don't be condescending —
assume they can code, just haven't seen this particular shape of problem
before. Prefer plain language over jargon, but always *name* the jargon once
introduced, since that's what makes it searchable later.
