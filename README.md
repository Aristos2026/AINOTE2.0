# Claude Code on the iFLYTEK AINOTE 2

A one-command setup that puts [Claude Code](https://code.claude.com/docs/en/overview) on the
iFLYTEK AINOTE 2 e-ink tablet, plus settings tuned for its screen and on-screen keyboard.

| Device fact | Value | Why it matters |
| --- | --- | --- |
| OS | Android 14, Google Play, sideloading allowed | Termux installs like any other app |
| CPU | Rockchip RK3576, 8 cores, arm64 | Claude Code ships a `linux-arm64` binary |
| RAM / storage | 4 GB / 64 GB | Meets Claude Code's 4 GB minimum; the install uses about 1.5 GB |
| Screen | 10.65" e-ink, 1920x2560 | Light theme, no animations, fewer redraws |

## How it works

Claude Code is a native Linux binary built against glibc. Android's Termux uses Bionic libc, so the
official installer (`curl -fsSL https://claude.ai/install.sh | bash`) and the npm package both fail
there. Anthropic does not list Android as a supported platform.

This kit sidesteps that by creating a small **Ubuntu container inside Termux** with
[proot-distro](https://github.com/termux/proot-distro) (no root or unlocking needed), running
Anthropic's **official installer inside Ubuntu**, and adding a `claude` command to Termux that
transparently starts Claude Code in that container, in your current folder. Auto-updates work as
normal because Claude Code sees an ordinary Ubuntu system.

```
Termux (Android)            Ubuntu (proot)
  $ claude       ──────►    ~/.local/bin/claude   ← official arm64 binary
  ~/projects/app            same path, same files
```

## Install

**1. Install Termux** on the tablet. Get the APK from
[F-Droid](https://f-droid.org/packages/com.termux/) or the
[Termux GitHub releases](https://github.com/termux/termux-app/releases) (`termux-app_*_arm64-v8a.apk`).
Open it in the tablet's browser, download, tap the file and allow installing from that source.
Avoid the Play Store build, which lags behind and has restrictions that break proot.

**2. Open Termux and run:**

```bash
pkg install -y git && git clone https://github.com/Aristos2026/AINOTE2.0.git ~/.claude-ainote && bash ~/.claude-ainote/install.sh
```

The install takes 10 to 20 minutes on Wi-Fi. Keep the screen on and Termux in the foreground;
Android may kill background downloads. Wait for `Claude Code is installed.`

**3. Sign in.** In any folder, run `claude`. Claude Code prints a login URL. Long-press to select
and copy it, open it in the tablet's browser, and sign in with a Claude Pro, Max, Team, Enterprise
or Console account (the free plan does not include Claude Code). The browser normally hands you back
to Termux. If it shows a code instead, paste it at the `Paste code here if prompted` prompt.

If pasting in the interactive prompt does nothing, run `claude auth login` instead, which prints the
URL and reads the code from standard input.

**4. Check:** `claude --version` and `claude doctor`.

## Daily use

```bash
cd ~/projects/my-app   # any folder under ~ or /sdcard
claude                 # start a session here
claude doctor          # diagnostics
claude update          # update Claude Code (also happens automatically, stable channel)
claude --shell         # plain bash inside the Ubuntu container (apt, python, node, ...)
```

Inside a session, `/theme` switches themes, `/config` opens settings and `/tui fullscreen`
switches to a full-screen renderer that some e-ink users prefer.

Files under Termux's home (`~`) and shared storage (`/sdcard`) are visible at the same paths inside
Ubuntu, so `git clone` in Termux and `claude` in Ubuntu see the same checkout. Run
`termux-setup-storage` once if you want `/sdcard` access.

## What the installer changes

Termux side:

- Installs the `proot-distro` and `git` packages and an Ubuntu container named `ubuntu`
  (`proot-distro list` shows it).
- Adds `$PREFIX/bin/claude` (from `scripts/claude-launcher.sh`).
- Adds `~/.termux/termux.properties` with an Esc / Tab / Ctrl / arrow key row if you had none
  (from `config/termux.properties`).

Ubuntu side (all under the container's `/root`):

- `curl`, `git`, `ripgrep`, `nano` and friends via apt.
- Claude Code at `~/.local/bin/claude` via `https://claude.ai/install.sh`.
- `~/.claude/settings.json` from `config/settings.json`: stable update channel, reduced motion, no
  spinner tips, terminal bell (Termux turns it into a vibration), 80-column prose.
- Light theme in `~/.claude.json`.

To pin a version: `CLAUDE_VERSION=2.1.283 bash ~/.claude-ainote/install.sh`.
To remove everything: `bash ~/.claude-ainote/scripts/uninstall.sh --all`.

## More

- [docs/e-ink-tips.md](docs/e-ink-tips.md): screen, keyboard and battery tips.
- [docs/troubleshooting.md](docs/troubleshooting.md): common errors and fixes.
- [docs/alternative-native-termux.md](docs/alternative-native-termux.md): running the binary directly
  in Termux without Ubuntu (faster, less tested).

## Sources

- Claude Code setup and system requirements: https://code.claude.com/docs/en/setup
- Install and login troubleshooting: https://code.claude.com/docs/en/troubleshoot-install
- Terminal configuration: https://code.claude.com/docs/en/terminal-config
- proot-distro: https://github.com/termux/proot-distro
- AINOTE 2 specifications: https://store.iflytek.com/products/iflytek-ainote-2
- Community Android approaches this kit builds on: https://github.com/ferrumclaudepilgrim/claude-code-android
