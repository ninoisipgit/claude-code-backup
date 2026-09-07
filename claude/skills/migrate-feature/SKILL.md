---
name: migrate-feature
description: >-
  Two-phase Angular feature migration for the NextGenFDP.UI.Overhaul repo. Phase 1 is an Opus
  planning pass (plan only, no production code) that stops for your explicit approval; Phase 2
  implements the approved plan on your default model. Wraps the repo's existing
  "/migrate --feature" (angular-migration) logic without changing its rules. Run it as
  "/migrate-feature <feature>".
argument-hint: <feature>
disable-model-invocation: true
---

# /migrate-feature &lt;feature&gt;

A wrapper around this repo's existing feature-migration workflow
(`.claude/commands/migrate.md` → the `angular-migration` skill). It adds one thing: a hard
**plan → approve → implement** gate with the planning done on Opus and the coding done on your
default model.

**Do not change the underlying `angular-migration` rules. Reuse them verbatim.** This skill
only adds the gate.

Feature to migrate: **$ARGUMENTS**

If `$ARGUMENTS` is empty, ask which feature to migrate — a folder name under
`NextGenFDP.UI/src/app/pages/`, or an existing plan under `.claude/planner/features/` — then
stop and wait.

---

## Phase 1 — Planning (Opus, plan only)

1. Delegate planning to the **`feature-migration-planner`** subagent via the Agent tool
   (`subagent_type: "feature-migration-planner"`). It is defined at
   `~/.claude/agents/feature-migration-planner.md` and runs on **Opus independently of this
   session** — this session's model is untouched. Pass it the feature name `$ARGUMENTS`.
2. That subagent follows the `angular-migration` skill's **Planning mode**: it inspects the
   legacy code and the target codebase, inventories and classifies the files, flags shared
   dependencies and portal-boundary crossings, analyses the current implementation, identifies
   risks and breaking changes, decides the approach, produces a step-by-step implementation
   plan, and writes/updates the tracked checklist at
   `.claude/planner/features/<name>_features.md` plus its TOC row. It modifies **no**
   production code and runs **no** lint / build / test / review / fix.
3. When it returns, relay its **full plan** to me. Then **STOP.**

**Wait for my explicit approval before Phase 2.** Do not start implementing until I reply with
a clear go-ahead (e.g. "approve", "approved", "go", "yes"). If I ask for changes, run Phase 1
again — re-delegate to the planner with my changes — and stop for approval again.

---

## Phase 2 — Implementation (my default model)

Run this only after I approve.

1. This session was never switched off my default model — the Opus work happened entirely
   inside the Phase 1 subagent — so there is nothing to reset. **Do not call `/model`.**
2. Follow the `angular-migration` skill's **Migration mode** against the approved plan:
   - Migrate **shared dependencies first**, then the plan's items.
   - Rewrite code strictly to the `AGENTS.md` topic files that apply.
   - Apply the `fdp-table-and-constants` skill: every API-backed table gets
     `<fdp-report-table-skeleton>` while its fetch is in flight, and shared/config literals go
     in `src/app/constants` (`@constants`) — import an existing one or add it there, never
     inline.
   - Modify the necessary files and write the code.
   - Check off each item in `.claude/planner/features/<name>_features.md` as it lands, and
     keep that plan file's own Status current.
   - Keep existing behavior unless the migration requires a change; call out any change.
3. Verify: run `npm run lint` and `npm run build:local`. Fix implementation errors you
   introduced (see the `angular-fix` skill if lint/build is failing). Do not report success
   until both exit clean.
4. Report: plan file path, items completed, flags raised, lint result, build result.

---

## Rules

- Never run Phase 2 before I approve the plan.
- This skill never edits `.claude/` config, `angular.json`, or `package.json`.
- Writing/updating the `.claude/planner/features/<name>_features.md` checklist is expected —
  it is the existing Planning-mode artifact, not production code.
