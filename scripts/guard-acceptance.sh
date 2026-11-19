#!/usr/bin/env bash
base="${1:-main}"
changed=$(git diff --name-only "$base" -- acceptance/features)
if [ -n "$changed" ] && [ "${ACCEPTANCE_APPROVED:-}" != "1" ]; then
  echo "❌ Acceptance tests changed without approval:"; echo "$changed"; exit 1
fi
echo "✅ Acceptance tests unchanged"
