#!/usr/bin/env bash
# One acceptance test in -> planned, built, reviewed, CI-checked, merged, deployed.
# Agents run live in their own Herdr panes; scripts/board.sh shows every step.
set -euo pipefail

FEATURE="${1:?usage: scripts/loop.sh acceptance/features/<name>.feature}"
NAME="$(basename "$FEATURE" .feature)"
BRANCH="feat/$NAME"
MAX_TRIES=3
mkdir -p tasks reviews .loop

step() { printf '\n\033[1;36m━━━━ %s ━━━━\033[0m\n' "$*"; }
ok()   { printf '\033[1;32m✔ %s\033[0m\n' "$*"; }
bad()  { printf '\033[1;31m✘ %s\033[0m\n' "$*"; }
mark() { echo "$1|$2|${3:-}" >> .loop/status; }   # step-number | run/done/fail/back | note

checks() {
  { npm test && npm run acceptance && ./scripts/guard-acceptance.sh main; } 2>&1 | tee .loop/checks.log
}

run_agent() {
  local stage="$1" pane=""
  [ -f ".loop/pane.$2" ] && pane="$(cat ".loop/pane.$2")"
  rm -f ".loop/$stage.exit" ".loop/$stage.out"
  if [ -n "$pane" ] && [ -n "${HERDR_ENV:-}" ]; then
    herdr pane run "$pane" "IN_PANE=1 ./scripts/agent.sh $stage" > /dev/null
    printf '   ↳ %s agent working live in pane %s …\n' "$stage" "$pane"
    until [ -f ".loop/$stage.exit" ]; do sleep 2; done
  else
    ./scripts/agent.sh "$stage"
  fi
  return "$(cat ".loop/$stage.exit")"
}

: > .loop/status; echo "$NAME" > .loop/feature
mark 0 done "$FEATURE"

step "0. START  $FEATURE"
git checkout -q main && git pull -q --ff-only
git checkout -q -B "$BRANCH"
ok "working on branch $BRANCH"

step "1. PLAN  (planner agent writes the task pack)"
mark 1 run "planner agent is reading the test"
cat > .loop/plan.prompt << PROMPT
Read CLAUDE.md, the existing code, and $FEATURE. Write a task pack in markdown with:
Goal, Plan (small numbered steps), Files you may touch, Files you must not touch, Done when.
Do not list tasks/ or reviews/ under "must not touch" (the loop commits those).
Do NOT try to write or save any file. Your final answer must be ONLY the task pack,
starting with the line '# Task pack: $NAME', no code fences, no comments before or after.
PROMPT
run_agent plan plan || true
sed -n '/^# Task pack/,$p' .loop/plan.out | grep -v '^```' \
  | sed '/^---$/,$d; /^\*\*Decisions/,$d' > "tasks/$NAME.md"
[ -s "tasks/$NAME.md" ] || { bad "planner did not produce a task pack"; mark 1 fail "no task pack"; exit 1; }
git add "tasks/$NAME.md" && git commit -qm "docs: task pack for $NAME"
ok "task pack saved: tasks/$NAME.md"
mark 1 done "tasks/$NAME.md"

step "2. RED  (the new test must fail before we build)"
mark 2 run "running tests"
if checks; then bad "Test already passes. Nothing to build."; mark 2 fail "already passes"; exit 1; fi
ok "acceptance test fails, as expected"
mark 2 done "fails as expected"

FEEDBACK=""; APPROVED=0
for try in $(seq 1 $MAX_TRIES); do
  step "3. BUILD  (try $try of $MAX_TRIES)"
  mark 3 run "try $try of $MAX_TRIES"
  cat > .loop/build.prompt << PROMPT
You are the builder. Follow CLAUDE.md and tasks/$NAME.md to make $FEATURE pass.
Add the feature to src/todo.js AND the web page. Write unit tests. Never edit acceptance/features.
Run npm test and npm run acceptance until green, then commit. Do not push.
$FEEDBACK
PROMPT
  run_agent build build || true
  mark 3 done "try $try finished"

  step "4. VERIFY  (the script checks; it does not trust the agent)"
  mark 4 run "running all checks"
  if ! checks; then
    bad "checks failed"
    mark 4 fail "checks failed"; mark 3 back "sent back to builder"
    FEEDBACK="Your last attempt failed these checks, fix them: $(tail -40 .loop/checks.log)"
    continue
  fi
  ok "unit tests, acceptance tests and guard are all green"
  mark 4 done "$(grep -Eo 'tests [0-9]+' .loop/checks.log | tail -1) · $(grep -Eo '[0-9]+ scenarios? \([0-9]+ passed\)' .loop/checks.log | tail -1)"

  step "5. REVIEW  (a fresh agent that did not write the code)"
  mark 5 run "reviewer agent is checking the diff"
  cat > .loop/review.prompt << PROMPT
