# TODOS

## Junior skill

### Post review questions to the PR

**What:** Add `/junior ask <PR>` (reviewer posts the 3 understanding questions as PR comments via `gh`) and `/junior grade <PR>` (checks the author's answers in the thread and explains the gaps).

**Why:** The quiz is opt-in, and the team habit is "we merge anyway". Putting the questions on the PR makes the understanding check part of the workflow people already use before merging.

**Context:** This was Approach C in `docs/designs/junior-learning-loop.md`. It was deferred, not rejected, as the fallback if quiz usage stays low. Start from the `review` mode, which already generates the questions and answer keys; this adds posting and grading. It's outward-facing (posts to GitHub), so confirm before posting, and it only works in Claude Code.

**Effort:** M
**Priority:** P2
**Depends on:** The two-week check-in after the quiz-first release shows low quiz completion (Success Criteria, "Completed quizzes" row).

### Automate quiz evals

**What:** A script that runs `/junior` headless (`claude -p`, resuming the session for each turn) over `evals/fixtures/`, gives scripted answers, and scores the output against `evals/CHECKLIST.md` with an LLM-judge rubric.

**Why:** The release check is a manual checklist (eng-review D6). Manual checks get skipped once releases feel routine, and prompt regressions are behavioral, so they don't show up when you read the prompt diff.

**Context:** Deferred in eng-review D6 so nobody builds a harness while the prompt is still changing. Start from the regression contract in `evals/regression.md` (explain/scope/language), then the quiz rules (one question at a time, Break always asked, skip logged as `skipped`). Expect flakiness: assert on structure and grades, not exact wording.

**Effort:** M
**Priority:** P3
**Depends on:** The prompt stays unchanged for 2 releases after the two-week check-in.
