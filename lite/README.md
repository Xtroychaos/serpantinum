# Serpantinum Lite (additive, no existing file modified)

Base commit: bc630542648b532753a1c410acf5efd8138c925a. Branch: lite/optimise.

- `bar-lite.json` / `apply-bar.sh apply|revert`: cleaner top bar by config only. Backs up to `settings.json.pre-lite`.
- `run-lite.sh`: run from this checkout, no installer. Stops waybar/mako/swaync/hypridle/swayosd-server for this session only.
- `recover.sh`: stops Serpantinum and restarts stock components (run inside the session; finds the sockets if run from a terminal). Bar settings are restored separately with `apply-bar.sh revert`.
- `measure.sh`: RSS/PSS/private memory and idle CPU sampler (writes lite/results/*.csv).

Status: scripts syntax-checked and the settings merge/revert round-trip tested on a copy. Nothing has been run against a live Hyprland/Omarchy session (NOT TESTED).
Rollback: `lite/recover.sh`, or `git checkout bc63054`, or delete `lite/`.
