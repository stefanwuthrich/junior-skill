# junior-skill

A Claude Code skill that helps developers learn from recent (often AI-written) work. By default it quizzes you on your own diff, one question at a time, and explains only what you missed. It can also give the full learning-oriented walkthrough (concept, reasoning, further reading), generate questions for a reviewer, or quiz you on code you're new to.

Why quiz first: reading an explanation feels like learning but mostly isn't. Having to answer is what makes it stick. See [docs/designs/junior-learning-loop.md](docs/designs/junior-learning-loop.md).

## Install in a Claude Team account (claude.ai)

### 1. Check that skills are enabled (Owner)

An Owner of the Team organization opens **Organization settings → Plugins & skills**, goes to the **Policy** tab and enables both:

- **Cloud code execution and file creation**
- **Skills**

Without these settings, members can't upload or use skills.

### 2. Package the skill as a ZIP

claude.ai expects a ZIP that contains a folder named after the skill, with a `SKILL.md` file inside. That file needs `name` and `description` in its frontmatter:

```
junior.zip
└── junior/
    └── SKILL.md
```

Build it from this repo:

```sh
mkdir -p dist/junior
# Copy JUNIOR-SKILL.md and add the `name` field claude.ai requires
sed '0,/^---$/!b;a name: junior' JUNIOR-SKILL.md > dist/junior/SKILL.md
(cd dist && zip -r junior.zip junior)
```

The folder name (`junior`) must match the `name` field, or the upload fails with "Skill folder name doesn't match the skill name".

### 3. Upload the skill

**Just for you (any member):**

1. Go to **Customize → Skills**.
2. Click **+**, then **+ Create skill**.
3. Choose **Upload a skill** and select `dist/junior.zip`.
4. Make sure the skill is toggled on.

**For the whole team (Owner):**

Upload the ZIP under **Organization settings → Plugins & skills**. The skill then appears in every member's skills list with a team indicator, and each member can switch it on or off.

**To share with specific colleagues:** in **Customize → Skills**, open the skill's **⋯** menu and choose **Share**. Recipients get a view-only copy that updates whenever you change it.

### 4. Use it

In a chat, ask Claude to quiz you on your work, e.g. *"Quiz me on this diff"*, or to explain it, e.g. *"Explain this diff to a junior dev"*. Then paste or attach the diff, commit or PR content. For onboarding, paste the code you want to be quizzed on.

> **Note:** On claude.ai, Claude can't see your local git repository. Give it the diff or changes directly. The learning log (below) only works in Claude Code; on claude.ai the quiz lists the concepts you missed at the end instead. The skill is most useful in Claude Code, where it can run `git` itself (see below).

## Install in Claude Code

Copy the skill into your personal skills directory:

```sh
mkdir -p ~/.claude/skills/junior
sed '0,/^---$/!b;a name: junior' JUNIOR-SKILL.md > ~/.claude/skills/junior/SKILL.md
```

To install it for a single project only, put it in `.claude/skills/junior/SKILL.md` inside that project.

Then run:

```
/junior                         # quiz on the last commit, or on uncommitted changes if there are any
/junior diff                    # quiz on uncommitted changes only
/junior explain                 # the full six-part walkthrough instead of a quiz
/junior explain main..feature/x # walkthrough of a specific range
/junior review                  # questions + answer keys for a reviewer (branch vs. default branch)
/junior review 42               # same, for PR #42
/junior onboard src/billing     # quiz on how unfamiliar code works
/junior diff de                 # quiz in German
/junior explain HEAD~3..HEAD pt # walkthrough in Brazilian Portuguese
/junior diff sr nolog           # quiz in Serbian (Latin; sr-cyrl for Cyrillic), without the learning log
```

> **Changed:** bare `/junior` used to print the walkthrough. It now starts a quiz. Use `/junior explain` for the old behavior.

**Modes:**

- `quiz` (default): up to 3 questions about your diff, asked one at a time. First *why* it's shaped this way, then *what breaks if…* (always asked), then *why not the alternative*. Each answer is graded `got it` / `partial` / `missed`, and only the gaps get explained. Questions get harder or more concrete depending on your last answer. It ends with a score and a short "Based on your answers:" note you can paste into your PR description.
- `explain`: the walkthrough: problem, approach, code walkthrough, concepts, read more, try this.
- `review`: for reviewers. Prints the questions with answer keys so you can ask the author yourself. Grades nothing, posts nothing.
- `onboard <path>`: for anyone new to an area. Prediction questions about how the code behaves, graded the same way.

**Languages:** English (default), Brazilian Portuguese (`pt`), Serbian (`sr`; Latin script, or `sr-cyrl` for Cyrillic) and German (`de`). On claude.ai, ask for the language in your message.

### Learning log

In Claude Code, `quiz` and `onboard` keep a small log of the concepts you missed at `~/.junior/log.md`. It stores one line per question (date, repo folder name, mode, concept name, grade), never code. When a missed concept is 3 or more days old, the next quiz starts with one warm-up question about it. The log keeps the newest 400 lines, and concepts you haven't mastered yet are never dropped. Add `nolog` to skip the log for a run.

Claude Code asks permission before reading or writing outside your project. To skip those prompts, allow the log once in `~/.claude/settings.json` (or the `settings.json` in your `CLAUDE_CONFIG_DIR`):

```json
{
  "permissions": {
    "allow": ["Read(~/.junior/**)", "Edit(~/.junior/**)"]
  }
}
```

`Edit` covers the Write tool too; a `Write(...)` rule would be ignored. If you deny access, the quiz says so in one line and continues.

### Learn while you build

`/junior` works after the code exists. To learn *while* Claude writes code, turn on Claude Code's built-in Learning output style: `/config` → Output style → Learning. Claude then leaves small `TODO(human)` pieces for you to write.

### Testing changes to the skill

The skill is a prompt, so it's tested by running it. Before releasing a change, follow [evals/CHECKLIST.md](evals/CHECKLIST.md) and the regression check in [evals/regression.md](evals/regression.md).

## Branches

- `main`: stable
- `dev`: active development
