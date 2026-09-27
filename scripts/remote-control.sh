#!/data/data/com.termux/files/usr/bin/bash
# Starts Claude Code Remote Control on the tablet so it appears in the Claude
# app's Code tab. Keeps it alive: if it exits, it restarts after a pause.
# Run inside Termux:  bash ~/.claude-ainote/scripts/remote-control.sh
# Logs: ~/remote-control.log
set -u
export PATH="$PREFIX/bin:$PATH"
LOG="$HOME/remote-control.log"
WORKDIR="${CLAUDE_REMOTE_DIR:-$HOME}"

termux-wake-lock 2>/dev/null || true
cd "$WORKDIR" || cd "$HOME" || exit 1

echo "$(date) starting remote control in $PWD" >> "$LOG"
while true; do
  claude remote-control >> "$LOG" 2>&1
  echo "$(date) remote control exited with $?, restarting in 15s" >> "$LOG"
  sleep 15
done
