#!/usr/bin/env bash
# Baseline sampler for Serpantinum processes. Run with the shell idle, then again after use.
# Usage: measure.sh [seconds=60]   Output: one CSV per run in ./lite/results/
set -u
DUR="${1:-60}"
OUT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/results"; mkdir -p "$OUT"
F="$OUT/$(date +%Y%m%d-%H%M%S).csv"
echo "proc,pid,rss_kb,pss_kb,private_kb" > "$F"
for pat in "quickshell.*quickshell/Shell.qml" "cava" "focus_daemon.py" "idle_helper.py"; do
  for pid in $(pgrep -f "$pat"); do
    s="/proc/$pid/smaps_rollup"; [ -r "$s" ] || continue
    rss=$(awk '/^Rss:/{print $2}' "$s"); pss=$(awk '/^Pss:/{print $2}' "$s")
    priv=$(awk '/^Private_(Clean|Dirty):/{t+=$2} END{print t}' "$s")
    echo "$pat,$pid,$rss,$pss,$priv" >> "$F"
  done
done
qs=$(pgrep -f "quickshell.*quickshell/Shell.qml" | head -1)
if [ -n "$qs" ]; then
  t0=$(awk '{print $14+$15}' /proc/$qs/stat); sleep "$DUR"; t1=$(awk '{print $14+$15}' /proc/$qs/stat)
  echo "quickshell idle CPU over ${DUR}s: $(( (t1-t0) * 100 / $(getconf CLK_TCK) / DUR ))% of one core (approx)" | tee -a "$F.cpu.txt"
fi
echo "wrote $F"
