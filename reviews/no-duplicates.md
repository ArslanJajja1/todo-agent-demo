I made no file edits.

# Review: `feat/no-duplicates` vs `main`

The duplicate check is correct in both `add` and `rename`. All three gates pass, `acceptance/features` is untouched, and every changed file is on the allowed list. I found only minor issues.

## Gate results (I ran each one)

| Command | Result |
|---|---|
| `npm test` | **42 tests, 42 pass, 0 fail** |
| `npm run acceptance` | **9 scenarios (9 passed), 32 steps (32 passed)**, including both `no-duplicates.feature` scenarios |
| `npm run guard` | **✅ Acceptance tests unchanged** |

## Scope check
- Changed files: `src/todo.js`, `test/todo.test.js` and `tasks/no-duplicates.md`. The task pack excludes `tasks/` from the allowed-list check.
- `git diff main...HEAD` shows no changes under `acceptance/`, `web/`, `scripts/`, `dist/`, `package.json` or `package-lock.json`. No dependencies were added.
- Commits are small and use conventional messages: `docs:`, `test:`, `feat:`, `feat:`. The working tree is clean.

## Correctness
- `#key` matches the task pack exactly: it trims, collapses whitespace and lowercases. It is used only for comparing; stored text is still just trimmed, with its original capitals.
- `add`: the duplicate check runs after the empty check and before `#nextId++`, so a rejected add doesn't use up an id. A unit test covers this.
- `rename`: the checks run in the order the spec asks for (empty, then not found, then duplicate). The `t.id !== id` filter lets a todo be renamed to its own text with different capitals. The check throws before `todo.text` is changed, so nothing changes on error.
- `web/app.js` needed no changes. Both the add and rename paths already show `err.message` in `#error`. The add input keeps its text on error, and a failed rename leaves the edit input open. So leaving the web code alone is the right call.

## Issues

**Critical:** none.

**Major:** none.

**Minor:**
1. **No evidence of the smoke test.** The task pack's "Done when" list includes the manual browser test (step 8). From reading `web/app.js` the behaviour should be correct, but I could not confirm it in a browser. Someone should run step 8 once before merging.
2. **Rename check order isn't tested.** No test calls `rename(unknownId, <duplicate text>)` to confirm it throws `Todo not found` rather than `Todo already exists`. The code is right; a test would lock it in.
3. **Missing rename case:** renaming a todo to its own text with different spacing (for example `"Buy   milk"`) isn't tested. Only different capitals is.
4. **`'add accepts texts that are similar but different'` is weak.** It only checks `size === 2`. It would be stronger if it checked the stored texts or wrapped the second add in `assert.doesNotThrow`.
5. **Edge cases outside the spec:** the match doesn't apply Unicode normalization (a composed `é` and a decomposed `e` + accent are treated as different), and `toLowerCase()` ignores locale rules such as Turkish dotted/dotless i. The spec doesn't require either, so this is just worth knowing.
6. **Small redundancy:** in `add` and `rename`, `#key(trimmed)` trims text that is already trimmed. It's harmless and the task pack asks for this exact helper, so no change is needed.

## Commit history
The `test:` commit (`0541620`) comes before the `feat:` commits, so `npm test` fails at that commit on its own. That is normal test-first order and the task pack asks for it, so I'm only noting it.

VERDICT: APPROVE