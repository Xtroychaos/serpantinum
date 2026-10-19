#!/usr/bin/env bash
# Terminal-only recovery: stop Serpantinum and bring back the stock Omarchy components.
# Works from a TTY (Ctrl+Alt+F3) after: export HYPRLAND_INSTANCE_SIGNATURE=... if needed, or just run it in the session.
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
"$ROOT/bin/serpantinumd" stop 2>/dev/null
pkill -f "quickshell.*serpantinum" 2>/dev/null
pkill -f focus_daemon.py 2>/dev/null
for p in waybar mako hypridle swayosd-server; do
  command -v "$p" >/dev/null 2>&1 && ! pgrep -x "$p" >/dev/null 2>&1 && { setsid "$p" >/dev/null 2>&1 & echo "started $p"; }
done
# Restore your pre-lite Serpantinum settings, if you applied the bar config.
"$ROOT/lite/apply-bar.sh" revert 2>/dev/null || true
