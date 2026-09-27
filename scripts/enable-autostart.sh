#!/data/data/com.termux/files/usr/bin/bash
# Makes Remote Control start automatically when the tablet boots.
# Needs the Termux:Boot add-on app installed once (see docs/remote-control.md).
# Run inside Termux:  bash ~/.claude-ainote/scripts/enable-autostart.sh
set -eu

KIT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$HOME/.termux/boot"
cat > "$HOME/.termux/boot/10-claude-remote-control.sh" <<BOOT
#!/data/data/com.termux/files/usr/bin/bash
# Installed by the AINOTE Claude kit. Starts Claude Code Remote Control at boot.
termux-wake-lock
nohup bash "$KIT_DIR/scripts/remote-control.sh" >/dev/null 2>&1 &
BOOT
chmod +x "$HOME/.termux/boot/10-claude-remote-control.sh"
echo "Boot script installed at ~/.termux/boot/10-claude-remote-control.sh"

if ! { pm list packages 2>/dev/null || cmd package list packages 2>/dev/null; } | grep -q com.termux.boot; then
  echo
  echo "Termux:Boot is not installed yet. Install it from"
  echo "  https://f-droid.org/packages/com.termux.boot/"
  echo "open it once, then restart the tablet."
else
  echo "Termux:Boot is installed. Restart the tablet, or start it now with:"
  echo "  nohup bash $KIT_DIR/scripts/remote-control.sh >/dev/null 2>&1 &"
fi
