---
name: fdp-table-and-constants
description: >-
  Always-on coding conventions for the NextGenFDP.UI.Overhaul repo. Apply whenever you create
  or edit a table (p-table / data table / grid); whenever you are about to hardcode a value in
  a component (page sizes, date formats, message copy, option lists, min/max lengths, keys);
  and whenever you MIGRATE a form, field, input, or button from the legacy NextGenFDP.UI app.
  Rule 1: every API-backed table shows <fdp-report-table-skeleton> while its fetch is in flight.
  Rule 2: shared/config values live in src/app/constants (@constants), not inline. Rule 3:
  migrated forms match the legacy code exactly — input validation, button conditioning, input
  behaviour, every visible label / heading / column / button / message (wording, title case,
  spelling, punctuation), and padding / margin — nothing added, dropped, loosened, tightened,
  reworded, recased, or respaced without an explicit flagged deviation. Defers to the repo's
  own .claude/rules/*.md when present.
---

# FDP — tables, constants & migration fidelity

Conventions to apply while writing code in this repo. Where the repo has its own rule file
(`.claude/rules/report-table-skeleton.md`, `.claude/rules/where-code-goes.md`,
`.claude/rules/validation.md`, `.claude/rules/form-elements.md`), that file wins on the details —
this skill just makes sure the conventions are not skipped. Rules 1–2 apply to any code; Rule 3
applies when code is being **migrated** from the legacy `NextGenFDP.UI` app.

## Rule 1 — every API-backed table gets `<fdp-report-table-skeleton>`

Any table whose rows come from an API shows the skeleton in the table's place while that fetch
is in flight — same spot, same column count. Do **not** add another loading indicator to that
table (`<fdp-spinner>`, `<fdp-card [loading]>`, `p-table [loading]`, `isFetching()`, an overlay).

Use this shape, **adapting the values** to the actual table — `ariaLabel` names what is
loading, `[columns]` matches the real column count, `[minWidth]` keeps a wide table scrolling
inside its container rather than the page:

```html
@if (loadingList()) {
  <fdp-report-table-skeleton
    ariaLabel="Loading transfers"
    [columns]="13"
    [rows]="tableRows"
    [minWidth]="'84rem'"
  />
} @else {
  <!-- the real <p-table> -->
}
```

- Driven by a **local** `signal(true)` (`loadingList`, `loadingReport`, …) toggled off in
  `finalize()` on the list request — never the app-wide `isFetching()`, so an unrelated GET
  (print, Excel) cannot blank the grid. Those other actions keep their own button spinner.
- A table with hardcoded or already-resolved rows does **not** get a skeleton.
- Don't write a second table skeleton — widen this component if it is nearly right.
- Pagination (`createReportPagination()` + `<fdp-footer-paginator>`) and sortable columns
  (`pSortableColumn` / `p-sort-icon`) follow `.claude/rules/report-table-skeleton.md`.

## Rule 2 — shared/config values live in `src/app/constants`

Before hardcoding a literal in a component, check `src/app/constants/` (the `@constants`
barrel, `src/app/constants/index.ts`):

1. **It already exists** → import it from `@constants` and use it. Examples in
   `app.constants.ts`: `PAGINATION`, `DATE_FORMATS`, `PRIMENG_DATE_FORMATS`, `TOAST_DEFAULTS`,
   `AppMessages`, `MONTH_NAMES`, `SEARCH_LENGTH`, `THEME_OPTIONS`, `SCANNER_MODEL_OPTIONS`,
   `KIOSK_MODE_ROLES`. Feature-scoped files exist too (`manage-materials.constants.ts`,
   `communication.constants.ts`).
2. **It is genuinely new and reusable** (a magic number, format string, option list, message,
   min/max, key, role list, etc.) → add it there, not inline:
   - App-wide value → `app.constants.ts`.
   - Used by one feature → `<feature>.constants.ts` in the same folder.
   - Export it through `src/app/constants/index.ts`.
   - `as const`, `UPPER_CASE` name, one-line comment only if the "why" is non-obvious.
3. **Truly local initial state** (an `EMPTY_*` default-value object for a form draft) stays in
   the component — that is state, not a shared contract. Data *shapes* (`interface`/`type`)
   still go to `@models`, per `where-code-goes.md`.

Do not leave a new shared literal inline in a component, and do not paste a second copy of a
value that already has a constant.

## Rule 3 — migrated forms behave exactly like the legacy code

When a field, input, button, or form is being **migrated** from `NextGenFDP.UI`, its *behaviour*
is ported 1:1. The Overhaul mechanism modernises (Reactive → Signal Forms, `nb-*` → PrimeNG,
`valueChanges` → `computed`) but the observable behaviour does not change. Read the legacy
`.ts` **and** `.html` for the field before writing the new one.

**Validation — port every rule, on every field, under every condition.**

- Every legacy `Validators.required` / `requiredTrue` / `maxLength(n)` / `minLength(n)` /
  `min` / `max` / `pattern(...)` / `email`, and every custom `ValidatorFn`, gets an Overhaul
  equivalent on the same field: `requiredField` / `requireTrimmed` / `maxLengthField(path.x, n)`
  / `minLengthField` / `minField` / `maxField` / `pattern` / `emailField` / `notFutureField`, etc.
- **Runtime validator changes** carry over as conditional schema. Legacy
  `control.setValidators([...]) / clearValidators() / updateValueAndValidity()` inside a
  `valueChanges` sub or a toggle handler (e.g. "delivery address required only when *not* same
  as mailing", "frequency required only when *repeating*") → `applyWhen(path, cond, p => {...})`,
  same predicate.
- The set of fields that are validated, the rule on each, and the trigger for each conditional
  rule must match. Do **not** add a `maxLength` the legacy field lacked (even where the DB or API
  would want one — that is a deviation the user opts into, flagged), and do **not** drop one it had.

**Buttons — port every condition.**

- Every `[disabled]="…"`, `*ngIf` / `[hidden]`, `[class.x]="…"`, `[severity]`, and "rendered only
  when X" on a button or row action ports to the same `@if` / `[disabled]` / class binding under
  the **same** condition. If legacy disables Save while `isAdd || isEdit`, or hides row actions on
  `isPrimary` rows, or shows a button only for a resource/role, the migration does the same.
- A conditionally-shown button does not become always-visible; a conditionally-disabled button
  does not become always-enabled; a `*ngIf`'d button behind a permission check keeps that check.

**Inputs — port every behaviour.**

- Masks → `p-inputmask` / `p-inputnumber mode="currency"` with the same accepted pattern; a legacy
  `mask="(000) 000-0000"` maps to `(999) 999-9999`, not "no mask".
- `readonly` / disable-when conditions, default values, `maxlength` HTML attr (where `[formField]`
  allows it), `type="password"` / show-hide toggles, `autocomplete` intent.
- Clear-on-change: legacy `patchValue({ dependent: '' })` inside a change handler → an explicit
  handler in the migration that resets the dependent field(s), same fields.
- Derived / synced fields: `valueChanges` + `{ emitEvent: false }` composition (e.g.
  `householdName = "Last, First"`) → `computed` / `linkedSignal`, same output.
- A "fill-in-the-blank" placeholder full of underscores is help text, not a placeholder — that
  much *does* change (accessibility), and is the kind of deviation to state, not hide.

**Copy — every visible string is migrated verbatim: same words, same case, same spelling.**

- This covers *all* on-screen text for the migrated form: field labels, section / card / panel
  headings, table column headers, button and link text, tab names, tooltips, placeholder and
  help text, validation messages, toast / dialog / confirm copy, and empty-state text.
- **Casing is part of the string.** Legacy `Date of Birth` does not become `Date Of Birth` or
  `Date of birth`; `First name` stays `First name`, not `First Name`. Match the capitalisation of
  every word, including title-case vs sentence-case for headings and buttons.
- **Spelling is ported as-is, quirks included** — `Zipcode`, `Cancelled`, `Org`, `# of Members`,
  `SSN`, domain abbreviations. Do **not** silently "correct" legacy spelling, grammar, or
  spacing-in-text. A real typo fix is a flagged deviation with old vs new, not an inline edit.
- Punctuation counts too: trailing colons on labels, `…` vs `...`, `&` vs `and`, parenthetical
  hints, singular/plural. Reproduce them.
- Shared/reusable copy still moves to `@constants` per Rule 2 — but the value stored there is the
  legacy text unchanged, not a cleaned-up rewrite.

**Spacing — padding and margin match the legacy layout.**

- Port the legacy component's spacing so the migrated screen reads at the same density: field
  vertical rhythm, label-to-control gap, gap between sections / fieldsets, button-row spacing,
  card / panel / dialog padding, table header and cell padding, inline gaps in a control group.
- Where legacy set explicit `px` / `rem` / `%`, reproduce the **same visual gap** using the
  repo's spacing variables / mixins (`src/styles/_variables.scss`, `.claude/rules/*`), not a
  raw hardcoded value — same spacing, expressed in the Overhaul's scale and tokens.
- Where a shared Overhaul component (`<fdp-card>`, `<fdp-validation>`, `<fdp-modal>`, a PrimeNG
  widget's own theme) already dictates padding / margin, **that standard wins** and the delta
  from legacy is a flagged deviation — note it; do not fight the design system with override
  CSS to chase a pixel.
- Do not add margins / padding the legacy screen did not have, and do not collapse spacing it
  did have. Responsive reflow required by `.claude/rules/conventions.md` is expected and is not
  a deviation to flag.

**Deviations are explicit, never silent.** Where the migration cannot or should not match legacy
— a broken accessibility hack (`readonly` + `onMouseDown`), genuinely dead code, a real bug, a
mechanism with no Overhaul equivalent, a typo or casing the user asked to fix, spacing a shared
`fdp-*` / PrimeNG component dictates, or a rule the user asked to add — say so in the plan and
in the PR notes, with the legacy behaviour, wording, or spacing and the new one side by side.
Loosening, tightening, dropping, adding, rewording, recasing, or respacing anything the user can
see or that the form enforces, without that call-out, is the failure this rule exists to catch.

The repo's `.claude/rules/validation.md`, `form-elements.md`, `tooltip.md` and `primeng.md`
define *how* to express these in Overhaul; this rule is about *fidelity to what legacy did*.

## Maintenance

This is a **growing list**. When a code-review / PR issue keeps recurring on this codebase,
add it here as a new numbered rule (short: the rule, a code shape, and a pointer to the repo's
own `.claude/rules/*.md` if one covers it) so the next migration and the next screen pick it
up automatically. Keep each rule tight; if it needs a lot of prose, it belongs in a repo rule
file and this skill just points at it.
