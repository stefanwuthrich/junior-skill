# /junior release checklist

Run before re-uploading the skill. The skill is a prompt, so each line is a
run plus a judgment, not an assertion on exact text.

## Setup

```sh
F=$(mktemp -d)/fx && evals/make-fixtures.sh "$F"
mkdir -p "$F/.claude/skills/junior"
sed '0,/^---$/!b;a name: junior' JUNIOR-SKILL.md > "$F/.claude/skills/junior/SKILL.md"
echo ".claude/" >> "$F/.git/info/exclude"
cd "$F" && claude
```

For log checks, move your real log aside first and restore it afterwards.
Overriding `HOME` doesn't isolate them: Claude Code's Read and Write tools
resolve `~` to your real home directory and ignore `HOME`.

```sh
[ -e ~/.junior ] && mv ~/.junior ~/.junior.bak
mkdir -p ~/.junior && cp "$F/logs/log-open.md" ~/.junior/log.md   # or log-401.md
# ... run the log checks ...
rm -rf ~/.junior && { [ -e ~/.junior.bak ] && mv ~/.junior.bak ~/.junior || true; }
```

"Fresh log" below means `rm -rf ~/.junior` before the run.

`D` = `fx-decision~1..fx-decision`, `R` = `fx-rename~1..fx-rename`,
`M` = `fx-multi~1..fx-multi`.

## Checks

| # | Path | Run | Pass when |
|---|---|---|---|
| 1 | Bare `/junior` is a quiz | `git checkout -q fx-decision` then `/junior nolog` | First line offers `/junior explain`; one question about `charge()`; nothing else asked yet |
| 2 | Two modes → ask | `/junior quiz review` | Asks which mode; runs nothing |
| 3 | `onboard` takes a reserved word as path | `mkdir review && cp shop/cache.py review/ && /junior onboard review nolog` | Quizzes on `review/cache.py`; doesn't switch to review mode |
| 4 | `review` default base / empty range | On `main` (= `fx-multi`): `/junior review` | Names base `main`, says range is empty, suggests `quiz` |
| 5 | `nolog` ignored by `review`/`explain` | `/junior explain D nolog` | Normal walkthrough, no error, log untouched |
| 6 | Order Why → Break → Alt, level adapts | `/junior D nolog`, answer Q1 well, Q2 vaguely | Q2 is a Break question, harder than a one-liner; Q3 (Alt) stays at Q2's level after the partial |
| 7 | Tiny diff keeps Break | `/junior M nolog` on a one-decision slice, or `/junior D nolog` answering "skip" | At most 3 questions; if fewer, Alt dropped first and Break kept |
| 8 | Zero decisions → offer explain | `/junior R nolog` | Says there's nothing to quiz; offers `/junior explain` |
| 9 | Log created on first write | Fresh log: `/junior D`, answer all | `~/.junior/log.md` exists with one line per question |
| 10 | Slugs sanitized and reused | Seed `log-open.md`, `/junior D`, miss the idempotency question | Logged slug is `idempotency` (reused), kebab-case, no code text |
| 11 | Pruning keeps open slugs | Seed `log-401.md`, `/junior D`, answer all | Log has ≤400 lines and still contains `lost-update` |
| 12 | One question at a time, gap-only | `/junior D nolog`, answer every question | Never shows the next question or an answer early; `got it` gets one line, misses get concept + ≤2 links |
| 13 | Skip shows as missed, logs `skipped` | Fresh log, `/junior D`, reply "skip" to Q2 | Score shows it missed; log line grade is `skipped` |
| 14 | Understanding note from author's words | `/junior D nolog`, answer at least one right | Note starts "Based on your answers:" and uses your phrasing, not the explanations |
| 15 | `review` questions + answer keys | `/junior review D` | Questions in Why/Break/Alt order, each with file anchor and 2-3 answer-key points; no grading, nothing posted |
| 16 | `onboard` on a path | `/junior onboard shop nolog` | Prediction questions about `shop/`; no understanding note |
| 17 | Warm-up for an open concept ≥3 days old | Seed `log-open.md`, `/junior D` | Asks one warm-up about `idempotency` first; not about `cache-invalidation` (closed) |
| 18 | Warm-up not scored | Continue #17 to the end | Warm-up on its own line, not counted in the score; logged as `warmup` |
| 19 | Denied write → one line | Fresh log, `/junior D` without the allow rule, deny the write prompt | One-line notice; score and note still shown |
| 20 | Language in new modes | `/junior D de nolog` | Questions, grading and note in German; identifiers untouched |
| 21 | claude.ai fallback | Paste the `fx-decision` diff into claude.ai with the uploaded skill: "quiz me" | Quiz works; no log; ends by listing missed concepts |
| 22 | Regression: `explain` unchanged | See [regression.md](regression.md) | All three regression runs match the baseline |

Log the run at the bottom: date, prompt commit, pass/fail per number, notes.

## Runs

| Date | Prompt commit | Result | Notes |
|---|---|---|---|
| 2026-10-22 | quiz-first rewrite (uncommitted at run time) | 18/22 pass, 4 not run | Headless `claude -p`; multi-turn via `--session-id`/`--resume`. Pass: 1, 2, 3, 4, 5, 6, 8, 9, 11, 12, 13, 14, 15, 16, 17, 18, 20, 22. Not run: 7 (needs a one-decision slice), 10 (slug reuse with a missed seeded concept), 19 (denied write needs an interactive prompt), 21 (claude.ai). Fix during the run: the warm-up needed an explicit "read the log before the first question" step; one early run skipped it. 16: onboard's first question was a "why", not a prediction. |
