I found no critical or major issues. Unit tests, acceptance tests and the guard all pass, and nothing under `acceptance/features/` changed. There are a few minor points below, so I'm approving.

## Check results (run just now on `feat/complete`)

**`npm test`**
```
✔ complete sets done to true and returns the updated todo
✔ complete keeps id, text and order and leaves other todos alone
✔ complete twice leaves the todo done
✔ uncomplete sets a done todo back to not done
✔ uncomplete on a todo that is not done leaves it not done
✔ complete with unknown id 999 throws and leaves the list unchanged
✔ complete with unknown id undefined throws and leaves the list unchanged
✔ uncomplete with unknown id 999 throws and leaves the list unchanged
✔ uncomplete with unknown id undefined throws and leaves the list unchanged
✔ size and countLabel do not change after complete or uncomplete
✔ changing done on returned copies does not change the list
ℹ tests 53  pass 53  fail 0
```

**`npm run acceptance`**
```
12 scenarios (12 passed)
43 steps (43 passed)
```

**`npm run guard`**
```
✅ Acceptance tests unchanged
```

## Scope
- **Changed files:** `src/todo.js`, `test/todo.test.js`, `acceptance/steps/complete.steps.js` (new), `web/app.js` and `web/index.html` are all on the allowed list. `tasks/complete.md` is not on the list, but it is the task pack itself, added in its own `docs:` commit, so I accept it.
- **Untouched:** `acceptance/features/`, the existing step files, `package.json`, `scripts/` and `dist/`. No dependencies were added.
- **Commits:** five small commits with conventional messages, matching the plan in the task pack.

## Correctness
- **Logic:** `complete` and `uncomplete` share a private `#setDone`. They only change `done`, can be called twice safely, return a copy, and throw `Todo not found` with the same message as `remove` and `rename`. An unknown id leaves the list unchanged, because the error is thrown before anything is written. `add`, `remove`, `rename`, `items`, `size` and `countLabel` are unchanged, and there is no DOM code in the logic file.
- **Step definitions:** the three new steps reuse the existing `{string} is not done`, the empty-list step and the error step, with no duplicates. The missing todo is passed as `todo?.id`, so the "Ghost task" scenario gets the real `Todo not found` error rather than a TypeError. I checked that this behaves correctly.
- **Web page:** each todo has a checkbox labelled `Mark "…" as done`, and its handler follows the same pattern as Delete. The strike-through now applies to `.todo-text` only, so the buttons are no longer struck through. The checkbox overrides `flex`, `padding` and `margin` from the generic `input` rule, and uses `accent-color: var(--accent)`.

## Issues

**Critical:** none.

**Major:** none.

**Minor:**
1. **Checkbox can get out of sync (`web/app.js:33-35`).** If `complete` or `uncomplete` throws, the error shows but the box stays in its new state while the data didn't change. Calling `render()` in the `catch` block, or setting `check.checked = todo.done`, would fix it. You can't trigger this with the current UI, because the id always exists.
2. **Clicking the checkbox while renaming may do nothing.** Clicking it first ends the rename, which rebuilds the list and removes the checkbox you clicked, so the tick is probably lost. Delete has the same problem today, so this change didn't cause it. I reasoned this from the code and did not test it in a browser.
3. **Checkbox still picks up some generic `input` styles (`web/index.html:53-63`).** It still gets `border-radius: 8px`, `border` and the `input:focus` outline with `outline-offset: -1px`. Native checkboxes mostly ignore border and radius, but the focus ring will be drawn inset over the box. Adding `outline-offset: 2px` to the `.todo-check` focus style would fix it.
4. **Screen-reader label doesn't change.** The `aria-label` always says "Mark … as done", so a ticked box reads as "Mark Buy milk as done, checked". The task pack suggested this wording, so it is acceptable, but a neutral label such as `Done: "Buy milk"` would read better.
5. **Small test gaps.**
   - No test checks that `uncomplete` leaves other todos and the order alone; only `complete` has that test.
   - The "complete twice" test proves it doesn't throw only by not failing; there is no explicit `assert.doesNotThrow`.
   - No test passes `null` as the id.

   None of these were required by the task pack.
6. **No proof of the manual page test.** Step 7 of the task pack asks for a check in the browser, and there's no record of it. I didn't run `npm run build` or `npm run serve` myself, because you asked me not to change any files and building rewrites `dist/`.

VERDICT: APPROVE