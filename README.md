# Claude Code — personal skills & agents backup

Personal (user-level) Claude Code customizations. These live under `~/.claude/` on each machine
and are **not** part of any project repo.

## What's here

```
README.md                           # this file
install.ps1 / install.sh            # one-shot installers
claude/
  skills/
    migrate-feature/SKILL.md        # /migrate-feature <feature> — Opus plan → approve → default-model implement
    fdp-table-and-constants/SKILL.md# always-on: API tables get <fdp-report-table-skeleton>; literals go in @constants
  agents/
    feature-migration-planner.md    # Opus planning subagent used by /migrate-feature phase 1
```

`migrate-feature` depends on `feature-migration-planner` (it delegates planning to it) — install
both. `fdp-table-and-constants` is independent.

These wrap the **NextGenFDP.UI.Overhaul** repo's own `/migrate --feature` (`angular-migration`)
workflow; they assume that repo's `.claude/skills/` and `.claude/rules/` are present when they run.

## Where they install

| OS | Target |
| --- | --- |
| Windows | `%USERPROFILE%\.claude\` (e.g. `C:\Users\<you>\.claude\`) |
| macOS / Linux | `~/.claude/` |

Final layout on the new device:

```
~/.claude/skills/migrate-feature/SKILL.md
~/.claude/skills/fdp-table-and-constants/SKILL.md
~/.claude/agents/feature-migration-planner.md
```

## Import on a new device

### Option 0 — run the installer (fastest)

From this folder, after getting it onto the new machine:

```powershell
powershell -ExecutionPolicy Bypass -File .\install.ps1   # Windows
```

```bash
bash install.sh                                          # macOS / Linux / Git Bash
```

Both copy `claude/skills/*` and `claude/agents/*` into `~/.claude/`. The manual options below do
the same thing by hand.

### Option A — copy by hand

Copy the three files from `claude/...` here into the matching path under `~/.claude/...`,
creating folders as needed. Restart Claude Code (or run `/doctor`) so it re-scans.

### Option B — PowerShell (Windows)

```powershell
$src  = "C:\Users\Nino Carlo\source\repos\claudebackup\claude"   # adjust to where you cloned this
$dest = "$env:USERPROFILE\.claude"
Copy-Item "$src\skills\*" "$dest\skills\" -Recurse -Force
Copy-Item "$src\agents\*" "$dest\agents\" -Recurse -Force
```

### Option C — bash (macOS / Linux / Git Bash)

```bash
src="$HOME/source/repos/claudebackup/claude"   # adjust to where you cloned this
dest="$HOME/.claude"
mkdir -p "$dest/skills" "$dest/agents"
cp -R "$src/skills/." "$dest/skills/"
cp -R "$src/agents/." "$dest/agents/"
```

## Verify

1. Start Claude Code in any project.
2. `/help` or type `/` — `migrate-feature` and `fdp-table-and-constants` appear in the list.
3. Agent check: ask Claude to "list available agents" or start `/migrate-feature <feature>` —
   phase 1 should launch the `feature-migration-planner` subagent (runs on Opus).
4. If they don't show up: confirm the paths are exactly
   `~/.claude/skills/<name>/SKILL.md` and `~/.claude/agents/<name>.md`, then restart Claude Code.

## Notes

- A **personal** skill/agent overrides a project one of the same name. That's why the personal
  command is named `migrate-feature`, not `migrate` — a personal `migrate` would shadow the
  NextGenFDP repo's `/migrate` router.
- Nothing here needs a git commit into a project. Keeping this folder under version control is
  optional but recommended — re-run the import after any edit.
- To update the backup from a machine where you changed a skill, copy the reverse direction:
  `~/.claude/skills/... → claude/skills/...` here.
