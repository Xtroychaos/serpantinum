#!/usr/bin/env bash
# Merge lite/bar-lite.json into the user's Serpantinum settings.json (keys not listed are untouched).
# Usage: apply-bar.sh apply | revert
set -euo pipefail
command -v jq >/dev/null || { echo "jq is required"; exit 1; }
HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CFG="${QS_SETTINGS:-$HOME/.config/serpantinum/settings.json}"
BAK="$CFG.pre-lite"

case "${1:-}" in
  apply)
    [ -f "$CFG" ] || { echo "no settings file at $CFG"; exit 1; }
    [ -f "$BAK" ] || cp -p "$CFG" "$BAK"
    tmp="$(mktemp)"
    jq --slurpfile lite "$HERE/bar-lite.json" '.bar = ((.bar // {}) * $lite[0])' "$CFG" > "$tmp"
    jq -e . "$tmp" >/dev/null
    mv "$tmp" "$CFG"
    echo "applied; backup at $BAK"
    ;;
  revert)
    [ -f "$BAK" ] || { echo "no backup at $BAK"; exit 1; }
    # Restore only the bar section so settings changed since apply are kept.
    tmp="$(mktemp)"
    jq --slurpfile old "$BAK" '.bar = $old[0].bar | if .bar == null then del(.bar) else . end' "$CFG" > "$tmp"
    jq -e . "$tmp" >/dev/null
    mv "$tmp" "$CFG"
    echo "restored bar section of $CFG from $BAK"
    ;;
  *) echo "usage: $0 apply|revert"; exit 1 ;;
esac
