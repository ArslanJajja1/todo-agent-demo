# Review: `feat/delete` vs `main`

**Scope checked:** `git diff main...HEAD` (6 files, 5 commits), `CLAUDE.md`, `tasks/delete.md`, `acceptance/features/delete.feature`, plus `basics.steps.js` for step reuse.

**Contract check:** `git diff main...HEAD --name-only -- acceptance/features` is empty. Nothing under `acceptance/features/` changed.

**Tests not run.** The permission layer blocked `npm test`, `npm run acceptance` and `npm run guard`, so I have no test output to show. Everything below comes from reading the code. Run all three before merging.

## Critical
None.

## Major
None.

## Minor
1. **A file from the forbidden list is in the diff.** `tasks/delete.md` came in with commit `02bf19e docs: task pack for delete`, but the task pack lists `tasks/**` as "must not touch". This is probably the person who wrote the spec committing the task pack on purpose, not the implementer changing it. Even so, `git diff --stat main...HEAD` now fails the "only allowed files changed" check. Either land the task pack on `main` first, or confirm this was intended.
2. **Weak test for the return value.** `remove returns the deleted todo` (`test/todo.test.js`) only checks `deepEqual`. It never checks that the returned object is a copy. If `remove` returned the internal object, the test would still pass. Add a check that changing the returned object does not change anything in the list.
3. **No unit test for `remove(undefined)`.** The acceptance step relies on `remove(undefined)` throwing `Todo not found` (`delete.steps.js:14`, `todo?.id`). Only the Cucumber scenario covers this path. A one-line unit test would protect the behaviour the step depends on.
4. **Focus is lost after a delete.** `render()` rebuilds every `<li>`, so the Delete button that had focus disappears and focus falls back to `<body>`. Keyboard and screen-reader users lose their place. Moving focus to the next row's Delete button, or to `#todo-input`, would fix it. The task pack doesn't require this.
5. **The `li` styles are split across two rules.** `web/index.html:77-83` defines `li { … }` and then a second `li { display:flex; … }`. Merging them would be cleaner. This is cosmetic, and the CSS-only constraint is respected.
6. **The web smoke test has no evidence.** The task pack asks for a manual check that "Nothing to do yet." comes back after the last todo is deleted. Reading the code, it should work, because `empty.hidden = items.length > 0` runs on every render. There's no note or output showing the check was actually done.

## What's correct
- **`TodoList#remove`:** it deletes by id with strict equality, throws `Error('Todo not found')` without changing the list, returns `{ ...removed }`, and leaves `add`, `items` and `size` alone. There's no DOM code in it.
- **Unit tests:** all 7 cases the task pack asks for are there: order is kept, the deleted todo is returned, unknown id, empty list, duplicate text, removing twice, and size.
- **Step definitions:** they're in a new file, they reuse `an empty todo list`, `the list contains only` and `I see the error` without defining them again, and the not-found error comes from the logic, not the step.
- **Web page:** each row has a text span and a `type="button"` Delete button with `aria-label="Delete "<text>""`. Clicking it clears `#error` and re-renders, and errors show in `#error`. The CSS uses only the existing variables, so dark mode still works.
- **Constraints:** no changes to `package.json` or `scripts/`, no new dependencies, and the commits are small with conventional messages.

There are no blocking issues, so this can be approved. The approval still depends on `npm test`, `npm run acceptance` and `npm run guard` passing.

VERDICT: APPROVE