You are a strict senior reviewer. Review the output of 'git diff main...HEAD'
against CLAUDE.md, tasks/$NAME.md and $FEATURE.
Run npm test, npm run acceptance and npm run guard yourself and include the results.
Check correctness, edge cases, missing or weak tests, files outside the allowed list,
and that acceptance/features is untouched. List issues by severity (critical, major, minor).
Minor-only issues can still be approved. Do not edit any file.
The last line of your final answer must be exactly: VERDICT: APPROVE  or  VERDICT: CHANGES
PROMPT
  run_agent review review || true
  cp .loop/review.out "reviews/$NAME.md"
  grep -E "VERDICT:" "reviews/$NAME.md" | tail -1 || true
  if grep -q "VERDICT: APPROVE" "reviews/$NAME.md"; then
    ok "reviewer approved"; mark 5 done "APPROVE"; APPROVED=1; break
  fi
  bad "reviewer asked for changes, sending them back to the builder"
  mark 5 back "CHANGES requested"; mark 3 back "fixing review comments"
  FEEDBACK="The reviewer asked for changes. Fix them: $(cat "reviews/$NAME.md")"
done

[ "$APPROVED" = 1 ] || { bad "Not approved after $MAX_TRIES tries. A human needs to look."; mark 5 fail "not approved"; exit 1; }
git add "reviews/$NAME.md" && git commit -qm "docs: AI review for $NAME"

if [ "${LOCAL_ONLY:-0}" = 1 ]; then ok "Local loop finished (LOCAL_ONLY=1)"; exit 0; fi

step "6. PULL REQUEST"
mark 6 run "pushing branch"
git push -q -u origin "$BRANCH"
gh pr create --base main --head "$BRANCH" --title "feat: $NAME" \
  --body "$(printf '## Task pack (written by planner agent)\n%s\n\n## Review (by reviewer agent)\n%s\n' \
  "$(cat "tasks/$NAME.md")" "$(cat "reviews/$NAME.md")")" || true
mark 6 done "$(gh pr view "$BRANCH" --json url -q .url 2>/dev/null || echo opened)"

step "7. CI  (GitHub tests everything on a clean machine)"
mark 7 run "GitHub Actions running"
sleep 15
gh pr checks "$BRANCH" --watch --fail-fast || { mark 7 fail "CI failed"; exit 1; }
ok "CI is green"
mark 7 done "green"

step "8. HUMAN GATE  (I decide what goes to main)"
mark 8 run "waiting for your y/N"
read -rp "Merge $BRANCH into main? [y/N] " yn
[ "$yn" = "y" ] || { echo "Stopped before merge."; mark 8 fail "not merged"; exit 0; }
gh pr merge "$BRANCH" --squash --delete-branch
git checkout -q main && git pull -q
mark 8 done "merged"

step "9. DEPLOY  (CD to GitHub Pages)"
mark 9 run "deploying"
SHA=$(git rev-parse HEAD); RUN_ID=""
echo "waiting for the deploy of $SHA ..."
until [ -n "$RUN_ID" ]; do
  sleep 5
  RUN_ID=$(gh run list --workflow deploy.yml --commit "$SHA" --limit 1 --json databaseId -q '.[0].databaseId')
done
gh run watch "$RUN_ID" --exit-status > /dev/null
URL=$(gh api "repos/{owner}/{repo}/pages" -q .html_url)
ok "Live at $URL"
mark 9 done "$URL"

step "10. DAILY UPDATE  (for the client)"
mark 10 run "agent writing update"
cat > .loop/update.prompt << PROMPT
Write a 5-line daily update for my client. Lines: Done, Next, Blockers, Questions, Demo.
Feature: $FEATURE. Recent commits: $(git log --oneline -6). Demo link: $URL. Plain, short sentences.
Your final answer must be only the 5 lines.
PROMPT
run_agent update plan || true
echo; cat .loop/update.out
mark 10 done "sent"
