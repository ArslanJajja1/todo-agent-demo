I've reviewed the branch: tests, acceptance and guard all pass, and I found no critical or major issues. Below is the full review.

# Review: `feat/rename` against `main`

## Check results

**`npm test`**: 27 passed, 0 failed (17 existing tests + 10 new rename tests)
```
✔ rename changes the text and returns the updated todo
✔ rename keeps the id, done value and order
✔ rename trims surrounding whitespace
✔ rename rejects "" / "   " / undefined / null and leaves the list unchanged
✔ rename with an unknown id throws and leaves the list unchanged
✔ rename by id leaves another todo with the same text
✔ size does not change after a rename
ℹ tests 27  ℹ pass 27  ℹ fail 0
```

**`npm run acceptance`**
```
6 scenarios (6 passed)
20 steps (20 passed)
```

**`npm run guard`**
```
✅ Acceptance tests unchanged
```

## Scope check

| File | Allowed? |
|---|---|
| `src/todo.js` | ✅ |
| `test/todo.test.js` | ✅ |
| `acceptance/steps/rename.steps.js` (new) | ✅ |
| `web/app.js` | ✅ |
| `web/index.html` (CSS only) | ✅ |
| `tasks/rename.md` (new) | ⚠️ Not in the allowed list. It is the task pack itself, added in its own `docs:` commits (see Minor 1). |
| `acceptance/features/**` | ✅ Not touched; the guard confirms it |
| `package.json`, `package-lock.json` | ✅ Not touched, no new dependencies |
| `basics.steps.js`, `delete.steps.js` | ✅ Not touched; their steps are reused, not redefined |

## Correctness

- **`TodoList#rename`** matches the task pack exactly:
  - It checks the text before looking up the id, so a bad call never changes anything.
  - It trims the same way `add` does.
  - It changes only `text`, so the id, `done` value and position stay the same.
  - It returns a copy, so callers can't change the list through the result.
  - It contains no DOM code, and `add`, `remove`, `items` and `size` are unchanged.
- **Step definitions** follow the pack. The second step checks order with `deepEqual`. The empty-text scenario uses the existing `I see the error` step.
- **Web page:**
  - Each Rename button has an `aria-label` that names the todo, and so does the edit input.
  - Enter and blur save, and Escape cancels and clears the error.
  - If saving fails, the error shows and the input stays open.
  - The `finished` flag stops a second save when `render()` removes the focused input.
  - Commit 33c59aa takes out the refocus on blur, which avoids trapping focus in the input. That was the right call.
- **CSS:** it reuses the `button.delete` style and `var(--accent)`, which has a dark-mode value, so it stays readable in both themes.

## Issues

### Critical
None.

### Major
None.

### Minor
1. **`tasks/rename.md` is on the branch but not in the allowed list.** It is the task pack itself, in separate `docs:` commits (`ee70faf`, `d52cb57`), so this is a process note rather than a code problem. I couldn't confirm that earlier packs like `tasks/delete.md` live on `main`, because listing `main`'s `tasks/` folder needed approval. If they do, this follows the same pattern.
2. **The `done` part of the "keeps the done value" test proves nothing.** There is no way to mark a todo done yet, so the test only ever checks `done: false`. When a toggle feature lands, add a test that renames a todo that is done.
3. **Two edit inputs can be open at once.** If an edit is showing an error (for example, empty text) and the user clicks Rename on another todo, the first input stays open next to the second. When the second save succeeds, `render()` throws away the first edit without saying so. The old text is kept, so no data is corrupted, but the screen is confusing for a moment.
4. **The edit input doesn't fill the row.** `.rename-input` has no `flex: 1`, so in the flex `li` it can be narrower than the text span it replaces. This is cosmetic only.
5. **The empty-text scenario doesn't check the list stayed the same.** That gap is in the customer's feature file, which can't be edited. The unit tests cover it, so nothing needs to change; I'm noting it for the customer.
6. **There are no automated tests for the web page.** The project has no browser test setup, so this matches how it works today. I did not run the manual smoke test from step 7 of the task pack (build, serve, click through), so the web behaviour above is checked by reading the code only.

## Commits
There are 7 small commits, all with conventional messages (`feat:`, `test:`, `docs:`, `fix:`). Nothing was committed to `main`.

VERDICT: APPROVE
