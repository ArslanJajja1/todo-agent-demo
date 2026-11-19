#!/usr/bin/env bash
# One acceptance test in -> planned, built, reviewed, CI-checked, merged, deployed.
set -euo pipefail

FEATURE="${1:?usage: scripts/loop.sh acceptance/features/<name>.feature}"
NAME="$(basename "$FEATURE" .feature)"
BRANCH="feat/$NAME"
MAX_TRIES=3
mkdir -p tasks reviews .loop

step() { printf '\n\033[1;36m━━━━ %s ━━━━\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m✔ %s\033[0m\n' "$*"; }
bad()  { printf '\033[1;31m✘ %s\033[0m\n' "$*"; }

READ_ONLY=(--allowedTools "Read" "Glob" "Grep" "Bash(git diff:*)" "Bash(git log:*)")
BUILDER=(--permission-mode acceptEdits --allowedTools "Read" "Glob" "Grep" "Edit" "Write"
         "Bash(npm:*)" "Bash(node:*)" "Bash(git add:*)" "Bash(git commit:*)"
         "Bash(git status:*)" "Bash(git diff:*)")

checks() {
  { npm test && npm run acceptance && ./scripts/guard-acceptance.sh main; } > .loop/checks.log 2>&1
}

step "0. START  $FEATURE"
git checkout -q main && git pull -q --ff-only
git checkout -q -B "$BRANCH"
ok "working on branch $BRANCH"

step "1. PLAN  (agent reads the test and writes a task pack)"
claude -p "Read CLAUDE.md, the existing code, and $FEATURE. Write a task pack in markdown with:
Goal, Plan (small numbered steps), Files you may touch, Files you must not touch, Done when.
Output only the markdown." "${READ_ONLY[@]}" > "tasks/$NAME.md"
cat "tasks/$NAME.md"
git add "tasks/$NAME.md" && git commit -qm "docs: task pack for $NAME"

step "2. RED  (the new test must fail before we build)"
if checks; then bad "Test already passes. Nothing to build."; exit 1; fi
ok "acceptance test fails, as expected"

FEEDBACK=""; APPROVED=0
for try in $(seq 1 $MAX_TRIES); do
  step "3. BUILD  (try $try of $MAX_TRIES)"
  claude -p "You are the builder. Follow CLAUDE.md and tasks/$NAME.md to make $FEATURE pass.
Add the feature to src/todo.js AND the web page. Write unit tests. Never edit acceptance/features.
Run npm test and npm run acceptance until green, then commit. $FEEDBACK" "${BUILDER[@]}"

  step "4. VERIFY  (the script checks; it does not trust the agent)"
  if ! checks; then
    bad "checks failed"; tail -25 .loop/checks.log
    FEEDBACK="Your last attempt failed these checks, fix them: $(tail -40 .loop/checks.log)"
    continue
  fi
  ok "unit tests, acceptance tests and guard are all green"

  step "5. REVIEW  (a fresh agent that did not write the code)"
  claude -p "You are a strict senior reviewer. Review the output of 'git diff main...HEAD'
against CLAUDE.md, tasks/$NAME.md and $FEATURE. Check correctness, edge cases, missing or
weak tests, files outside the allowed list, and that acceptance/features is untouched.
List issues by severity (critical, major, minor). Minor-only issues can still be approved.
The last line must be exactly: VERDICT: APPROVE  or  VERDICT: CHANGES" "${READ_ONLY[@]}" > "reviews/$NAME.md"
  cat "reviews/$NAME.md"
  if grep -q "VERDICT: APPROVE" "reviews/$NAME.md"; then ok "reviewer approved"; APPROVED=1; break; fi
  bad "reviewer asked for changes"
  FEEDBACK="The reviewer asked for changes. Fix them: $(cat "reviews/$NAME.md")"
done

[ "$APPROVED" = 1 ] || { bad "Not approved after $MAX_TRIES tries. A human needs to look."; exit 1; }
git add "reviews/$NAME.md" && git commit -qm "docs: AI review for $NAME"

if [ "${LOCAL_ONLY:-0}" = 1 ]; then ok "Local loop finished (LOCAL_ONLY=1)"; exit 0; fi

step "6. PULL REQUEST"
git push -q -u origin "$BRANCH"
gh pr create --base main --head "$BRANCH" --title "feat: $NAME" \
  --body "$(printf '## Task pack (written by planner agent)\n%s\n\n## Review (by reviewer agent)\n%s\n' \
  "$(cat "tasks/$NAME.md")" "$(cat "reviews/$NAME.md")")" || true

step "7. CI  (GitHub tests everything on a clean machine)"
sleep 15
gh pr checks "$BRANCH" --watch --fail-fast
ok "CI is green"

step "8. HUMAN GATE  (I decide what goes to main)"
read -rp "Merge $BRANCH into main? [y/N] " yn
[ "$yn" = "y" ] || { echo "Stopped before merge."; exit 0; }
gh pr merge "$BRANCH" --squash --delete-branch
git checkout -q main && git pull -q

step "9. DEPLOY  (CD to GitHub Pages)"
sleep 10
RUN_ID=$(gh run list --workflow deploy.yml --branch main --limit 1 --json databaseId -q '.[0].databaseId')
gh run watch "$RUN_ID" --exit-status > /dev/null
URL=$(gh api "repos/{owner}/{repo}/pages" -q .html_url)
ok "Live at $URL"

step "10. DAILY UPDATE  (for the client)"
claude -p "Write a 5-line daily update for my client. Lines: Done, Next, Blockers, Questions, Demo.
Feature: $FEATURE. Recent commits: $(git log --oneline -6). Demo link: $URL. Plain, short sentences." "${READ_ONLY[@]}"
