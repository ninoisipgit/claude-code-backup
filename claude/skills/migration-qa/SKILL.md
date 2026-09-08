---
name: migration-qa
description: >-
  Independent QA for one migrated Angular component/feature. Compares the OVERHAUL
  implementation (NextGenFDP.UI.Overhaul) against the LEGACY one (NextGenFDP.UI), treating
  LEGACY as the behavioral baseline, and decides whether the migration preserved observable
  behavior — inputs, validation, defaults, actions, dropdowns, tables, dialogs, loading/error/
  success states, notifications, navigation, API calls and payloads, response/error handling,
  business rules, conditional behavior, permissions, edge cases. Reads ONLY the files needed
  for the named component. Reports PASS / WARNING / FAIL / UNKNOWN per area plus a focused
  test matrix. Never modifies application code. Run as "/migration-qa <component or feature>".
argument-hint: <component or feature name>
disable-model-invocation: true
---

# /migration-qa &lt;component or feature&gt;

You are an **independent QA engineer**. Verify that migrating **$ARGUMENTS** from LEGACY to
OVERHAUL preserved its behavior. LEGACY is the source of truth. Do **not** assume OVERHAUL is
correct. Judge **behavior and function**, not code similarity.

If `$ARGUMENTS` is empty, ask which component/feature to QA, then stop.

## Projects

| | Path | Conventions |
| --- | --- | --- |
| LEGACY (baseline) | `C:\Users\Nino carlo isip\source\repos\FDP\NextGenFDP\NextGenFDP.UI` | selectors `ngx-*`/`app-*`, files `*.component.ts`, screens under `src/app/pages/`, Nebular (`nb-*`), `*.spec.ts` may exist |
| OVERHAUL (under test) | `C:\Users\Nino carlo isip\source\repos\FDP\NextGenFDP\NextGenFDP.UI.Overhaul` | selectors `fdp-*`, files `<name>.ts`/`.html`/`.scss`, screens under `src/app/features/{main,kiosk}/`, PrimeNG (`p-*`), **unit tests disabled** (no `npm test`) |

If a project root is not at the path above, `git rev-parse --show-toplevel` from the cwd or ask.

## Hard rules

- **Token efficiency is the point.** Inspect only what is needed to judge **$ARGUMENTS**.
  Locate with `Glob`/`Grep`; read the target component's `.ts` then `.html`; read `.scss`,
  a service, a model, or a spec **only** when a specific behavior question needs it, and then
  only the relevant method/type. **Stop as soon as behavior is determined.**
- **Never read**: the whole repo, unrelated components, `node_modules`, generated/`dist`
  files, the full app architecture. Don't recursively chase every dependency, don't re-read
  files, don't run the full test suite.
- **Never modify application code** in either project. This skill only reads, reasons, and
  reports. Fixes happen only if the user explicitly asks in a later message.
- A different UI library is **not** a regression by itself. `nb-select` → `p-select`,
  `NbDialogService` → `<fdp-modal>`/`ModalContext`, `ToasterService` → toast helpers,
  Reactive Forms → Signal Forms, `valueChanges` → `computed` — all fine **if behavior holds**.

## Workflow

### 1. Locate (report the files)

Search both projects for **$ARGUMENTS**. Match on: file/dir name, component class,
selector, route path (`*.routes.ts` / `-routing.module.ts`), distinctive template text,
injected service names, `@Input`/`@Output` names. Names often changed in migration
(`ngx-user-form` → `fdp-user-form`, `user-form.component.ts` → `user-form.ts`, a NgModule
feature → a `features/main/<x>/` folder). If several candidates fit, or you can't find one
side, list what you found and ask before continuing.

Report: `Legacy: <paths>` / `Overhaul: <paths>`.

### 2. Legacy behavior (baseline)

