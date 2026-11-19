#!/usr/bin/env bash
mkdir -p .loop
echo "$HERDR_PANE_ID" > ".loop/pane.$1"
clear
printf '\033[1m%s pane ready (%s). Waiting for work…\033[0m\n' "$(echo "$1" | tr a-z A-Z)" "$HERDR_PANE_ID"
