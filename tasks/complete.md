# Task pack: complete

## Goal
Let users mark a todo as done and undo it, in both the logic (`src/todo.js`) and the web page, so that `acceptance/features/complete.feature` passes:
- Marking a todo as done sets its `done` to `true` and leaves the other todos unchanged.
- Marking a done todo as not done sets its `done` back to `false`.
- Marking a todo that does not exist throws an `Error` with the message `Todo not found`, and the list stays unchanged.

All existing unit tests and acceptance tests (`basics`, `count`, `delete`, `no-duplicates`, `rename`) must keep passing.

## Plan
1. **Check that the test fails first.** Run `npm run acceptance` and confirm that `complete.feature` fails because the steps `I mark {string} as done`, `I mark {string} as not done` and `{string} is done` are undefined. `{string} is not done`, `a todo list with {string} and {string}`, `an empty todo list` and `I see the error {string}` already exist.
2. **Add `complete(id)` and `uncomplete(id)` to `TodoList`** in `src/todo.js`:
   - Find the todo by `id`. If none matches, `throw new Error('Todo not found')`, the same message `remove` and `rename` use.
   - `complete` sets `done = true`. `uncomplete` sets `done = false`. Both are idempotent: completing a todo that is already done is not an error.
   - Change only `done`. Keep the same `id`, `text` and position in the list.
   - Return a copy of the updated todo (`{ ...todo }`).
   - Do not change `add`, `remove`, `rename`, `items`, `size` or `countLabel`. `size` and `countLabel` still count every todo, done or not. Keep DOM code out of this file.
   - Use explicit set methods, not a `toggle`, so that "mark as done" means the same thing every time it is called.
3. **Add unit tests** to `test/todo.test.js`:
   - `complete` sets `done` to `true` and returns the updated todo.
   - `complete` keeps the `id`, the `text` and the order of the list, and leaves the other todos with `done: false`.
   - `complete` twice leaves the todo done and does not throw.
   - `uncomplete` sets a done todo back to `done: false`. `uncomplete` on a todo that is not done leaves it not done.
   - `complete` and `uncomplete` with an unknown id (and with `undefined`) throw `Todo not found` and leave the list unchanged.
   - `size` and `countLabel` do not change after complete or uncomplete.
   - `items()` copies stay copies: changing `done` on a returned object does not change the list.
4. **Add step definitions** in a new file, `acceptance/steps/complete.steps.js`:
   - `When I mark {string} as done`: find the todo with that text in `this.list.items()` and call `this.list.complete(todo?.id)`. Catch any error into `this.error`.
   - `When I mark {string} as not done`: same as above, but call `this.list.uncomplete(todo?.id)`.
   - `Then {string} is done`: find the todo by text, assert that it exists, and assert that `todo.done === true`. Follow the pattern of `{string} is not done` in `basics.steps.js`.
   - Do not define `{string} is not done`, `a todo list with {string} and {string}`, `an empty todo list` or `I see the error {string}` again. Cucumber fails on duplicate step definitions.
5. **Update the web page:**
   - `web/app.js`: in `render()`, add a checkbox at the start of each `<li>`, checked when `todo.done` is true, with an `aria-label` that names the todo, such as `Mark "Buy milk" as done`. On `change`, call `list.complete(todo.id)` or `list.uncomplete(todo.id)` depending on `checked`, clear `#error` and call `render()`. On failure, show `err.message` in `#error`. `render()` already toggles the `done` class on `<li>`. Keep Rename and Delete working.
   - `web/index.html`: add only the CSS needed for the checkbox. The existing `li.done` rule strikes through the whole row, including the buttons, so change it to strike through only `.todo-text` (for example `li.done .todo-text`). Reuse the existing CSS variables (for example `accent-color: var(--accent)`) so it stays readable in dark mode. Do not let the generic `input` rule (padding, border, `flex: 1`) stretch the checkbox.
6. **Run all checks:** `npm test`, `npm run acceptance` and `npm run guard`. All three must pass.
7. **Smoke test the page:** run `npm run build`, then `npm run serve`. Add two todos, tick one and check that only its text is struck through and muted. Untick it and check that it goes back to normal. Check that the count does not change, and that Rename and Delete still work on a done todo.
8. **Commit in small steps** with conventional messages, for example:
   - `feat: add TodoList.complete and uncomplete`
   - `test: unit tests for complete`
   - `test: step definitions for complete feature`
   - `feat: mark todos as done on web page`

## Files you may touch
- `src/todo.js`
- `test/todo.test.js`
- `acceptance/steps/complete.steps.js` (new)
- `web/app.js`
- `web/index.html` (CSS for the checkbox and the done style only)

## Files you must not touch
- `acceptance/features/**`: this is the customer's contract. If a scenario looks wrong, stop and report it.
- `acceptance/steps/basics.steps.js`, `acceptance/steps/count.steps.js`, `acceptance/steps/delete.steps.js`, `acceptance/steps/rename.steps.js`: reuse their steps, don't change them.
- `package.json`, `package-lock.json`: no new dependencies or scripts.
- `scripts/**`
- `dist/**`: generated by `npm run build`, so don't edit or commit it by hand.
- `CLAUDE.md`, `.github/**`
- Any `.env` file, secrets or deploy configuration.

## Done when
- [ ] `TodoList#complete(id)` and `TodoList#uncomplete(id)` exist, change only `done` on the matching todo, are idempotent, return a copy, and throw `Error('Todo not found')` for an unknown id without changing the list.
- [ ] The new unit tests cover complete, uncomplete, idempotency, unknown id, kept id/text/order, other todos left alone, and unchanged size/countLabel, and `npm test` passes.
- [ ] `npm run acceptance` passes for every scenario in every feature file, including all three scenarios in `complete.feature`.
- [ ] `npm run guard` passes, meaning no changes under `acceptance/features/` compared with `main`.
- [ ] Each todo on the web page has a checkbox with an accessible label that marks it done and undoes it. Done todos have struck-through, muted text, and the buttons are not struck through. Rename, Delete and the count still work.
- [ ] Only files from the allowed list changed (`git diff --stat main...HEAD`).
- [ ] No new dependencies were added.
- [ ] Commits are small and use conventional messages.
- [ ] The output of `npm test` and `npm run acceptance` is pasted in the final report.
