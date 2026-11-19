#!/usr/bin/env bash
# Runs one agent stage (plan | build | review | update) and shows its work live.
stage="$1"
cd "$(dirname "$0")/.."
RO=(--allowedTools Read Glob Grep "Bash(git diff:*)" "Bash(git log:*)")
case "$stage" in
  plan|update) TOOLS=("${RO[@]}"); TITLE="PLANNER"; COLOR=35 ;;
  build)  TOOLS=(--permission-mode acceptEdits --allowedTools Read Glob Grep Edit Write
                 "Bash(npm:*)" "Bash(node:*)" "Bash(git add:*)" "Bash(git commit:*)"
                 "Bash(git status:*)" "Bash(git diff:*)"); TITLE="BUILDER"; COLOR=36 ;;
  review) TOOLS=("${RO[@]}" "Bash(npm test)" "Bash(npm run acceptance)"
                 "Bash(npm run guard)" "Bash(npm run build)"); TITLE="REVIEWER"; COLOR=33 ;;
  *) echo "unknown stage $stage"; exit 1 ;;
esac
[ -n "${IN_PANE:-}" ] && clear
printf '\033[1;%sm━━━━ %s AGENT · %s ━━━━\033[0m\n' "$COLOR" "$TITLE" "$stage"
printf '\033[2mTask: %s…\033[0m\n\n' "$(head -c 220 ".loop/$stage.prompt" | tr '\n' ' ')"
claude -p "$(cat ".loop/$stage.prompt")" "${TOOLS[@]}" --output-format stream-json --verbose \
  | node scripts/show.mjs ".loop/$stage.out"
echo "${PIPESTATUS[0]}" > ".loop/$stage.exit"
