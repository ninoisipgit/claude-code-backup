---
name: fdp-table-and-constants
description: >-
  Always-on coding conventions for the NextGenFDP.UI.Overhaul repo. Apply whenever you create
  or edit a table (p-table / data table / grid), or whenever you are about to hardcode a value
  in a component (page sizes, date formats, message copy, option lists, min/max lengths, role
  lists, keys, etc.). Rule 1: every API-backed table shows <fdp-report-table-skeleton> while
  its fetch is in flight. Rule 2: shared/config values live in src/app/constants (@constants),
  not inline. Defers to the repo's own .claude/rules/*.md when present.
---

# FDP — tables & constants

Two conventions to apply while writing code in this repo. Where the repo has its own rule file
(`.claude/rules/report-table-skeleton.md`, `.claude/rules/where-code-goes.md`), that file wins
on the details — this skill just makes sure the conventions are not skipped.

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

## Maintenance

This is a **growing list**. When a code-review / PR issue keeps recurring on this codebase,
add it here as a new numbered rule (short: the rule, a code shape, and a pointer to the repo's
own `.claude/rules/*.md` if one covers it) so the next migration and the next screen pick it
up automatically. Keep each rule tight; if it needs a lot of prose, it belongs in a repo rule
file and this skill just points at it.
