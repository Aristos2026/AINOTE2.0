#!/bin/bash
# Stage 2 of the AINOTE 2 install: runs INSIDE the Ubuntu proot container.
# Installs runtime dependencies, then Claude Code via Anthropic's official
# installer, then applies e-ink friendly defaults.
#
# Usage: bash ubuntu-setup.sh [latest|stable|<version>]
set -euo pipefail

CHANNEL_OR_VERSION="${1:-latest}"
KIT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)

log()  { printf '\n\033[1;32m  ->\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33mwarning:\033[0m %s\n' "$*" >&2; }

SUDO=""
if [ "$(id -u)" -ne 0 ]; then
  command -v sudo >/dev/null 2>&1 && SUDO="sudo"
fi

export DEBIAN_FRONTEND=noninteractive

log "Installing Ubuntu packages (curl, git, ripgrep, ...)"
$SUDO apt-get update -q
$SUDO apt-get install -y -q --no-install-recommends \
  ca-certificates curl bash git ripgrep procps less nano python3 \
  libstdc++6 libgcc-s1 tzdata locales

# A UTF-8 locale keeps Claude Code's box-drawing characters intact.
if ! locale -a 2>/dev/null | grep -qi 'C.utf8\|C.UTF-8'; then
  $SUDO locale-gen C.UTF-8 >/dev/null 2>&1 || true
fi

log "Running Anthropic's official installer ($CHANNEL_OR_VERSION)"
# The installer detects linux-arm64 + glibc (Ubuntu inside proot) and places the
# binary at ~/.local/bin/claude with versions under ~/.local/share/claude/.
curl -fsSL https://claude.ai/install.sh | bash -s "$CHANNEL_OR_VERSION"

CLAUDE_BIN="$HOME/.local/bin/claude"
[ -x "$CLAUDE_BIN" ] || { echo "error: $CLAUDE_BIN was not created by the installer" >&2; exit 1; }

# Make sure interactive shells inside the container can find it too.
if ! grep -qs '\.local/bin' "$HOME/.bashrc" 2>/dev/null; then
  # shellcheck disable=SC2016
  echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$HOME/.bashrc"
fi
grep -qs 'LANG=' "$HOME/.bashrc" 2>/dev/null || echo 'export LANG=C.UTF-8' >> "$HOME/.bashrc"

log "Applying e-ink friendly Claude Code settings"
mkdir -p "$HOME/.claude"
if [ -f "$HOME/.claude/settings.json" ]; then
  warn "$HOME/.claude/settings.json already exists inside Ubuntu; leaving it alone. See config/settings.json for the suggested values."
else
  cp "$KIT_DIR/config/settings.json" "$HOME/.claude/settings.json"
fi

# Light theme reads far better on e-ink. This is stored in ~/.claude.json.
# `claude config` is a legacy command; fall back to writing the key directly.
if ! "$CLAUDE_BIN" config set -g theme light >/dev/null 2>&1; then
  if [ -f "$HOME/.claude.json" ]; then
    warn "Could not set the theme automatically; run /theme inside Claude Code and choose Light."
  else
    printf '{\n  "theme": "light"\n}\n' > "$HOME/.claude.json"
  fi
fi

log "Installing iFLYTEK's official ainote skill (/ainote inside Claude Code)"
# Source: https://github.com/iflyink/ainote - talks to the AINOTE app's local
# OpenModel API (port 46588) to read and write real notes, folders and schedules.
SKILL_URL="${AINOTE_SKILL_URL:-https://github.com/iflyink/ainote.git}"
SKILL_DIR="$HOME/.claude/skills/ainote"
mkdir -p "$HOME/.claude/skills"
if [ -d "$SKILL_DIR/.git" ]; then
  git -C "$SKILL_DIR" pull --ff-only || warn "Could not update the ainote skill; keeping the existing copy."
else
  rm -rf "$SKILL_DIR"
  git clone --depth 1 "$SKILL_URL" "$SKILL_DIR"
fi
[ -f "$SKILL_DIR/SKILL.md" ] || warn "ainote skill not found at $SKILL_DIR after install."

log "Verifying"
"$CLAUDE_BIN" --version
