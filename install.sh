#!/data/data/com.termux/files/usr/bin/bash
# Claude Code installer for the iFLYTEK AINOTE 2 (Android 14, arm64) - run inside Termux.
#
# What it does:
#   1. Updates Termux and installs proot-distro + git.
#   2. Creates an Ubuntu container (no root needed) with proot-distro.
#   3. Runs scripts/ubuntu-setup.sh inside Ubuntu, which uses Anthropic's
#      official installer to put the native linux-arm64 Claude Code binary in place.
#   4. Installs a `claude` command in Termux that starts Claude Code inside Ubuntu,
#      in whatever directory you are currently in.
#
# Usage (inside Termux):
#   bash install.sh                 # from a clone of this repo
#   curl -fsSL <raw url>/install.sh | bash
#
# Environment overrides:
#   CLAUDE_VERSION=2.1.283   install a specific Claude Code version (default: latest)
#   AINOTE_KIT_DIR=...       where to keep this kit (default: ~/.claude-ainote)
#   AINOTE_REPO_URL=...      git URL to clone when not running from a checkout
set -euo pipefail

KIT_DEFAULT_DIR="$HOME/.claude-ainote"
KIT_DIR="${AINOTE_KIT_DIR:-$KIT_DEFAULT_DIR}"
REPO_URL="${AINOTE_REPO_URL:-https://github.com/Aristos2026/AINOTE2.0.git}"
CONTAINER_KIT_PATH="/opt/claude-ainote"

log()  { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31merror:\033[0m %s\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------- preflight
if [ -z "${PREFIX:-}" ] || [ ! -d /data/data/com.termux ]; then
  die "This script must run inside Termux on the tablet (PREFIX is not set)."
fi

case "$(uname -m)" in
  aarch64|arm64) ;;
  *) die "Unsupported CPU architecture '$(uname -m)'. The AINOTE 2 (RK3576) should report aarch64." ;;
esac

if ! command -v curl >/dev/null 2>&1; then
  pkg install -y curl
fi

# Rough free-space check on the Termux data partition. Ubuntu + Claude Code
# needs about 1.5 GB; ask for 3 GB so apt has room to work.
avail_kb=$(df -k "$HOME" | awk 'NR==2 {print $4}')
if [ "${avail_kb:-0}" -lt 3000000 ]; then
  warn "Less than 3 GB free on the device. The install may run out of space."
fi

# ---------------------------------------------------------------- Termux packages
log "Updating Termux packages"
export DEBIAN_FRONTEND=noninteractive
pkg update -y
pkg upgrade -y -o Dpkg::Options::=--force-confold
pkg install -y proot-distro git

# ---------------------------------------------------------------- get the kit
# If this script is running from inside a checkout that has scripts/ubuntu-setup.sh,
# use that. Otherwise clone (or update) the repo into KIT_DIR.
script_dir=""
if [ -n "${BASH_SOURCE[0]:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  script_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
fi
if [ -n "$script_dir" ] && [ -f "$script_dir/scripts/ubuntu-setup.sh" ]; then
  KIT_DIR="$script_dir"
else
  if [ -d "$KIT_DIR/.git" ]; then
    log "Updating kit in $KIT_DIR"
    git -C "$KIT_DIR" pull --ff-only || warn "git pull failed; using the existing copy"
  else
    log "Cloning kit into $KIT_DIR"
    git clone --depth 1 "$REPO_URL" "$KIT_DIR"
  fi
fi
[ -f "$KIT_DIR/scripts/ubuntu-setup.sh" ] || die "scripts/ubuntu-setup.sh not found in $KIT_DIR"

# ---------------------------------------------------------------- Ubuntu container
# proot-distro has changed where it stores containers between releases, so never
# look for a directory: ask proot-distro whether the container can be entered.
DISTRO="${AINOTE_DISTRO:-ubuntu}"

container_works() {
  proot-distro login "$1" -- /bin/true >/dev/null 2>&1
}

if container_works "$DISTRO"; then
  log "Ubuntu container '$DISTRO' already exists, reusing it"
else
  log "Installing Ubuntu with proot-distro (downloads a few hundred MB)"
  if ! proot-distro install ubuntu && ! proot-distro install ubuntu:24.04; then
    die "proot-distro could not install Ubuntu. Run 'proot-distro list' to see available names and rerun with AINOTE_DISTRO=<name>."
  fi
  if ! container_works "$DISTRO"; then
    echo "Installed containers according to proot-distro:" >&2
    proot-distro list >&2 || true
    die "Ubuntu installed but 'proot-distro login $DISTRO' fails. Rerun with AINOTE_DISTRO=<name from the list above>."
  fi
fi

# ---------------------------------------------------------------- Claude Code inside Ubuntu
log "Installing Claude Code inside Ubuntu (this is the slow step)"
proot-distro login "$DISTRO" --shared-tmp \
  --bind "$KIT_DIR:$CONTAINER_KIT_PATH" \
  -- /bin/bash "$CONTAINER_KIT_PATH/scripts/ubuntu-setup.sh" "${CLAUDE_VERSION:-latest}"

# ---------------------------------------------------------------- Termux side
log "Installing the 'claude' launcher into $PREFIX/bin"
sed "s|@DISTRO@|$DISTRO|g" "$KIT_DIR/scripts/claude-launcher.sh" > "$PREFIX/bin/claude"
chmod 755 "$PREFIX/bin/claude"

mkdir -p "$HOME/.termux"
if [ ! -f "$HOME/.termux/termux.properties" ]; then
  log "Installing Termux extra-keys row (Esc, Tab, Ctrl, arrows) for Claude Code"
  cp "$KIT_DIR/config/termux.properties" "$HOME/.termux/termux.properties"
  termux-reload-settings 2>/dev/null || true
else
  warn "$HOME/.termux/termux.properties already exists; see config/termux.properties for the suggested keys row."
fi

log "Checking the install"
claude --version

cat <<MSG

Claude Code is installed.

  Next steps
  ----------
  1. cd into a project folder (or stay in ~) and run:   claude
  2. Sign in: Claude Code prints a login URL. Long-press it in Termux to copy,
     open it in the tablet's browser and sign in with your Claude Pro/Max or
     Console account. If the browser shows a code instead of returning to the
     terminal, paste it at the "Paste code here if prompted" prompt.
  3. Type /theme and pick "Light" for the e-ink screen (if the setup did not already).

  Docs: $KIT_DIR/README.md and $KIT_DIR/docs/
MSG
