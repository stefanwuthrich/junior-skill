# junior-skill

A Claude Code skill that explains recent work to a junior developer as a learning-oriented walkthrough (concept, reasoning, and further reading), not just a changelog.

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

In a chat, ask Claude to explain the work to a junior developer, e.g. *"Explain this diff to a junior dev"*. Then paste or attach the diff, commit or PR content.

> **Note:** On claude.ai, Claude can't see your local git repository. Give it the diff or changes directly. The skill is most useful in Claude Code, where it can run `git` itself (see below).

## Install in Claude Code

Copy the skill into your personal skills directory:

```sh
mkdir -p ~/.claude/skills/junior
sed '0,/^---$/!b;a name: junior' JUNIOR-SKILL.md > ~/.claude/skills/junior/SKILL.md
```

To install it for a single project only, put it in `.claude/skills/junior/SKILL.md` inside that project.

Then run:

```
/junior                 # last commit, or uncommitted changes if there are any
/junior diff            # only uncommitted changes
/junior main..feature/x # a specific range
/junior HEAD~3..HEAD pt # answer in Brazilian Portuguese
/junior diff sr         # answer in Serbian (Latin; use sr-cyrl for Cyrillic)
/junior diff de         # answer in German
```

**Languages:** English (default), Brazilian Portuguese (`pt`), Serbian (`sr`; Latin script, or `sr-cyrl` for Cyrillic) and German (`de`). On claude.ai, ask for the language in your message.

## Branches

- `main`: stable
- `dev`: active development
