#!/usr/bin/env bash
# Live status board for the agentic loop. Run it in its own Herdr pane.
cd "$(dirname "$0")/.."
mkdir -p .loop
STEPS=("Acceptance test" "Plan" "Red" "Build" "Verify" "Review"
       "Pull request" "CI" "Merge gate" "Deploy" "Daily update")
WHO=("you" "agent" "script" "agent" "script" "agent" "github" "github" "me" "github" "agent")
printf '\033[2J'
while true; do
  out="$(printf '\033[1;36m AGENTIC LOOP\033[0m  \033[1m%s\033[0m' "$(cat .loop/feature 2>/dev/null || echo 'waiting…')")"$'\n\n'
  for i in "${!STEPS[@]}"; do
    line=$(grep "^$i|" .loop/status 2>/dev/null | tail -1)
    state=$(echo "$line" | cut -d'|' -f2); note=$(echo "$line" | cut -d'|' -f3-)
    case "$state" in
      run)  ic='\033[1;33m▶' ;;
      done) ic='\033[1;32m✔' ;;
      fail) ic='\033[1;31m✘' ;;
      back) ic='\033[1;35m↺' ;;
      *)    ic='\033[2m○' ;;
    esac
    out+="$(printf ' %b %2d  %-15s\033[0m \033[2m%-6s\033[0m %s\033[K' "$ic" "$i" "${STEPS[$i]}" "${WHO[$i]}" "$note")"$'\n'
  done
  printf '\033[H%s\033[J' "$out"
  sleep 1
done