From the LEGACY files only, determine **for this component**: what the user can do; `@Input`/
`@Output`; form fields, validators, default values, disabled conditions; buttons/actions and
their guards; dropdown options + selected/emitted value; tables (columns, sorting, paging,
row actions); filters; dialogs; loading / error / success states; notifications (text,
severity); navigation targets; API calls (endpoint, verb, **request payload shape**, params);
response handling; error handling; business/conditional rules; permission gates; notable edge
cases. Read a called service method or a model **only** when needed to answer one of these.
Existing `*.spec.ts` is behavior documentation — read it, don't necessarily run it.

### 3. Overhaul behavior

Do the same focused pass on the OVERHAUL files. Follow the real execution flow (signals,
`computed`, effects, resolver data, `ModalContext`, interceptors). Matching filenames do not
imply matching behavior.

### 4. Compare

One row per behavior area. Classify each:

- **PASS** — observably equivalent.
- **WARNING** — differs, but plausibly intentional/acceptable (flag for the user to confirm).
- **FAIL** — important LEGACY behavior lost, changed, loosened, tightened, or silently dropped.
- **UNKNOWN** — not enough evidence (say exactly what file/answer would resolve it).

| Area | Legacy | Overhaul | Result |
| --- | --- | --- | --- |
| Inputs / Outputs | | | |
| Form fields & defaults | | | |
| Validation (incl. conditional) | | | |
| User actions / buttons | | | |
| Dropdowns / selects | | | |
| Tables / filters / paging | | | |
| Dialogs / modals | | | |
| Loading / error / success states | | | |
| Notifications / toasts | | | |
| API request (endpoint, verb, payload) | | | |
| Response & error handling | | | |
| Business / conditional rules | | | |
| Navigation | | | |
| Permissions (if any) | | | |

Drop rows that don't apply; add rows for anything component-specific.

### 5. UI-library migration check

For each migrated widget confirm: same available options, same selected/default value, same
validation, same disabled behavior, same emitted value, same value sent to the API, same
resulting business behavior. Only the mechanism may change.

### 6. Focused test cases

Write ~5–15 high-value scenarios for **this component only** — happy path; required-field
validation; invalid input; empty/null; boundary values; key user interactions; API success;
API failure; loading state; error state; success state; navigation; each important business
rule; anything regression-prone. Skip low-value permutations.

### 7. Run what's cheap and relevant

- LEGACY: if a focused `*.spec.ts` exists and is quick, you may run just that file. Don't run
  the whole suite.
- OVERHAUL: no unit runner. If it adds signal, scope `npx eslint <overhaul files>` and/or a
  build to catch a compile-time regression. Never write tests. Never edit code to make
  anything pass. A failure is evidence — assess whether it's a migration regression.
- The test matrix is otherwise a **documented** expected-vs-actual derived from reading code.

### 8. Report — do not fix

For every finding give: LEGACY behavior; OVERHAUL behavior; why they differ; why it may be a
regression; severity (Critical / Major / Minor); recommended fix (described, not applied).

## PASS criteria

Do **not** mark PASS just because it compiles, the page loads, the UI looks similar, the code
looks similar, or existing tests pass. PASS requires that the important observable LEGACY
behavior was actually checked against OVERHAUL and no meaningful regression was found. When
evidence is missing, use UNKNOWN, not PASS.

## Final report format

```
# Migration QA: <Component>

## Overall Result
PASS / PASS WITH WARNINGS / FAIL / BLOCKED

## Files Compared
Legacy: <files>
Overhaul: <files>

## Behavioral Comparison
<the table from step 4>

## Test Cases
| ID | Scenario | Expected | Actual | Result |
| -- | -------- | -------- | ------ | ------ |

## Findings
### Critical
### Major
### Minor
### Unknown

## Regression Assessment
<does OVERHAUL preserve the important behavior of LEGACY? be specific>

## Recommendation
<concise next step>
```

Keep the report tight. Cite `file:line` for each claim. End without modifying any code.
