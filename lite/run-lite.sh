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
OMARCHY_LAUNCHER=/usr/share/omarchy/bin/omarchy-launch-shell

# Omarchy 4 runs its bar/notifications as a Quickshell instance, supervised by omarchy-launch-shell
# (it relaunches the shell if it is killed). Stop the supervisor first: on SIGTERM it stops the shell
# and exits cleanly. recover.sh starts the launcher again.
if pgrep -f "bash $OMARCHY_LAUNCHER" >/dev/null 2>&1; then
  echo "stopping Omarchy shell launcher"
  touch "$STATE/omarchy-launcher-stopped"
  pkill -TERM -f "bash $OMARCHY_LAUNCHER"
  for _ in 1 2 3 4 5 6 7 8 9 10; do
    pgrep -f "$OMARCHY_SHELL_PATTERN" >/dev/null 2>&1 || break
    sleep 0.3
  done
fi
# If the shell is still there (no launcher, or it ignored SIGTERM), stop it directly.
for pid in $(pgrep -f "$OMARCHY_SHELL_PATTERN"); do
  echo "stopping Omarchy shell (pid $pid)"
  touch "$STATE/omarchy-launcher-stopped"
  kill "$pid"
done

# Older Omarchy / other setups: only matching running processes are touched.
for p in waybar mako swaync hypridle swayosd-server; do
  pgrep -x "$p" >/dev/null 2>&1 && { echo "$p" >> "$STATE/other-stopped"; echo "stopping $p"; pkill -x "$p"; }
done
exec "$ROOT/bin/serpantinumd" start "$@"
