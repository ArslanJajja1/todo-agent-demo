## Review: `feat/count` vs `main`

### What changed (`git diff --stat main...HEAD`)
| File | Allowed? |
|---|---|
| `src/todo.js` (+4) | ✅ |
| `test/todo.test.js` (+34) | ✅ |
| `acceptance/steps/count.steps.js` (new, +6) | ✅ |
| `web/app.js` (+2) | ✅ |
| `web/index.html` (+2: count element and one CSS rule) | ✅ |
| `tasks/count.md` (new, +63) | ⚠️ Not in the allowed list. It is the task pack itself, committed separately as `docs: task pack for count`. |

Nothing under `acceptance/features/` changed. The diff confirms it and the guard passes. No other step files, no `package.json` or lockfile, and no `scripts/` or `dist/` files were touched.

### Check results (I ran all three)
**`npm test`:** 32 tests, 32 pass, 0 fail. All 5 new `countLabel` tests are green:
```
✔ countLabel on an empty list is "0 todos"
✔ countLabel with one todo is "1 todo"
✔ countLabel with two todos is "2 todos"
✔ countLabel updates after add and remove
✔ countLabel does not change after a failed add
ℹ tests 32  ℹ pass 32  ℹ fail 0
```
**`npm run acceptance`:**
```
7 scenarios (7 passed)
22 steps (22 passed)
```
There are no undefined or ambiguous steps.

**`npm run guard`:** `✅ Acceptance tests unchanged`

### Correctness
- **`countLabel()`** builds its result from the existing `size` getter and adds no new state. It returns `1 todo` when the size is exactly 1 and `N todos` otherwise, including 0. `add`, `remove`, `rename`, `items` and `size` are unchanged, and no DOM code was added. This matches the task pack.
- **Step definition:** `I see {string}` cannot clash with `I see the error {string}`. `{string}` only matches a quoted string, so the unquoted words "the error" never match it. The acceptance run confirms there are no ambiguous steps. The new file correctly reuses `a todo list with {string} and {string}` from `delete.steps.js` instead of defining it again.
- **Web page:**
  - `#count` is fetched once and set at the end of `render()`.
  - `render()` runs on page load (`web/app.js:108`) and after add, delete and rename, so the page shows `0 todos` at start and stays up to date.
  - The element is a `<p>` with `aria-live="polite"`, placed between the list and the empty message as specified.
  - The CSS uses `var(--muted)`, so it stays readable in dark mode.
- **"Done todos still count" test:** correctly left out. The only `done` reference in `src/todo.js` is the initial `done: false` in `add`, and the grep found no public method that sets it.

### Issues

**Critical:** none.

**Major:** none.

**Minor:**
1. **`tasks/count.md` is outside the allowed file list.** It is the task pack, in its own `docs:` commit, so this is low risk. Strictly, though, the diff touches a file the pack doesn't list. Either add task-pack files to the allowed list or commit them to `main` before branching.
2. **No unit test for the label after a rename.** Plan step 3 doesn't require one, and the existing `size does not change after a rename` test covers it indirectly. A direct check that `countLabel()` doesn't change after a rename would match the "updates after every add, delete and rename" item in the Done list.
3. **No automated test for the web page.** Nothing tests that `#count` is rendered. The smoke test in plan step 7 (build, serve, then click through) is the only check, and I haven't seen evidence that it was done. I read the code but did not open the page in a browser.
4. **The label and the empty message appear together on an empty list.** It shows both `0 todos` and "Nothing to do yet." This is what the spec asks for, but it is slightly redundant. Product feedback only, not a defect.
5. **`count` is a generic name** at the top of `web/app.js`. A name like `countEl` would match `listEl`. Cosmetic.

### Summary
The change is small and correct, and it follows the task pack. The commits are small and use conventional messages. All three checks pass and the customer contract is untouched. The only issues are minor: one file outside the allowed list (the task pack itself), one optional extra test, and an unverified browser smoke test.

VERDICT: APPROVE