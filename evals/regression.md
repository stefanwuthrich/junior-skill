# Regression check: `explain` stays what `/junior` used to be

Contract (eng-review D5): `explain` keeps the six sections in order, the scope
rules, the language rules, the honesty rule, and asking on an invalid scope.
The one intended change: bare `/junior` now starts a quiz.

## How to run

Run each command in a clone of this repo checked out at `de87581`. Install the
prompt as a project skill and keep it out of the diff:

```sh
git clone -q . /tmp/jr && git -C /tmp/jr checkout -q de87581
mkdir -p /tmp/jr/.claude/skills/junior
sed '0,/^---$/!b;a name: junior' JUNIOR-SKILL.md > /tmp/jr/.claude/skills/junior/SKILL.md
echo ".claude/" >> /tmp/jr/.git/info/exclude
```

For run 2, append the same 4-line "Troubleshooting" section to `README.md` in
the clone first, so there's one uncommitted change.

| # | Baseline (prompt at `de87581`) | Current prompt |
|---|---|---|
| 1 | `/junior 35b3196..de87581` | `/junior explain 35b3196..de87581` |
| 2 | `/junior diff de` (dirty tree) | `/junior explain diff de` (dirty tree) |
| 3 | `/junior nosuchref` | `/junior explain nosuchref` |

Headless: `claude -p "<command>" --allowedTools "Bash(git:*)" Read Grep Glob`.

## Pass when

1. Sections `1. The problem` through `6. Try this` appear in that order, and
   the walkthrough is limited to the 1-3 most instructive files.
2. Everything is in German with the same six sections. Only the uncommitted
   README change is explained, and identifiers stay untouched.
3. No walkthrough. It says the ref doesn't resolve, lists what exists, and
   asks which scope to use.

## Results

### 2026-10-22: quiz-first rewrite

| # | Baseline | Current | Verdict |
|---|---|---|---|
| 1 | Six sections in order; walkthrough of `JUNIOR-SKILL.md`, `README.md`, `.gitignore` | Six sections in order; same three files | PASS |
| 2 | German, six sections; explains only the README change | German, six sections; explains only the README change | PASS |
| 3 | Says `nosuchref` doesn't resolve, lists branches/commits, asks | Same; example commands now use `/junior explain` | PASS |
