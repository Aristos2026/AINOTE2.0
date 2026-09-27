#!/data/data/com.termux/files/usr/bin/bash
# Removes the Claude Code setup created by install.sh. Run inside Termux.
#   bash uninstall.sh            remove the launcher, keep the Ubuntu container
#   bash uninstall.sh --all      also delete the Ubuntu container (and Claude's
#                                settings and login inside it)
set -euo pipefail

[ -n "${PREFIX:-}" ] || { echo "Run this inside Termux." >&2; exit 1; }

if [ -f "$PREFIX/bin/claude" ]; then
  rm -f "$PREFIX/bin/claude"
  echo "Removed $PREFIX/bin/claude"
fi

if [ "${1:-}" = "--all" ]; then
  rootfs="$PREFIX/var/lib/proot-distro/installed-rootfs"
  for d in "$rootfs"/ubuntu*; do
    [ -d "$d" ] || continue
    name=$(basename "$d")
    echo "Deleting Ubuntu container '$name' (this removes Claude Code, its login and settings)"
    proot-distro remove "$name"
  done
  echo "You can also delete the kit checkout: rm -rf ~/.claude-ainote"
fi
echo "Done."
