# todo-agent-demo

A simple todo list app, used to demo an AI-agent workflow with acceptance tests.
Node.js 22, ES modules, no framework, no database (in-memory).

## Commands
- `npm test`: unit tests (node:test)
- `npm run acceptance`: acceptance tests (Cucumber, Given/When/Then)
- `npm run guard`: fails if acceptance feature files changed vs main
- `npm run build`: builds the web app into dist/
- `npm run serve`: serves dist/ on http://localhost:8080

## Architecture
- `src/todo.js`: all todo logic as a `TodoList` class. No DOM code here.
- `web/index.html` + `web/app.js`: a simple web page that uses src/todo.js.
- Every feature must work in BOTH the logic and the web page.
- `acceptance/steps/`: step definitions that test src/todo.js.

## Rules
- NEVER edit anything in `acceptance/features/`. It is the customer's contract.
  If a test looks wrong, stop and say so. Never change a test to make it pass.
- Only touch the files the task pack allows.
- Small commits, conventional commit messages (feat:, fix:, test:, docs:).
- Before saying done, run `npm test` and `npm run acceptance` and show the output.
- Do not add new dependencies without asking.
- Never touch secrets or deploy anything yourself.
