#!/data/data/com.termux/files/usr/bin/bash
# `claude` command for Termux on the iFLYTEK AINOTE 2.
# Starts Claude Code inside the Ubuntu proot container, in the current directory.
# Installed by install.sh to $PREFIX/bin/claude with @DISTRO@ filled in.
#
# Pass-through: every argument goes to Claude Code, e.g.
#   claude                    interactive session in this folder
#   claude --version
#   claude doctor
#   claude auth login         print the login URL instead of opening a browser
#   claude update             update Claude Code inside the container
#
# Extra: `claude --shell` opens a plain bash shell inside the Ubuntu container.

DISTRO="${CLAUDE_AINOTE_DISTRO:-@DISTRO@}"

if [ "${1:-}" = "--shell" ]; then
  shift
  exec proot-distro login "$DISTRO" --shared-tmp --bind "$HOME:$HOME" -- /bin/bash -l "$@"
fi

# proot-distro shares /sdcard and Termux's own tree by default; the explicit
# --bind makes sure Termux's home is visible at the same path inside the
# container whatever the proot-distro version, so the current directory carries over.
# Arguments: $1 = host cwd, $2 = host TERM, rest = Claude Code args.
# shellcheck disable=SC2016  # the single-quoted script is expanded inside the container
exec proot-distro login "$DISTRO" --shared-tmp --bind "$HOME:$HOME" -- /bin/bash -c '
  host_pwd="$1"; host_term="$2"; shift 2
  export TERM="${host_term:-xterm-256color}"
  export LANG="${LANG:-C.UTF-8}"
  export PATH="$HOME/.local/bin:$PATH"
  cd "$host_pwd" 2>/dev/null || cd "$HOME"
  if [ ! -x "$HOME/.local/bin/claude" ]; then
    echo "error: Claude Code is not installed inside the Ubuntu container." >&2
    echo "       Re-run install.sh from the AINOTE kit." >&2
    exit 127
  fi
  exec "$HOME/.local/bin/claude" "$@"
' claude "$PWD" "${TERM:-xterm-256color}" "$@"
