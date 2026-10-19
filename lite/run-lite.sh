#!/usr/bin/env bash
# Run Serpantinum from this checkout without the installer. Nothing system-wide is edited.
# Competing Omarchy components are only stopped for this session (restart them with recover.sh).
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SERPANTINUM_DIR="$ROOT/src"
# serpantinumd picks its entry file with an unordered find (Shell.qml or Bar.qml); pin it.
export MAIN_QML="$SERPANTINUM_DIR/quickshell/Shell.qml"

# Components that would duplicate Serpantinum's own bar, notification server, idle and OSD.
# Names assume stock Omarchy; adjust if your session differs. Only matching running processes are touched.
for p in waybar mako swaync hypridle swayosd-server; do
  pgrep -x "$p" >/dev/null 2>&1 && { echo "stopping $p"; pkill -x "$p"; }
done
exec "$ROOT/bin/serpantinumd" start "$@"
