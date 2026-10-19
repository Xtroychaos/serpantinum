#!/usr/bin/env bash
# Run Serpantinum from this checkout without the installer. Nothing system-wide is edited.
# Omarchy's own shell (a second Quickshell instance) and other bars/daemons are only stopped for this session;
# lite/recover.sh brings them back.
set -u
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SERPANTINUM_DIR="$ROOT/src"
# serpantinumd picks its entry file with an unordered find (Shell.qml or Bar.qml); pin it.
export MAIN_QML="$SERPANTINUM_DIR/quickshell/Shell.qml"

command -v quickshell >/dev/null 2>&1 || { echo "quickshell not found in PATH; nothing was stopped"; exit 1; }

STATE="${XDG_RUNTIME_DIR:-/tmp}/serpantinum-lite"
mkdir -p "$STATE"
OMARCHY_SHELL_PATTERN='quickshell.* -p /usr/share/omarchy/shell'

# Omarchy 4 runs its bar/notifications as a Quickshell instance. Remember its exact command line
# so recover.sh can start it again, then stop it so the two shells don't fight over bars and notifications.
for pid in $(pgrep -f "$OMARCHY_SHELL_PATTERN"); do
  tr '\0' ' ' < "/proc/$pid/cmdline" > "$STATE/omarchy-shell.cmd" 2>/dev/null
  echo "stopping Omarchy shell (pid $pid)"
  kill "$pid"
done

# Older Omarchy / other setups: only matching running processes are touched.
for p in waybar mako swaync hypridle swayosd-server; do
  pgrep -x "$p" >/dev/null 2>&1 && { echo "$p" >> "$STATE/other-stopped"; echo "stopping $p"; pkill -x "$p"; }
done
exec "$ROOT/bin/serpantinumd" start "$@"
