# Troubleshooting

Run these first; they answer most questions:

```bash
claude --version      # prints e.g. 2.1.283 (Claude Code)
claude doctor         # install health, settings errors, update status
claude --shell        # a bash prompt inside Ubuntu for poking around
```

## Install problems

**`This script must run inside Termux`**
You ran `install.sh` somewhere other than Termux on the tablet. Every command in this kit runs in the
Termux app.

**`pkg update` fails or hangs**
Termux's mirror may be unreachable. Run `termux-change-repo`, pick a different mirror group, then
rerun the installer.

**`proot-distro could not install Ubuntu`**
Check `proot-distro list` for the Ubuntu name your version offers, then
`AINOTE_DISTRO=<name> bash ~/.claude-ainote/install.sh`. Very old proot-distro versions need
`pkg upgrade` first.

**Install dies part way (`Killed`, or Termux restarts)**
Android stopped the download. Keep Termux in the foreground, plug in the charger and rerun the
installer. It is safe to rerun; existing steps are skipped. See the battery section in
[e-ink-tips.md](e-ink-tips.md) for the phantom-process limit.

**`Failed to fetch version from downloads.claude.ai`, `403`, or `curl: (22)`**
The tablet cannot reach Anthropic's download server. Check Wi-Fi, disable any VPN or DNS filter, and
rerun. If you are in a region Anthropic does not serve, Claude Code will not install or log in.

**`Illegal instruction` or `Exec format error` when running `claude`**
The wrong binary was downloaded. Inside `claude --shell` run `uname -m` (must say `aarch64`) and
`ldd --version` (must say GNU libc). Then remove and reinstall:

```bash
rm -rf ~/.local/bin/claude ~/.local/share/claude
curl -fsSL https://claude.ai/install.sh | bash
```

**Bundled ripgrep fails / search tools return nothing**
Ubuntu's `ripgrep` package is already installed. Tell Claude Code to use it: inside `claude --shell`
add `"USE_BUILTIN_RIPGREP": "0"` to the `env` object in `~/.claude/settings.json`.

## Login problems

**The browser never opens**
Expected: there is no `xdg-open` in the container. Copy the URL from the terminal (long-press to
select) or run `claude auth login`, which prints it plainly.

**Browser shows a code instead of returning to the terminal**
Normal for a sandboxed install. Paste the code at `Paste code here if prompted`. If pasting does
nothing, quit and run `claude auth login`, which reads the code from standard input.

**`OAuth error: Invalid code`**
The code expired or was cut off. Start again and complete the browser step quickly.

**`Claude Code access has not been granted for this account`**
Claude Code needs Pro, Max, Team, Enterprise or an Anthropic Console account. Free claude.ai plans
do not include it.

**Start over**
`claude auth logout`, or delete `~/.claude/.credentials.json` inside `claude --shell`.

## Runtime problems

**Slow file operations**
proot traces every system call, so `npm install`, large `git` operations and compilers run slower
than on a laptop. Claude Code itself is fine. Keep projects small on the device or use it against a
remote machine over SSH (`pkg install openssh` in Termux).

**Box-drawing characters look wrong**
Make sure the container locale is UTF-8: `echo $LANG` inside `claude --shell` should print
`C.UTF-8`. The installer adds it to `~/.bashrc` and the launcher exports it.

**Screen flickers or scroll jumps**
`/tui fullscreen`.

**`command not found: claude` in Termux**
The launcher is `$PREFIX/bin/claude`. Rerun `install.sh`, or copy `scripts/claude-launcher.sh` there
manually and replace `@DISTRO@` with your container name.

**Update went wrong**
`claude update` inside the launcher. If the binary is broken, pin a known version:
`CLAUDE_VERSION=2.1.283 bash ~/.claude-ainote/install.sh`.
