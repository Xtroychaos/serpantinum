#!/usr/bin/env bash
# Stop Serpantinum and bring back what run-lite.sh stopped (Omarchy's own shell, or Waybar/mako/etc).
# Run it inside your Hyprland session (terminal or keybind). From a bare TTY it still stops Serpantinum,
# and it tries to find the Wayland/Hyprland sockets before restarting the stock components.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export SERPANTINUM_DIR="$ROOT/src"
export MAIN_QML="$SERPANTINUM_DIR/quickshell/Shell.qml"
STATE="${XDG_RUNTIME_DIR:-/tmp}/serpantinum-lite"
OMARCHY_LAUNCHER=/usr/share/omarchy/bin/omarchy-launch-shell

"$ROOT/bin/serpantinumd" stop 2>/dev/null
pkill -f "quickshell.*$MAIN_QML" 2>/dev/null
pkill -f focus_daemon.py 2>/dev/null

RT="${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
export XDG_RUNTIME_DIR="$RT"
if [ -z "${WAYLAND_DISPLAY:-}" ]; then
  sock="$(ls "$RT"/wayland-[0-9]* 2>/dev/null | grep -v '\.lock$' | head -1)"
  [ -n "$sock" ] && export WAYLAND_DISPLAY="$(basename "$sock")"
fi
if [ -z "${HYPRLAND_INSTANCE_SIGNATURE:-}" ]; then
  sig="$(ls -t "$RT/hypr" 2>/dev/null | head -1)"
  [ -n "$sig" ] && export HYPRLAND_INSTANCE_SIGNATURE="$sig"
fi

if [ -z "${WAYLAND_DISPLAY:-}" ]; then
  echo "No Wayland session found; Serpantinum is stopped. Log back in to get the stock desktop."
  exit 0
fi

# Omarchy's own shell: start its launcher again (same as the session does) unless it is already running.
if [ -x "$OMARCHY_LAUNCHER" ] && ! pgrep -f 'quickshell.* -p /usr/share/omarchy/shell' >/dev/null 2>&1 \
   && ! pgrep -f "bash $OMARCHY_LAUNCHER" >/dev/null 2>&1; then
  OMARCHY_PATH="${OMARCHY_PATH:-/usr/share/omarchy}" setsid "$OMARCHY_LAUNCHER" >/dev/null 2>&1 &
  echo "started Omarchy shell"
fi
rm -f "$STATE/omarchy-launcher-stopped"

# Anything else run-lite.sh stopped (nothing is started if there is no record).
if [ -f "$STATE/other-stopped" ]; then others="$(sort -u "$STATE/other-stopped")"; else others=""; fi
for p in $others; do
  command -v "$p" >/dev/null 2>&1 && ! pgrep -x "$p" >/dev/null 2>&1 && { setsid "$p" >/dev/null 2>&1 & echo "started $p"; }
done
rm -f "$STATE/other-stopped"
echo "To also restore your previous bar settings: $ROOT/lite/apply-bar.sh revert"
